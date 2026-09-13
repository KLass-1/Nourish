const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

// Load environment variables from .env file
dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;
const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
const GEMINI_MODEL = process.env.GEMINI_MODEL || 'gemini-3.6-flash';

// Middleware
app.use(cors());
app.use(express.json());

// Health Check Endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'Nourish Nutrition Analysis Backend',
    hasApiKey: Boolean(GEMINI_API_KEY && GEMINI_API_KEY.trim().length > 0),
    model: GEMINI_MODEL,
  });
});

// Helper to sanitize and parse JSON returned by Gemini
function parseGeminiJsonResponse(rawText) {
  let cleaned = rawText.trim();
  // Remove markdown code fences if Gemini included them
  if (cleaned.startsWith('```json')) {
    cleaned = cleaned.replace(/^```json\s*/i, '').replace(/```\s*$/, '');
  } else if (cleaned.startsWith('```')) {
    cleaned = cleaned.replace(/^```\s*/, '').replace(/```\s*$/, '');
  }
  cleaned = cleaned.trim();
  return JSON.parse(cleaned);
}

// POST /api/analyze-health
app.post('/api/analyze-health', async (req, res) => {
  try {
    const {
      age,
      gender,
      height,
      weight,
      dietType,
      waterIntake,
      sleepDuration,
      exerciseFrequency,
      sunlightExposure,
      symptoms = [],
    } = req.body;

    // Check if API key is provided
    if (!GEMINI_API_KEY || GEMINI_API_KEY.trim() === '' || GEMINI_API_KEY === 'your_gemini_api_key_here') {
      return res.status(500).json({
        success: false,
        error: 'Gemini API key is not configured. Please set GEMINI_API_KEY in the backend/.env file.',
      });
    }

    // Build the constrained prompt for Gemini
    const systemPrompt = `You are a nutrition and wellness analysis assistant.
Your goal is to estimate POSSIBLE nutrient gaps or nutritional risk areas based strictly on user-reported habits and symptoms.

CRITICAL SAFETY & MEDICAL CONSTRAINTS:
1. You must NOT claim the user has a confirmed deficiency or disease.
2. You must NOT present this as a medical diagnosis or clinical finding.
3. Do NOT invent blood test values, lab numbers, or clinical measurements that the user did not provide.
4. Allowed risk values are strictly: "Low", "Moderate", "High".
5. Provide practical, gentle food and lifestyle suggestions.
6. Return your response ONLY as a JSON object matching this exact schema:
{
  "results": [
    {
      "nutrient": "Nutrient name (e.g. Vitamin B12, Vitamin D, Iron, Calcium, Zinc)",
      "risk": "Low" | "Moderate" | "High",
      "reason": "Short, clear explanation based on the user's provided information.",
      "suggestions": [
        "General food suggestion",
        "General lifestyle suggestion"
      ]
    }
  ]
}`;

    const userPrompt = `Analyze the following user health check data for potential nutrient risk areas:
- Age: ${age ?? 'Not specified'}
- Gender: ${gender ?? 'Not specified'}
- Height: ${height ?? 'Not specified'} cm
- Weight: ${weight ?? 'Not specified'} kg
- Dietary Preference: ${dietType ?? 'Not specified'}
- Daily Water Intake: ${waterIntake ?? 'Not specified'}
- Average Sleep Duration: ${sleepDuration ?? 'Not specified'} hours/day
- Physical Activity Frequency: ${exerciseFrequency ?? 'Not specified'}
- Direct Sunlight Exposure: ${sunlightExposure ?? 'Not specified'}
- Logged Symptoms: ${symptoms.length > 0 ? symptoms.join(', ') : 'None reported'}

Return the JSON analysis results following the required schema. Include 2 to 5 relevant nutrients.`;

    const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent?key=${GEMINI_API_KEY}`;

    const requestPayload = {
      systemInstruction: {
        parts: [{ text: systemPrompt }],
      },
      contents: [
        {
          role: 'user',
          parts: [{ text: userPrompt }],
        },
      ],
      generationConfig: {
        responseMimeType: 'application/json',
        temperature: 0.3,
      },
    };

    const response = await fetch(geminiUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(requestPayload),
    });

    if (!response.ok) {
      const errText = await response.text();
      console.error('Gemini API error response:', response.status, errText);
      return res.status(response.status).json({
        success: false,
        error: `Gemini API returned error: ${response.status} ${response.statusText}`,
        details: errText,
      });
    }

    const data = await response.json();
    const candidateText = data.candidates?.[0]?.content?.parts?.[0]?.text;

    if (!candidateText) {
      throw new Error('Gemini API did not return any content parts.');
    }

    const parsedJson = parseGeminiJsonResponse(candidateText);

    // Validate and sanitize the results list
    const rawResults = parsedJson.results || [];
    const validRisks = ['Low', 'Moderate', 'High'];

    const sanitizedResults = rawResults.map((item) => {
      let risk = item.risk || 'Low';
      if (!validRisks.includes(risk)) {
        // Fallback normalization
        if (risk.toLowerCase().includes('high')) risk = 'High';
        else if (risk.toLowerCase().includes('mod')) risk = 'Moderate';
        else risk = 'Low';
      }

      return {
        nutrient: String(item.nutrient || 'General Nutrition'),
        risk: risk,
        reason: String(item.reason || 'Estimated based on provided lifestyle parameters.'),
        suggestions: Array.isArray(item.suggestions)
          ? item.suggestions.map((s) => String(s))
          : [],
      };
    });

    return res.json({
      success: true,
      results: sanitizedResults,
    });
  } catch (error) {
    console.error('Error handling /api/analyze-health:', error);
    return res.status(500).json({
      success: false,
      error: error.message || 'Internal server error while analyzing health assessment.',
    });
  }
});

// Start listening on all network interfaces (0.0.0.0)
app.listen(PORT, '0.0.0.0', () => {
  console.log(`========================================`);
  console.log(` Nourish Backend running on port ${PORT}`);
  console.log(` Local: http://localhost:${PORT}/health`);
  console.log(` Analysis API: http://localhost:${PORT}/api/analyze-health`);
  console.log(`========================================`);
});

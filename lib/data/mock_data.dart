import '../models/assessment_model.dart';

class MockData {
  static const List<String> symptomsList = [
    'Fatigue',
    'Hair fall',
    'Muscle weakness',
    'Pale skin',
    'Dry skin',
    'Frequent illness',
    'Poor concentration',
    'Bone discomfort',
    'Tingling sensation',
  ];

  static const List<String> dietTypes = [
    'Vegetarian',
    'Non-Vegetarian',
    'Vegan',
    'Other',
  ];

  static const List<String> exerciseFrequencies = [
    'Rarely',
    '1-2 times/week',
    '3-4 times/week',
    'Daily',
  ];

  static const List<String> sunlightExposures = [
    '< 15 mins',
    '15-30 mins',
    '30-60 mins',
    '> 60 mins',
  ];

  static const List<String> waterIntakes = [
    '< 1 Litre',
    '1-2 Litres',
    '2-3 Litres',
    '> 3 Litres',
  ];

  // Map of recommendations based on deficiency
  static final Map<String, Map<String, List<String>>> recommendations = {
    'Vitamin D': {
      'diet': [
        'Incorporate fortified foods like milk, orange juice, and cereals.',
        'Consume fatty fish (if non-vegetarian) or mushrooms exposed to UV light.',
        'Consider egg yolks if they fit your dietary preferences.'
      ],
      'lifestyle': [
        'Get 15-20 minutes of daily sunlight exposure, preferably in the morning.',
        'Engage in weight-bearing exercises to build bone density.',
      ],
      'general': [
        'Vitamin D is critical for Calcium absorption.',
        'Consult a healthcare professional for a serum 25(OH)D blood test.'
      ]
    },
    'Vitamin B12': {
      'diet': [
        'Consume fortified plant milks, breakfast cereals, and nutritional yeast.',
        'For vegetarians, include dairy products like milk, cheese, and yogurt.',
        'For non-vegetarians, poultry, fish, and eggs are rich sources.'
      ],
      'lifestyle': [
        'Keep track of energy levels and cognitive performance.',
        'Maintain a balanced sleep schedule to help with neurological regeneration.'
      ],
      'general': [
        'Since B12 is primarily found in animal products, vegans should consider regular supplementation.',
        'B12 deficiency can take years to manifest but is crucial for nerve health.'
      ]
    },
    'Iron': {
      'diet': [
        'Consume iron-rich foods: spinach, legumes, lentils, pumpkin seeds, and quinoa.',
        'Combine iron-rich foods with Vitamin C (e.g., lemon juice on spinach) to double absorption.',
        'Avoid drinking tea or coffee immediately after meals, as tannins block iron absorption.'
      ],
      'lifestyle': [
        'Incorporate cardiovascular workouts at a moderate intensity.',
        'Allow plenty of time for rest, as iron deficiency directly causes fatigue.'
      ],
      'general': [
        'Iron is essential for producing hemoglobin, which carries oxygen in blood.',
        'Check ferritin levels if fatigue and pale skin persist.'
      ]
    },
    'Vitamin C': {
      'diet': [
        'Eat citrus fruits: oranges, lemons, grapefruits, and limes.',
        'Incorporate bell peppers, strawberries, tomatoes, and broccoli into meals.',
        'Prefer raw fruits and vegetables, as heat destroys Vitamin C.'
      ],
      'lifestyle': [
        'Practice stress management techniques, as stress depletes Vitamin C levels.',
        'Maintain regular light physical activity to keep your immune system active.'
      ],
      'general': [
        'Vitamin C is a powerful antioxidant essential for collagen production and skin health.',
        'Helps in wound healing and enhances iron absorption.'
      ]
    },
    'Calcium': {
      'diet': [
        'Consume dairy products: milk, yogurt, and cheese.',
        'Incorporate green leafy vegetables, tofu, almonds, and fortified plant milks.',
        'Eat sesame seeds and chia seeds, which are highly concentrated in calcium.'
      ],
      'lifestyle': [
        'Combine calcium-rich foods with adequate Vitamin D intake for optimal absorption.',
        'Avoid excessive consumption of carbonated sodas, which can deplete bone calcium.'
      ],
      'general': [
        'Calcium is vital for bone structural integrity, muscle contractions, and nerve impulses.',
        'Ensure proper hydration to assist with mineral transport in the body.'
      ]
    }
  };

  // Logic engine to calculate risks based on answers
  static List<DeficiencyRisk> calculateRisks(AssessmentAnswers answers) {
    List<DeficiencyRisk> risks = [];

    // 1. Vitamin D Analysis
    bool lowSunlight = answers.sunlightExposure == '< 15 mins' || answers.sunlightExposure == '15-30 mins';
    bool hasBoneSymptom = answers.symptoms.contains('Bone discomfort') || answers.symptoms.contains('Muscle weakness');
    bool hasFatigue = answers.symptoms.contains('Fatigue');

    if (lowSunlight && hasBoneSymptom) {
      risks.add(DeficiencyRisk(
        name: 'Vitamin D',
        riskLevel: 'High',
        description: 'Your limited sunlight exposure combined with bone or muscle discomfort suggests a high risk of deficiency. Vitamin D is essential for bone health and immune function.',
      ));
    } else if (lowSunlight || (hasBoneSymptom && hasFatigue)) {
      risks.add(DeficiencyRisk(
        name: 'Vitamin D',
        riskLevel: 'Moderate',
        description: 'Moderate risk due to low sun exposure or mild bone/muscle symptoms. Vitamin D is synthesized via skin exposure to sunlight.',
      ));
    } else {
      risks.add(DeficiencyRisk(
        name: 'Vitamin D',
        riskLevel: 'Low',
        description: 'Sufficient sun exposure and lack of related symptoms indicate low current risk.',
      ));
    }

    // 2. Vitamin B12 Analysis
    bool plantDiet = answers.dietType == 'Vegetarian' || answers.dietType == 'Vegan';
    bool hasNeurological = answers.symptoms.contains('Tingling sensation') || answers.symptoms.contains('Poor concentration');
    
    if (plantDiet && hasNeurological) {
      risks.add(DeficiencyRisk(
        name: 'Vitamin B12',
        riskLevel: 'High',
        description: 'A plant-based diet combined with neurological symptoms (tingling, poor concentration) indicates high risk. Vitamin B12 is almost exclusively found in animal products.',
      ));
    } else if (plantDiet || (hasNeurological && hasFatigue)) {
      risks.add(DeficiencyRisk(
        name: 'Vitamin B12',
        riskLevel: 'Moderate',
        description: 'Moderate risk. Since your diet is vegetarian/vegan, you should monitor B12 levels. Fortified foods or supplements are recommended.',
      ));
    } else {
      risks.add(DeficiencyRisk(
        name: 'Vitamin B12',
        riskLevel: 'Low',
        description: 'Regular dietary consumption or lack of neurological indicators suggests low risk.',
      ));
    }

    // 3. Iron Analysis
    bool hasAnemicSymptoms = answers.symptoms.contains('Pale skin') || answers.symptoms.contains('Fatigue') || answers.symptoms.contains('Hair fall');
    
    if (plantDiet && hasAnemicSymptoms) {
      risks.add(DeficiencyRisk(
        name: 'Iron',
        riskLevel: 'High',
        description: 'Plant-based diets have lower-absorbing non-heme iron. Your symptoms (pale skin, fatigue, hair fall) indicate high risk of iron deficiency.',
      ));
    } else if (hasAnemicSymptoms || plantDiet) {
      risks.add(DeficiencyRisk(
        name: 'Iron',
        riskLevel: 'Moderate',
        description: 'Moderate risk. Ensure consumption of iron-rich greens combined with vitamin C to enhance absorption.',
      ));
    } else {
      risks.add(DeficiencyRisk(
        name: 'Iron',
        riskLevel: 'Low',
        description: 'No symptoms or dietary restrictions indicating low iron levels.',
      ));
    }

    // 4. Vitamin C Analysis
    bool hasSkinOrImmune = answers.symptoms.contains('Dry skin') || answers.symptoms.contains('Frequent illness');
    if (hasSkinOrImmune && answers.dietType != 'Vegan') {
      risks.add(DeficiencyRisk(
        name: 'Vitamin C',
        riskLevel: 'Moderate',
        description: 'Dry skin and susceptibility to frequent illness could point to moderate Vitamin C deficiency, which is essential for collagen and immunity.',
      ));
    } else if (hasSkinOrImmune) {
      risks.add(DeficiencyRisk(
        name: 'Vitamin C',
        riskLevel: 'Low',
        description: 'Low risk. Continue eating fresh fruits and vegetables.',
      ));
    }

    // 5. Calcium Analysis
    bool lowWaterOrSleep = answers.sleepDuration < 6.0 || answers.waterIntake == '< 1 Litre';
    if (answers.symptoms.contains('Bone discomfort') && lowWaterOrSleep) {
      risks.add(DeficiencyRisk(
        name: 'Calcium',
        riskLevel: 'Moderate',
        description: 'Moderate risk of calcium deficiency indicated by bone symptoms and poor sleep/hydration habits which can affect bone mineralization.',
      ));
    }

    // Sort risks: High first, then Moderate, then Low
    risks.sort((a, b) {
      int getPriority(String level) {
        if (level == 'High') return 3;
        if (level == 'Moderate') return 2;
        return 1;
      }
      return getPriority(b.riskLevel).compareTo(getPriority(a.riskLevel));
    });

    return risks;
  }
}

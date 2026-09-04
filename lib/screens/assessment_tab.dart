import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../routes/app_routes.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_button.dart';

class AssessmentTab extends StatelessWidget {
  const AssessmentTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final lastResult = state.lastAssessmentResult;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Health Assessment'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page intro
              const Text(
                'Deficiency Screener',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Answer a few simple questions about your health, food habits, and lifestyle to find possible nutrient gaps.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Last assessment panel
              if (lastResult != null) ...[
                CustomCard(
                  borderColor: AppTheme.primary.withOpacity(0.5),
                  backgroundColor: AppTheme.primaryLight.withOpacity(0.15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Active Health Profile',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(lastResult.dateTime),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Based on your symptoms and lifestyle analysis, we have updated your nutritional risk map.',
                        style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, AppRoutes.assessmentResult);
                            },
                            child: const Text('View Last Results'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, AppRoutes.recommendations);
                            },
                            child: const Text('View Recommendations'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Assessment details timeline / list
              const Text(
                'What does this scan analyze?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 14),

              _buildTimelineStep(
                stepNum: '1',
                title: 'Biometrics & Profile',
                description: 'Basic information like your age, gender, height and weight.',
                icon: Icons.person_outline_rounded,
              ),
              _buildTimelineStep(
                stepNum: '2',
                title: 'Diet & Lifestyle Habits',
                description: 'Diet preferences, water intake, sleep patterns, exercise, and sunlight exposure levels.',
                icon: Icons.wb_sunny_outlined,
              ),
              _buildTimelineStep(
                stepNum: '3',
                title: 'Symptom Log',
                description: 'Common symptoms such as fatigue, hair fall, pale skin, dry skin, and muscle aches.',
                icon: Icons.healing_outlined,
              ),
              _buildTimelineStep(
                stepNum: '4',
                title: 'Verification & Review',
                description: 'A summary screen to verify your answers before submission.',
                icon: Icons.check_circle_outline_rounded,
                isLast: true,
              ),
              const SizedBox(height: 24),

              // Button to trigger fullscreen assessment
              CustomButton(
                text: lastResult != null ? 'Take Assessment Again' : 'Start Assessment',
                onPressed: () {
                  state.clearCurrentAssessment();
                  Navigator.pushNamed(context, AppRoutes.assessmentFlow);
                },
              ),
              const SizedBox(height: 10),
              
              // Disclaimer
              const Center(
                child: Text(
                  'Takes approximately 2 minutes to complete.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineStep({
    required String stepNum,
    required String title,
    required String description,
    required IconData icon,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    stepNum,
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppTheme.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 16, color: AppTheme.textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

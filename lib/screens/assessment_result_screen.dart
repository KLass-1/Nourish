import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../routes/app_routes.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_card.dart';

class AssessmentResultScreen extends StatelessWidget {
  const AssessmentResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final result = state.lastAssessmentResult;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Assessment Result'),
        automaticallyImplyLeading: false, // Prevent swiping back
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Status Info
                    const Text(
                      'Possible Nutritional Concerns',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Based on your reported symptoms and daily lifestyle metrics, the following areas may warrant attention.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Risk Listing
                    if (result == null || result.deficiencies.isEmpty) ...[
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40.0),
                          child: Text(
                            'No current nutritional deficiencies detected.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.success,
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      ...result.deficiencies.map((deficiency) => Padding(
                        padding: const EdgeInsets.only(bottom: 14.0),
                        child: CustomCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      deficiency.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildRiskChip(deficiency.riskLevel),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                deficiency.description,
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                    ],
                    const SizedBox(height: 20),

                    // Medical Disclaimer Block
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.warning.withOpacity(0.3), width: 1.0),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: AppTheme.warning,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Medical Disclaimer',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'This assessment is for general health awareness and does not replace professional medical advice, clinical diagnosis, or laboratory testing.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 1.4,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom Buttons
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  CustomButton(
                    text: 'View Personalized Recommendations',
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, AppRoutes.recommendations);
                    },
                  ),
                  const SizedBox(height: 10),
                  CustomButton(
                    text: 'Return to Dashboard',
                    onPressed: () {
                      // Navigate back to navigation container and clear route stack
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.navigation,
                        (route) => false,
                      );
                    },
                    isSecondary: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskChip(String level) {
    Color chipColor;
    Color textColor;

    switch (level) {
      case 'High':
        chipColor = AppTheme.error.withOpacity(0.1);
        textColor = AppTheme.error;
        break;
      case 'Moderate':
        chipColor = AppTheme.warning.withOpacity(0.15);
        textColor = AppTheme.warning;
        break;
      case 'Low':
      default:
        chipColor = AppTheme.success.withOpacity(0.1);
        textColor = AppTheme.success;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$level Risk',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}

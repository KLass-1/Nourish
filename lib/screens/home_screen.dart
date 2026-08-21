import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../routes/app_routes.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_button.dart';
import '../models/assessment_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final waterIntake = state.currentWaterIntakeMl;
    final waterGoal = state.waterGoalMl;
    final waterProgress = state.waterProgress;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Nourish'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.primaryLight,
              child: Text(
                state.name.isNotEmpty ? state.name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Greeting Section
              Text(
                'Good Morning, ${state.name}',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 6),
              const Text(
                'Let\'s check your wellness indicators today.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              // Main Assessment Card
              CustomCard(
                backgroundColor: AppTheme.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.health_and_safety_rounded,
                            color: AppTheme.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          'How are you feeling today?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Complete our quick 4-step assessment to scan for potential nutritional deficiencies and receive personalized recommendations.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    CustomButton(
                      text: 'Start Deficiency Detection Test',
                      onPressed: () {
                        // Clear previous state and push full screen assessment flow
                        state.clearCurrentAssessment();
                        Navigator.pushNamed(context, AppRoutes.assessmentFlow);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick Overview Title
              const Text(
                'Today\'s Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 12),

              // Quick Overview Grid-like layout
              Row(
                children: [
                  // Water Intake Tracker Card
                  Expanded(
                    child: CustomCard(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.waterTracker);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Water Intake',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Icon(
                                Icons.water_drop_rounded,
                                color: AppTheme.secondary,
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '$waterIntake ml',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            'Goal: $waterGoal ml',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 14),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: waterProgress,
                              minHeight: 6,
                              backgroundColor: AppTheme.border,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppTheme.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Daily Activity Summary Card
                  Expanded(
                    child: CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Sleep & Activity',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Icon(
                                Icons.bedtime_outlined,
                                color: Colors.indigo,
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${state.currentAssessment.sleepDuration.toStringAsFixed(1)} hrs',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const Text(
                            'Sleep duration logged',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              const Icon(
                                Icons.directions_run_rounded,
                                size: 14,
                                color: AppTheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  state.currentAssessment.exerciseFrequency,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Last Assessment Summary Card
              CustomCard(
                onTap: () {
                  if (state.lastAssessmentResult != null) {
                    Navigator.pushNamed(context, AppRoutes.assessmentResult);
                  } else {
                    state.clearCurrentAssessment();
                    Navigator.pushNamed(context, AppRoutes.assessmentFlow);
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Last Deficiency Assessment',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Icon(
                          Icons.assignment_turned_in_rounded,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (state.lastAssessmentResult != null) ...[
                      Row(
                        children: [
                          const Text(
                            'Status: ',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Analyzed',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatDate(state.lastAssessmentResult!.dateTime),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _getDeficiencyOverviewText(state.lastAssessmentResult!),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ] else ...[
                      const Text(
                        'No assessment records completed yet.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Complete your first scan to analyze possible mineral risks.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick Actions List
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuickActionItem(
                    context,
                    label: 'Scan Deficiencies',
                    icon: Icons.biotech_rounded,
                    color: Colors.green,
                    onTap: () {
                      state.clearCurrentAssessment();
                      Navigator.pushNamed(context, AppRoutes.assessmentFlow);
                    },
                  ),
                  _buildQuickActionItem(
                    context,
                    label: 'Water Log',
                    icon: Icons.local_drink_rounded,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.waterTracker);
                    },
                  ),
                  _buildQuickActionItem(
                    context,
                    label: 'Track History',
                    icon: Icons.analytics_rounded,
                    color: Colors.orange,
                    onTap: () {
                      // We can just rely on the bottom navigation tab, or open route. For this prototype, navigating to home and changing standard states works.
                      // Since we are in Home screen inside bottom nav wrapper, we can navigate directly or show a snackbar or trigger route.
                      // Let's make it open recommendations or water tracker. Or just open Recommendations screen if there is a result!
                      if (state.lastAssessmentResult != null) {
                        Navigator.pushNamed(context, AppRoutes.recommendations);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please complete an assessment first to see trends.',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionItem(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _getDeficiencyOverviewText(AssessmentResult result) {
    final highRisks = result.deficiencies
        .where((d) => d.riskLevel == 'High')
        .map((d) => d.name)
        .toList();
    final modRisks = result.deficiencies
        .where((d) => d.riskLevel == 'Moderate')
        .map((d) => d.name)
        .toList();

    if (highRisks.isNotEmpty) {
      return 'High Risk: ${highRisks.join(", ")}';
    } else if (modRisks.isNotEmpty) {
      return 'Moderate Risk: ${modRisks.join(", ")}';
    }
    return 'Low overall deficiency indicators';
  }
}

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../routes/app_routes.dart';
import '../widgets/custom_card.dart';
import '../models/assessment_model.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final history = state.assessmentHistory;
    final todayIntake = state.currentWaterIntakeMl;
    final waterGoal = state.waterGoalMl;

    // Build Mock 7-day Hydration Logs (incorporating actual current today intake)
    final double maxIntake = 3000.0; // ml scale height
    final List<HydrationBarData> weeklyHydration = [
      HydrationBarData(dayLabel: 'M', amountMl: 2100),
      HydrationBarData(dayLabel: 'T', amountMl: 2500),
      HydrationBarData(dayLabel: 'W', amountMl: 1800),
      HydrationBarData(dayLabel: 'T', amountMl: 2650),
      HydrationBarData(dayLabel: 'F', amountMl: 1500),
      HydrationBarData(dayLabel: 'S', amountMl: 2200),
      HydrationBarData(dayLabel: 'Today', amountMl: todayIntake),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Progress & Trends'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: Water Intake Trend Chart
              const Text(
                'Weekly Hydration Trend',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 12),
              
              CustomCard(
                child: Column(
                  children: [
                    // Bar Chart Row
                    SizedBox(
                      height: 140,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: weeklyHydration.map((dayData) {
                          final double percentHeight = (dayData.amountMl / maxIntake).clamp(0.0, 1.0);
                          final isToday = dayData.dayLabel == 'Today';
                          final isGoalMet = dayData.amountMl >= waterGoal;

                          return Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '${dayData.amountMl}',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: isToday ? AppTheme.secondary : AppTheme.textLight,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                // Vertical Bar
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 18,
                                  height: 80 * percentHeight,
                                  decoration: BoxDecoration(
                                    color: isToday
                                        ? AppTheme.secondary
                                        : (isGoalMet ? AppTheme.secondary.withOpacity(0.6) : AppTheme.secondary.withOpacity(0.35)),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    dayData.dayLabel,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                                      color: isToday ? AppTheme.secondary : AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    // Weekly Metrics Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: _buildTrendMetric(label: 'Avg Daily Intake', value: '2,110 ml')),
                        const SizedBox(width: 8),
                        Expanded(child: _buildTrendMetric(label: 'Weekly Goal Met', value: '5 / 7 Days')),
                        const SizedBox(width: 8),
                        Expanded(child: _buildTrendMetric(label: 'Consistency', value: '82%')),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Section 2: Healthy Habit Indicators
              const Text(
                'Habit Indicators',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: CustomCard(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.bedtime_rounded, color: Colors.indigo.shade400, size: 16),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Sleep Quality',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            '7.2 Hrs/day',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                          ),
                          const Text(
                            'Stable average',
                            style: TextStyle(fontSize: 11, color: AppTheme.success, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: CustomCard(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.wb_sunny_rounded, color: Colors.amber, size: 16),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Sunlight Index',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            '25 Mins/day',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                          ),
                          const Text(
                            'Sub-optimal',
                            style: TextStyle(fontSize: 11, color: AppTheme.warning, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Section 3: Assessment History list
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Assessment History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${history.length} scans',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (history.isEmpty) ...[
                CustomCard(
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Text(
                        'No previous assessment records found.',
                        style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                      ),
                    ),
                  ),
                )
              ] else ...[
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final record = history[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: CustomCard(
                        onTap: () {
                          // Allow viewing this historical result
                          state.lastAssessmentResult = record;
                          Navigator.pushNamed(context, AppRoutes.assessmentResult);
                        },
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.assignment_turned_in_rounded, color: AppTheme.primary, size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getHistoryHeadline(record),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    _formatDate(record.dateTime),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textLight,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: AppTheme.textLight),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendMetric({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textLight,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} at ${_formatTime(dt)}';
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour;
    final min = dt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$formattedHour:$min $period';
  }

  String _getHistoryHeadline(AssessmentResult result) {
    final highCount = result.deficiencies.where((d) => d.riskLevel == 'High').length;
    final modCount = result.deficiencies.where((d) => d.riskLevel == 'Moderate').length;

    if (highCount > 0) {
      return '$highCount High concern${highCount > 1 ? "s" : ""} scanned';
    } else if (modCount > 0) {
      return '$modCount Moderate concern${modCount > 1 ? "s" : ""} scanned';
    }
    return 'Optimal nutritional index scanned';
  }
}

class HydrationBarData {
  final String dayLabel;
  final int amountMl;

  HydrationBarData({
    required this.dayLabel,
    required this.amountMl,
  });
}

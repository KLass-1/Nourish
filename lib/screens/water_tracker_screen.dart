import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../widgets/custom_card.dart';

class WaterTrackerScreen extends StatelessWidget {
  const WaterTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final waterIntake = state.currentWaterIntakeMl;
    final waterGoal = state.waterGoalMl;
    final progress = state.waterProgress;

    // Filter logs for today
    final today = DateTime.now();
    final todayLogs = state.waterLogs
        .where((log) =>
            log.dateTime.year == today.year &&
            log.dateTime.month == today.month &&
            log.dateTime.day == today.day)
        .toList()
        .reversed
        .toList(); // Newest first

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Water Tracker'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Visual Circular Water Indicator
                    const SizedBox(height: 16),
                    Center(
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.surface,
                          border: Border.all(color: AppTheme.border, width: 2.0),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.secondary.withOpacity(0.05),
                              blurRadius: 20,
                              spreadRadius: 5,
                            )
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Liquid Circular Progress (Uses Custom Paint or Stacked containers)
                            SizedBox(
                              width: 176,
                              height: 176,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 10,
                                backgroundColor: AppTheme.border,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.secondary),
                              ),
                            ),
                            
                            // Center Content
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.water_drop_rounded,
                                  color: AppTheme.secondary,
                                  size: 40,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$waterIntake',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary,
                                    height: 1.0,
                                  ),
                                ),
                                Text(
                                  '/ $waterGoal ml',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textLight,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${(progress * 100).toInt()}%',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Quick-Add Buttons Row
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Quick Add Log',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildQuickAddButton(context, state, amount: 250, label: '+250 ml'),
                        const SizedBox(width: 10),
                        _buildQuickAddButton(context, state, amount: 500, label: '+500 ml'),
                        const SizedBox(width: 10),
                        _buildQuickAddButton(context, state, amount: 750, label: '+750 ml'),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Today's History Log List
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Today\'s Consumption Log',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${todayLogs.length} logs',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (todayLogs.isEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: Column(
                          children: [
                            Icon(Icons.water_drop_outlined, size: 44, color: AppTheme.textLight.withOpacity(0.5)),
                            const SizedBox(height: 10),
                            const Text(
                              'No water logged yet today.',
                              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      )
                    ] else ...[
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: todayLogs.length,
                        itemBuilder: (context, index) {
                          final log = todayLogs[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: CustomCard(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Color(0xFFE0F2FE), // sky-100
                                    child: Icon(Icons.water_drop_rounded, color: AppTheme.secondary, size: 16),
                                  ),
                                  const SizedBox(width: 14),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${log.amountMl} ml',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        _formatTime(log.dateTime),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textLight,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.error, size: 20),
                                    onPressed: () {
                                      state.removeWaterLog(log.id);
                                    },
                                  ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAddButton(
    BuildContext context,
    AppState state, {
    required int amount,
    required String label,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          state.addWater(amount);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added $amount ml of water.'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_drink_rounded, color: AppTheme.secondary, size: 18),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour;
    final min = dt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$formattedHour:$min $period';
  }
}

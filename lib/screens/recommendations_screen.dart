import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../routes/app_routes.dart';
import '../widgets/custom_button.dart';
import '../data/mock_data.dart';

class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final result = state.lastAssessmentResult;
    
    // Determine active deficiency names that have High or Moderate risk
    final activeDeficiencies = result != null
        ? result.deficiencies
            .where((d) => d.riskLevel == 'High' || d.riskLevel == 'Moderate')
            .map((d) => d.name)
            .toList()
        : <String>[];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Recommendations'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.navigation, (route) => false);
          },
        ),
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
                    // Heading Text
                    const Text(
                      'Your Action Plan',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      activeDeficiencies.isNotEmpty
                          ? 'Guidance tailored to address indicators of ${activeDeficiencies.join(", ")}.'
                          : 'General wellness recommendations to maintain optimal nutrient levels.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 1. Nutrition Suggestions
                    _buildSectionHeader(
                      title: 'Diet & Nutrition',
                      icon: Icons.restaurant_rounded,
                      iconColor: Colors.orange,
                    ),
                    const SizedBox(height: 10),
                    ..._getDietRecommendations(activeDeficiencies).map((rec) => _buildBulletPoint(rec)),
                    const SizedBox(height: 24),

                    // 2. Hydration Guidance
                    _buildSectionHeader(
                      title: 'Hydration Strategy',
                      icon: Icons.local_drink_rounded,
                      iconColor: Colors.blue,
                    ),
                    const SizedBox(height: 10),
                    ..._getHydrationRecommendations(state.waterGoalMl).map((rec) => _buildBulletPoint(rec)),
                    const SizedBox(height: 24),

                    // 3. Lifestyle Advice
                    _buildSectionHeader(
                      title: 'Lifestyle & Habits',
                      icon: Icons.wb_sunny_rounded,
                      iconColor: Colors.amber,
                    ),
                    const SizedBox(height: 10),
                    ..._getLifestyleRecommendations(activeDeficiencies).map((rec) => _buildBulletPoint(rec)),
                    const SizedBox(height: 24),

                    // 4. General Wellness Tips
                    _buildSectionHeader(
                      title: 'Clinical & General Notes',
                      icon: Icons.healing_rounded,
                      iconColor: Colors.red,
                    ),
                    const SizedBox(height: 10),
                    ..._getGeneralRecommendations(activeDeficiencies).map((rec) => _buildBulletPoint(rec)),
                  ],
                ),
              ),
            ),
            
            // Bottom Action
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: CustomButton(
                text: 'Done & Back to Dashboard',
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.navigation, (route) => false);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 6.0, bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6.0),
            child: Icon(
              Icons.circle,
              size: 6,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Recommendation Gatherers
  List<String> _getDietRecommendations(List<String> deficiencies) {
    if (deficiencies.isEmpty) {
      return [
        'Eat a colorful, diverse range of whole fruits, leafy greens, and cruciferous vegetables.',
        'Incorporate clean proteins like nuts, legumes, lean poultry, or dairy products.',
        'Choose whole grains such as oats, brown rice, and quinoa over refined flours.'
      ];
    }
    List<String> recs = [];
    for (var def in deficiencies) {
      if (MockData.recommendations.containsKey(def)) {
        recs.addAll(MockData.recommendations[def]!['diet']!);
      }
    }
    return recs;
  }

  List<String> _getHydrationRecommendations(int waterGoalMl) {
    final double liters = waterGoalMl / 1000.0;
    return [
      'Aim to drink approximately ${liters.toStringAsFixed(1)} litres of water per day based on your profile.',
      'Log water consumption consistently using the Nourish Water Tracker.',
      'Drink a glass of water first thing in the morning to kickstart cellular metabolism.',
      'Avoid high-sugar juices or energy drinks which can lead to metabolic crashes.'
    ];
  }

  List<String> _getLifestyleRecommendations(List<String> deficiencies) {
    List<String> recs = [];
    bool hasD = deficiencies.contains('Vitamin D');
    
    if (hasD) {
      if (MockData.recommendations.containsKey('Vitamin D')) {
        recs.addAll(MockData.recommendations['Vitamin D']!['lifestyle']!);
      }
    }
    
    // Add standard lifestyle tips
    recs.add('Engage in 150 minutes of moderate cardiovascular activity per week.');
    recs.add('Aim for a regular sleeping schedule containing 7 to 8 hours of deep sleep.');
    
    for (var def in deficiencies) {
      if (def != 'Vitamin D' && MockData.recommendations.containsKey(def)) {
        recs.addAll(MockData.recommendations[def]!['lifestyle'] ?? []);
      }
    }
    return recs;
  }

  List<String> _getGeneralRecommendations(List<String> deficiencies) {
    if (deficiencies.isEmpty) {
      return [
        'Maintain an annual preventive health checkup calendar.',
        'Keep track of energy levels, brain focus, and recovery trends.',
        'Use the Nourish screener if symptoms change or return.'
      ];
    }
    List<String> recs = [];
    for (var def in deficiencies) {
      if (MockData.recommendations.containsKey(def)) {
        recs.addAll(MockData.recommendations[def]!['general']!);
      }
    }
    return recs;
  }
}

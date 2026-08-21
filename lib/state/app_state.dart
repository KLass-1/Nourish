import 'package:flutter/material.dart';
import '../models/assessment_model.dart';
import '../models/water_log_model.dart';
import '../data/mock_data.dart';

class AppState extends ChangeNotifier {
  // Profile settings
  String name = 'Piyush';
  int age = 22;
  String gender = 'Male';
  double height = 175.0; // cm
  double weight = 70.0; // kg
  String dietaryPreference = 'Vegetarian';
  
  // App settings
  bool notificationEnabled = true;
  bool weeklyReportEnabled = true;
  bool offlineMode = false;

  // Water Tracker
  int waterGoalMl = 2500;
  final List<WaterLog> _waterLogs = [];
  
  // Assessment
  final AssessmentAnswers currentAssessment = AssessmentAnswers();
  final List<AssessmentResult> _assessmentHistory = [];
  AssessmentResult? lastAssessmentResult;

  AppState() {
    // Populate some initial water logs for today
    final now = DateTime.now();
    _waterLogs.addAll([
      WaterLog(id: '1', amountMl: 250, dateTime: now.subtract(const Duration(hours: 6))),
      WaterLog(id: '2', amountMl: 500, dateTime: now.subtract(const Duration(hours: 4))),
      WaterLog(id: '3', amountMl: 250, dateTime: now.subtract(const Duration(hours: 2))),
    ]);

    // Populate a historical assessment result from 2 weeks ago
    _assessmentHistory.add(
      AssessmentResult(
        dateTime: now.subtract(const Duration(days: 14)),
        deficiencies: [
          DeficiencyRisk(
            name: 'Vitamin D',
            riskLevel: 'Moderate',
            description: 'Moderate risk due to low sun exposure.',
          ),
          DeficiencyRisk(
            name: 'Iron',
            riskLevel: 'Low',
            description: 'Low risk. Baseline dietary absorption is normal.',
          ),
        ],
      ),
    );
  }

  // Getters
  List<WaterLog> get waterLogs => List.unmodifiable(_waterLogs);
  List<AssessmentResult> get assessmentHistory => List.unmodifiable(_assessmentHistory);

  int get currentWaterIntakeMl {
    final today = DateTime.now();
    return _waterLogs
        .where((log) =>
            log.dateTime.year == today.year &&
            log.dateTime.month == today.month &&
            log.dateTime.day == today.day)
        .fold(0, (sum, log) => sum + log.amountMl);
  }

  double get waterProgress {
    if (waterGoalMl <= 0) return 0.0;
    final progress = currentWaterIntakeMl / waterGoalMl;
    return progress > 1.0 ? 1.0 : progress;
  }

  // Water Tracker Actions
  void addWater(int amountMl) {
    _waterLogs.add(WaterLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amountMl: amountMl,
      dateTime: DateTime.now(),
    ));
    notifyListeners();
  }

  void removeWaterLog(String id) {
    _waterLogs.removeWhere((log) => log.id == id);
    notifyListeners();
  }

  void updateWaterGoal(int newGoalMl) {
    waterGoalMl = newGoalMl;
    notifyListeners();
  }

  // Profile Actions
  void updateProfile({
    required String newName,
    required int newAge,
    required String newGender,
    required double newHeight,
    required double newWeight,
    required String newDiet,
  }) {
    name = newName;
    age = newAge;
    gender = newGender;
    height = newHeight;
    weight = newWeight;
    dietaryPreference = newDiet;
    
    // Also keep current assessment model synced with profile defaults
    currentAssessment.age = newAge;
    currentAssessment.gender = newGender;
    currentAssessment.height = newHeight;
    currentAssessment.weight = newWeight;
    currentAssessment.dietType = newDiet;

    notifyListeners();
  }

  void setNotificationsEnabled(bool value) {
    notificationEnabled = value;
    notifyListeners();
  }

  void setWeeklyReportEnabled(bool value) {
    weeklyReportEnabled = value;
    notifyListeners();
  }

  // Assessment Actions
  void submitAssessment() {
    // Calculate risks based on answers
    final risks = MockData.calculateRisks(currentAssessment);
    
    // Create new result
    final result = AssessmentResult(
      dateTime: DateTime.now(),
      deficiencies: risks,
    );

    // Save to history and set as last result
    _assessmentHistory.insert(0, result);
    lastAssessmentResult = result;

    notifyListeners();
  }

  void clearCurrentAssessment() {
    currentAssessment.clear();
    // Sync back with profile details
    currentAssessment.age = age;
    currentAssessment.gender = gender;
    currentAssessment.height = height;
    currentAssessment.weight = weight;
    currentAssessment.dietType = dietaryPreference;
    notifyListeners();
  }
}

// Inherited Widget for Provider-like access without external dependencies
class AppStateProvider extends InheritedNotifier<AppState> {
  const AppStateProvider({
    super.key,
    required AppState super.notifier,
    required super.child,
  });

  static AppState of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AppStateProvider>();
    assert(provider != null, 'No AppStateProvider found in context');
    return provider!.notifier!;
  }
}

import 'package:flutter/material.dart';
import '../models/assessment_model.dart';
import '../models/water_log_model.dart';
import '../data/mock_data.dart';
import '../services/health_check_service.dart';
import '../services/water_storage_service.dart';

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
  final WaterStorageService _waterStorageService;
  int waterGoalMl = 2500;
  final List<WaterLog> _waterLogs = [];
  String _lastKnownDate = WaterStorageService.todayDateString;
  
  // Assessment
  final AssessmentAnswers currentAssessment = AssessmentAnswers();
  final List<AssessmentResult> _assessmentHistory = [];
  AssessmentResult? lastAssessmentResult;

  AppState({WaterStorageService? storageService, bool loadPersistedData = true})
      : _waterStorageService = storageService ?? WaterStorageService() {
    // Populate a historical assessment result from 2 weeks ago
    final now = DateTime.now();
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

    if (loadPersistedData) {
      loadSavedData();
    }
  }

  /// Loads persisted water logs and goal from SharedPreferences
  Future<void> loadSavedData() async {
    try {
      final logs = await _waterStorageService.loadTodayWaterLogs();
      _waterLogs.clear();
      _waterLogs.addAll(logs);
      waterGoalMl = await _waterStorageService.loadWaterGoal();
      _lastKnownDate = WaterStorageService.todayDateString;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading water data in AppState: $e');
    }
  }

  /// Checks if the day has changed while the app was running and resets if so
  void _checkDailyReset() {
    final today = WaterStorageService.todayDateString;
    if (_lastKnownDate != today) {
      _lastKnownDate = today;
      _waterLogs.clear();
      _waterStorageService.resetToday();
    }
  }

  // Getters
  List<WaterLog> get waterLogs {
    _checkDailyReset();
    return List.unmodifiable(_waterLogs);
  }

  List<AssessmentResult> get assessmentHistory => List.unmodifiable(_assessmentHistory);

  /// Current today's water intake in ml
  int get currentWaterIntakeMl {
    _checkDailyReset();
    final today = DateTime.now();
    return _waterLogs
        .where((log) =>
            log.dateTime.year == today.year &&
            log.dateTime.month == today.month &&
            log.dateTime.day == today.day)
        .fold(0, (sum, log) => sum + log.amountMl);
  }

  /// Clamped progress (0.0 to 1.0) for visual progress bars
  double get waterProgress {
    if (waterGoalMl <= 0) return 0.0;
    final progress = currentWaterIntakeMl / waterGoalMl;
    return progress > 1.0 ? 1.0 : (progress < 0.0 ? 0.0 : progress);
  }

  /// Unclamped progress for calculating accurate percentage (e.g. 108% if exceeding goal)
  double get rawWaterProgress {
    if (waterGoalMl <= 0) return 0.0;
    return currentWaterIntakeMl / waterGoalMl;
  }

  int _logCounter = 0;

  // Water Tracker Actions
  void addWater(int amountMl) {
    if (amountMl <= 0) return; // Prevent zero or negative intake
    _checkDailyReset();

    final newLog = WaterLog(
      id: '${DateTime.now().microsecondsSinceEpoch}_${_logCounter++}',
      amountMl: amountMl,
      dateTime: DateTime.now(),
    );
    _waterLogs.add(newLog);
    _waterStorageService.saveTodayWaterLogs(_waterLogs);
    notifyListeners();
  }

  void removeWaterLog(String id) {
    _waterLogs.removeWhere((log) => log.id == id);
    _waterStorageService.saveTodayWaterLogs(_waterLogs);
    notifyListeners();
  }

  void resetTodayWater() {
    _waterLogs.clear();
    _waterStorageService.resetToday();
    notifyListeners();
  }

  void updateWaterGoal(int newGoalMl) {
    if (newGoalMl <= 0) return; // Guard against non-positive goals
    waterGoalMl = newGoalMl;
    _waterStorageService.saveWaterGoal(newGoalMl);
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
  Future<void> submitAssessmentAsync({HealthCheckService? service}) async {
    final healthService = service ?? HealthCheckService();
    final risks = await healthService.analyzeHealth(currentAssessment);

    final result = AssessmentResult(
      dateTime: DateTime.now(),
      deficiencies: risks,
    );

    _assessmentHistory.insert(0, result);
    lastAssessmentResult = result;
    notifyListeners();
  }

  void submitAssessment() {
    // Offline / fallback calculation based on answers
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

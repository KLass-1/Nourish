import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/water_log_model.dart';

/// Service responsible for persisting and retrieving daily water tracker data
/// using local SharedPreferences storage.
/// 
/// Supports:
/// 1. Saving & restoring today's water consumption logs
/// 2. Automatic daily reset: detects if the saved date != today, resetting intake to 0
/// 3. Saving & restoring daily water goal
/// 4. Explicit manual reset of today's logs
class WaterStorageService {
  static const String _keyWaterDate = 'water_tracker_date';
  static const String _keyWaterLogs = 'water_tracker_logs';
  static const String _keyWaterGoal = 'water_tracker_goal';

  /// Helper to get today's date formatted as YYYY-MM-DD
  static String get todayDateString {
    final now = DateTime.now();
    final year = now.year.toString().padLeft(4, '0');
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Loads today's water logs from SharedPreferences.
  /// 
  /// If no data exists, or if the stored date is from a previous day,
  /// the method automatically marks today as the active date, clears previous logs,
  /// and returns an empty list so the new day starts from 0 ml.
  Future<List<WaterLog>> loadTodayWaterLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedDate = prefs.getString(_keyWaterDate);
      final today = todayDateString;

      // Check if a new day has arrived (or first run)
      if (savedDate == null || savedDate != today) {
        debugPrint('Water tracker: New day detected ($today vs $savedDate). Resetting logs to 0.');
        await prefs.setString(_keyWaterDate, today);
        await prefs.remove(_keyWaterLogs);
        return [];
      }

      final logsJson = prefs.getString(_keyWaterLogs);
      if (logsJson == null || logsJson.isEmpty) {
        return [];
      }

      final List<dynamic> decoded = jsonDecode(logsJson) as List<dynamic>;
      return decoded
          .map((item) => WaterLog.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading water logs from storage: $e');
      return [];
    }
  }

  /// Persists today's list of water logs to SharedPreferences as a JSON string.
  Future<void> saveTodayWaterLogs(List<WaterLog> logs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = todayDateString;
      
      // Ensure date key is updated to today
      await prefs.setString(_keyWaterDate, today);

      final encoded = jsonEncode(logs.map((log) => log.toJson()).toList());
      await prefs.setString(_keyWaterLogs, encoded);
    } catch (e) {
      debugPrint('Error saving water logs to storage: $e');
    }
  }

  /// Loads the stored water goal (defaults to 2500 ml if not set).
  Future<int> loadWaterGoal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyWaterGoal) ?? 2500;
    } catch (e) {
      return 2500;
    }
  }

  /// Persists the user's daily water goal.
  Future<void> saveWaterGoal(int goalMl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyWaterGoal, goalMl);
    } catch (e) {
      debugPrint('Error saving water goal: $e');
    }
  }

  /// Clears today's water logs from storage (resets back to 0 ml).
  Future<void> resetToday() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = todayDateString;
      await prefs.setString(_keyWaterDate, today);
      await prefs.remove(_keyWaterLogs);
    } catch (e) {
      debugPrint('Error resetting water logs: $e');
    }
  }
}

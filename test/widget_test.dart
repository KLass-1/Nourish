import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nourish/state/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AppState Water Tracker Unit Tests', () {
    test('initial state starts with zero water intake on a fresh day', () {
      final state = AppState(loadPersistedData: false);
      expect(state.currentWaterIntakeMl, 0);
      expect(state.waterProgress, 0.0);
      expect(state.waterGoalMl, 2500);
      expect(state.waterLogs.isEmpty, isTrue);
    });

    test('adding water updates current intake and progress dynamically', () {
      final state = AppState(loadPersistedData: false);
      state.addWater(250);
      expect(state.currentWaterIntakeMl, 250);
      expect(state.waterProgress, 0.1); // 250 / 2500

      state.addWater(500);
      expect(state.currentWaterIntakeMl, 750);
      expect(state.waterProgress, 0.3); // 750 / 2500
    });

    test('non-positive water intake is rejected and does not alter logs', () {
      final state = AppState(loadPersistedData: false);
      state.addWater(250);
      expect(state.currentWaterIntakeMl, 250);

      // Attempt negative or zero additions
      state.addWater(0);
      state.addWater(-250);
      expect(state.currentWaterIntakeMl, 250);
      expect(state.waterLogs.length, 1);
    });

    test('intake exceeding target remains uncapped while visual progress clamps to 1.0', () {
      final state = AppState(loadPersistedData: false);
      state.addWater(2700);

      // Raw intake is preserved without capping
      expect(state.currentWaterIntakeMl, 2700);
      // Raw progress is 1.08 (108%)
      expect(state.rawWaterProgress, closeTo(1.08, 0.001));
      // Visual progress bar value is clamped to 1.0
      expect(state.waterProgress, 1.0);
    });

    test('updating water goal alters progress calculations dynamically', () {
      final state = AppState(loadPersistedData: false);
      state.addWater(1000);
      expect(state.waterProgress, 0.4); // 1000 / 2500

      state.updateWaterGoal(2000);
      expect(state.waterGoalMl, 2000);
      expect(state.waterProgress, 0.5); // 1000 / 2000
    });

    test('removing water log decreases hydration level', () {
      final state = AppState(loadPersistedData: false);
      state.addWater(500);
      state.addWater(250);
      expect(state.currentWaterIntakeMl, 750);

      final lastLogId = state.waterLogs.last.id;
      state.removeWaterLog(lastLogId);

      expect(state.currentWaterIntakeMl, 500);
      expect(state.waterLogs.length, 1);
    });

    test('resetting water intake restores zero level', () {
      final state = AppState(loadPersistedData: false);
      state.addWater(500);
      state.addWater(250);
      expect(state.currentWaterIntakeMl, 750);

      state.resetTodayWater();
      expect(state.currentWaterIntakeMl, 0);
      expect(state.waterProgress, 0.0);
      expect(state.waterLogs.isEmpty, isTrue);
    });
  });
}

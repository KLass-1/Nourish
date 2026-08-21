import 'package:flutter_test/flutter_test.dart';
import 'package:nourish/state/app_state.dart';

void main() {
  group('AppState Hydration Unit Tests', () {
    test('initial state has pre-populated water intake', () {
      final state = AppState();
      // Pre-populated water logs should sum to 1000 ml
      expect(state.currentWaterIntakeMl, 1000);
      expect(state.waterProgress, 0.4); // 1000 / 2500
    });

    test('adding water updates current intake and progress', () {
      final state = AppState();
      state.addWater(500);
      
      expect(state.currentWaterIntakeMl, 1500);
      expect(state.waterProgress, 0.6); // 1500 / 2500
    });

    test('updating water goal alters progress calculations', () {
      final state = AppState();
      state.updateWaterGoal(2000);
      
      expect(state.waterProgress, 0.5); // 1000 / 2000
    });

    test('removing water log decreases hydration level', () {
      final state = AppState();
      final lastLogId = state.waterLogs.last.id;
      
      state.removeWaterLog(lastLogId);
      
      // Last pre-populated log was 250ml. 1000 - 250 = 750ml.
      expect(state.currentWaterIntakeMl, 750);
    });
  });
}

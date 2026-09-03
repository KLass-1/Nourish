import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nourish/theme/app_theme.dart';
import 'package:nourish/state/app_state.dart';
import 'package:nourish/screens/assessment_flow_screen.dart';
import 'package:nourish/screens/assessment_result_screen.dart';
import 'package:nourish/routes/app_routes.dart';

void main() {
  testWidgets('AssessmentFlow 4-step full navigation test with zero overflows', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final appState = AppState();

    await tester.pumpWidget(
      AppStateProvider(
        notifier: appState,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AssessmentFlowScreen(),
          onGenerateRoute: (settings) {
            if (settings.name == AppRoutes.assessmentResult) {
              return MaterialPageRoute(
                builder: (_) => const AssessmentResultScreen(),
              );
            }
            return null;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Step 1: Basic Information
    expect(find.text('Tell us about yourself'), findsOneWidget);
    expect(find.text('Step 1 of 4'), findsOneWidget);

    // Tap 'Next Step'
    await tester.tap(find.text('Next Step'));
    await tester.pumpAndSettle();

    // Step 2: Diet & Lifestyle
    expect(find.text('Diet & Lifestyle habits'), findsOneWidget);
    expect(find.text('Step 2 of 4'), findsOneWidget);

    // Tap 'Next Step'
    await tester.tap(find.text('Next Step'));
    await tester.pumpAndSettle();

    // Step 3: Symptoms
    expect(find.text('Symptom Check'), findsOneWidget);
    expect(find.text('Step 3 of 4'), findsOneWidget);

    // Tap a symptom
    await tester.tap(find.text('Fatigue').first);
    await tester.pumpAndSettle();

    // Tap 'Next Step'
    await tester.tap(find.text('Next Step'));
    await tester.pumpAndSettle();

    // Step 4: Review
    expect(find.text('Review assessment details'), findsOneWidget);
    expect(find.text('Step 4 of 4'), findsOneWidget);
    expect(find.text('Submit Assessment'), findsOneWidget);

    // Tap 'Submit Assessment'
    await tester.tap(find.text('Submit Assessment'));
    await tester.pumpAndSettle();

    // Should navigate to Assessment Result Screen
    expect(find.text('Possible Nutritional Concerns'), findsOneWidget);
  });
}

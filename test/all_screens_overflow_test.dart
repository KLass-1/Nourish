import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nourish/theme/app_theme.dart';
import 'package:nourish/state/app_state.dart';
import 'package:nourish/screens/home_screen.dart';
import 'package:nourish/screens/onboarding_screen.dart';
import 'package:nourish/screens/assessment_tab.dart';
import 'package:nourish/screens/assessment_flow_screen.dart';
import 'package:nourish/screens/assessment_result_screen.dart';
import 'package:nourish/screens/progress_screen.dart';
import 'package:nourish/screens/profile_screen.dart';
import 'package:nourish/screens/recommendations_screen.dart';
import 'package:nourish/screens/water_tracker_screen.dart';

Widget buildTestableWidget(Widget widget, [AppState? state]) {
  final appState = state ?? AppState();
  if (state == null) {
    appState.submitAssessment();
  }
  return AppStateProvider(
    notifier: appState,
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: widget,
    ),
  );
}

void main() {
  const sizes = [
    Size(320, 568),
    Size(360, 640),
    Size(392, 825),
    Size(412, 915),
  ];

  for (final size in sizes) {
    group('Screen size: ${size.width}x${size.height}', () {
      testWidgets('HomeScreen', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestableWidget(const HomeScreen()));
        await tester.pumpAndSettle();
      });

      testWidgets('OnboardingScreen', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestableWidget(const OnboardingScreen()));
        await tester.pumpAndSettle();
      });

      testWidgets('AssessmentTab', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestableWidget(const AssessmentTab()));
        await tester.pumpAndSettle();
      });

      testWidgets('AssessmentFlowScreen Step 1', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestableWidget(const AssessmentFlowScreen()));
        await tester.pumpAndSettle();
      });

      testWidgets('AssessmentResultScreen', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestableWidget(const AssessmentResultScreen()));
        await tester.pumpAndSettle();
      });

      testWidgets('RecommendationsScreen', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestableWidget(const RecommendationsScreen()));
        await tester.pumpAndSettle();
      });

      testWidgets('ProgressScreen', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestableWidget(const ProgressScreen()));
        await tester.pumpAndSettle();
      });

      testWidgets('ProfileScreen', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestableWidget(const ProfileScreen()));
        await tester.pumpAndSettle();
      });

      testWidgets('WaterTrackerScreen', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestableWidget(const WaterTrackerScreen()));
        await tester.pumpAndSettle();
      });
    });
  }
}

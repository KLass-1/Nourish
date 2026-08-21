import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/assessment_flow_screen.dart';
import '../screens/assessment_result_screen.dart';
import '../screens/recommendations_screen.dart';
import '../screens/water_tracker_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String navigation = '/navigation';
  static const String assessmentFlow = '/assessment-flow';
  static const String assessmentResult = '/assessment-result';
  static const String recommendations = '/recommendations';
  static const String waterTracker = '/water-tracker';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      onboarding: (context) => const OnboardingScreen(),
      navigation: (context) => const MainNavigationScreen(),
      assessmentFlow: (context) => const AssessmentFlowScreen(),
      assessmentResult: (context) => const AssessmentResultScreen(),
      recommendations: (context) => const RecommendationsScreen(),
      waterTracker: (context) => const WaterTrackerScreen(),
    };
  }
}

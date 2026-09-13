import 'package:flutter_test/flutter_test.dart';
import 'package:nourish/models/assessment_model.dart';
import 'package:nourish/services/health_check_service.dart';

void main() {
  group('HealthCheckService & Models Tests', () {
    test('AssessmentAnswers serializes to JSON map correctly', () {
      final answers = AssessmentAnswers(
        age: 24,
        gender: 'Female',
        height: 165.0,
        weight: 58.0,
        dietType: 'Vegetarian',
        waterIntake: '2-3 Litres',
        sleepDuration: 8.0,
        exerciseFrequency: '3-4 times/week',
        sunlightExposure: '30-60 mins',
        symptoms: ['Fatigue', 'Hair fall'],
      );

      final json = answers.toJson();
      expect(json['age'], 24);
      expect(json['gender'], 'Female');
      expect(json['height'], 165.0);
      expect(json['weight'], 58.0);
      expect(json['dietType'], 'Vegetarian');
      expect(json['waterIntake'], '2-3 Litres');
      expect(json['sleepDuration'], 8.0);
      expect(json['exerciseFrequency'], '3-4 times/week');
      expect(json['sunlightExposure'], '30-60 mins');
      expect(json['symptoms'], ['Fatigue', 'Hair fall']);
    });

    test('DeficiencyRisk parses JSON from Gemini API schema correctly', () {
      final geminiItem = {
        'nutrient': 'Vitamin B12',
        'risk': 'Moderate',
        'reason': 'Plant-based diet with limited dairy may lead to reduced cobalamin intake.',
        'suggestions': [
          'Incorporate fortified plant milks or nutritional yeast.',
          'Consider routine B12 monitoring.',
        ],
      };

      final risk = DeficiencyRisk.fromJson(geminiItem);
      expect(risk.name, 'Vitamin B12');
      expect(risk.riskLevel, 'Moderate');
      expect(risk.description, contains('Plant-based'));
      expect(risk.suggestions.length, 2);
      expect(risk.suggestions.first, contains('fortified'));
    });

    test('DeficiencyRisk parses legacy schema with default empty suggestions', () {
      final legacyItem = {
        'name': 'Iron',
        'riskLevel': 'High',
        'description': 'Frequent fatigue and pale skin reported.',
      };

      final risk = DeficiencyRisk.fromJson(legacyItem);
      expect(risk.name, 'Iron');
      expect(risk.riskLevel, 'High');
      expect(risk.description, 'Frequent fatigue and pale skin reported.');
      expect(risk.suggestions, isEmpty);
    });

    test('HealthCheckService provides correct platform base URL', () {
      expect(HealthCheckService.defaultBaseUrl, isNotEmpty);
      expect(HealthCheckService.defaultBaseUrl.startsWith('http'), isTrue);
    });
  });
}

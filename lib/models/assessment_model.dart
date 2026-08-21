class AssessmentAnswers {
  int age;
  String gender;
  double height; // in cm
  double weight; // in kg
  String dietType;
  String waterIntake;
  double sleepDuration; // in hours
  String exerciseFrequency;
  String sunlightExposure;
  List<String> symptoms;

  AssessmentAnswers({
    this.age = 22,
    this.gender = 'Male',
    this.height = 175.0,
    this.weight = 70.0,
    this.dietType = 'Vegetarian',
    this.waterIntake = '1-2 Litres',
    this.sleepDuration = 7.0,
    this.exerciseFrequency = '1-2 times/week',
    this.sunlightExposure = '15-30 mins',
    List<String>? symptoms,
  }) : symptoms = symptoms ?? [];

  AssessmentAnswers copyWith({
    int? age,
    String? gender,
    double? height,
    double? weight,
    String? dietType,
    String? waterIntake,
    double? sleepDuration,
    String? exerciseFrequency,
    String? sunlightExposure,
    List<String>? symptoms,
  }) {
    return AssessmentAnswers(
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      dietType: dietType ?? this.dietType,
      waterIntake: waterIntake ?? this.waterIntake,
      sleepDuration: sleepDuration ?? this.sleepDuration,
      exerciseFrequency: exerciseFrequency ?? this.exerciseFrequency,
      sunlightExposure: sunlightExposure ?? this.sunlightExposure,
      symptoms: symptoms ?? List.from(this.symptoms),
    );
  }

  void clear() {
    age = 22;
    gender = 'Male';
    height = 175.0;
    weight = 70.0;
    dietType = 'Vegetarian';
    waterIntake = '1-2 Litres';
    sleepDuration = 7.0;
    exerciseFrequency = '1-2 times/week';
    sunlightExposure = '15-30 mins';
    symptoms.clear();
  }
}

class DeficiencyRisk {
  final String name;
  final String riskLevel; // 'High', 'Moderate', 'Low'
  final String description;

  DeficiencyRisk({
    required this.name,
    required this.riskLevel,
    required this.description,
  });
}

class AssessmentResult {
  final DateTime dateTime;
  final List<DeficiencyRisk> deficiencies;

  AssessmentResult({
    required this.dateTime,
    required this.deficiencies,
  });
}

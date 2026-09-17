class WaterLog {
  final String id;
  final int amountMl;
  final DateTime dateTime;

  WaterLog({
    required this.id,
    required this.amountMl,
    required this.dateTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amountMl': amountMl,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  factory WaterLog.fromJson(Map<String, dynamic> json) {
    return WaterLog(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      amountMl: (json['amountMl'] as num?)?.toInt() ?? 0,
      dateTime: json['dateTime'] != null
          ? DateTime.tryParse(json['dateTime'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

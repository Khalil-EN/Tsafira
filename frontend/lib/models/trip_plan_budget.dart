class TripPlanBudget {
  final double totalBudget;
  final double totalSpent;
  final double remainingBudget;
  final double overBudget;
  final bool withinBudget;
  final Map<String, dynamic> allocated;
  final Map<String, dynamic> spent;
  final List<String> warnings;

  const TripPlanBudget({
    required this.totalBudget,
    required this.totalSpent,
    required this.remainingBudget,
    required this.overBudget,
    required this.withinBudget,
    required this.allocated,
    required this.spent,
    required this.warnings,
  });

  factory TripPlanBudget.fromJson(Map<String, dynamic> json) {
    return TripPlanBudget(
      totalBudget: _num(json['totalBudget']),
      totalSpent: _num(json['totalSpent']),
      remainingBudget: _num(json['remainingBudget']),
      overBudget: _num(json['overBudget']),
      withinBudget: json['withinBudget'] == true,
      allocated: json['allocated'] is Map ? Map<String, dynamic>.from(json['allocated']) : {},
      spent: json['spent'] is Map ? Map<String, dynamic>.from(json['spent']) : {},
      warnings: json['warnings'] is List
          ? (json['warnings'] as List).map((w) => w.toString().trim()).where((w) => w.isNotEmpty).toList()
          : [],
    );
  }

  bool get isOverBudget => !withinBudget || remainingBudget < 0 || overBudget > 0;

  static double _num(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
class DashboardModel {
  final String lastActivity;
  final String mostFrequentVariety;
  final Map<String, double> precisionPerVariety;
  final int totalAnalyses;
  final int varietiesCount;
  final Map<String, int> varietyDistribution;
  final Map<String, int> weeklyActivity;

  DashboardModel({
    required this.lastActivity,
    required this.mostFrequentVariety,
    required this.precisionPerVariety,
    required this.totalAnalyses,
    required this.varietiesCount,
    required this.varietyDistribution,
    required this.weeklyActivity,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      lastActivity: json['last_activity'] ?? '',
      mostFrequentVariety: json['most_frequent_variety'] ?? '',
      precisionPerVariety: Map<String, double>.from(json['precision_per_variety'] ?? {}),
      totalAnalyses: json['total_analyses'] ?? 0,
      varietiesCount: json['varieties_count'] ?? 0,
      varietyDistribution: Map<String, int>.from(json['variety_distribution'] ?? {}),
      weeklyActivity: Map<String, int>.from(json['weekly_activity'] ?? {}),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'last_activity': lastActivity,
      'most_frequent_variety': mostFrequentVariety,
      'precision_per_variety': precisionPerVariety,
      'total_analyses': totalAnalyses,
      'varieties_count': varietiesCount,
      'variety_distribution': varietyDistribution,
      'weekly_activity': weeklyActivity,
    };
  }
}

class RiderDashboard {
  final int activeDeliveries;
  final int completedDeliveriesToday;
  final int completedDeliveriesWeek;
  final int completedDeliveriesMonth;
  final double totalEarningsToday;
  final double totalEarningsWeek;
  final double totalEarningsMonth;
  final double averageRating; // e.g., 4.5
  final int totalReviews;

  RiderDashboard({
    required this.activeDeliveries,
    required this.completedDeliveriesToday,
    required this.completedDeliveriesWeek,
    required this.completedDeliveriesMonth,
    required this.totalEarningsToday,
    required this.totalEarningsWeek,
    required this.totalEarningsMonth,
    required this.averageRating,
    required this.totalReviews,
  });

  factory RiderDashboard.fromJson(Map<String, dynamic> json) {
    return RiderDashboard(
      activeDeliveries: json['active_deliveries'] ?? 0,
      completedDeliveriesToday: json['completed_deliveries_today'] ?? 0,
      completedDeliveriesWeek: json['completed_deliveries_week'] ?? 0,
      completedDeliveriesMonth: json['completed_deliveries_month'] ?? 0,
      totalEarningsToday: (json['total_earnings_today'] ?? 0.0).toDouble(),
      totalEarningsWeek: (json['total_earnings_week'] ?? 0.0).toDouble(),
      totalEarningsMonth: (json['total_earnings_month'] ?? 0.0).toDouble(),
      averageRating: (json['average_rating'] ?? 0.0).toDouble(),
      totalReviews: json['total_reviews'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'active_deliveries': activeDeliveries,
      'completed_deliveries_today': completedDeliveriesToday,
      'completed_deliveries_week': completedDeliveriesWeek,
      'completed_deliveries_month': completedDeliveriesMonth,
      'total_earnings_today': totalEarningsToday,
      'total_earnings_week': totalEarningsWeek,
      'total_earnings_month': totalEarningsMonth,
      'average_rating': averageRating,
      'total_reviews': totalReviews,
    };
  }
}

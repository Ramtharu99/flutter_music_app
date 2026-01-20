class Purchase {
  final int id;
  final int userId;
  final int musicId;
  final String transactionId;
  final double amount;
  final DateTime purchaseDate;

  Purchase({
    required this.id,
    required this.userId,
    required this.musicId,
    required this.transactionId,
    required this.amount,
    required this.purchaseDate,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      musicId: json['musicId'] as int? ?? 0,
      transactionId: json['transactionId'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      purchaseDate: json['purchaseDate'] != null
          ? DateTime.parse(json['purchaseDate'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'musicId': musicId,
      'transactionId': transactionId,
      'amount': amount,
      'purchaseDate': purchaseDate.toIso8601String(),
    };
  }
}

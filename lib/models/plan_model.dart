// models/plan_model.dart

class PlanModel {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String price;
  final String formattedPrice;
  final String billingPeriod;
  final String billingPeriodText;
  final List<String> features;
  final int trialDays;
  final bool isFeatured;
  final String? stripePriceId;
  final String? stripeProductId;
  final DateTime? createdAt;

  PlanModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.price,
    required this.formattedPrice,
    required this.billingPeriod,
    required this.billingPeriodText,
    required this.features,
    required this.trialDays,
    required this.isFeatured,
    this.stripePriceId,
    this.stripeProductId,
    this.createdAt,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      price: json['price'],
      formattedPrice: json['formatted_price'],
      billingPeriod: json['billing_period'],
      billingPeriodText: json['billing_period_text'],
      features: List<String>.from(json['features']),
      trialDays: json['trial_days'],
      isFeatured: json['is_featured'] ?? false,
      stripePriceId: json['stripe_price_id'],
      stripeProductId: json['stripe_product_id'],
      createdAt: DateTime.tryParse(json['created_at'] ?? ''),
    );
  }
}

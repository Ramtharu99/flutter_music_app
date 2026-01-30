import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:music_app/core/api/api.dart';

final GetStorage _storage = GetStorage();
final token = _storage.read('auth_token');

class PaymentService {
  static Future<Map<String, dynamic>?> createPaymentIntent({
    required String type,
    required int itemId,
    required double amount,
  }) async {
    debugPrint('token: $token');
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.paymentIntent}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'type': type, 'item_id': itemId, 'amount': amount}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body)['data'];
        return Map<String, dynamic>.from(jsonResponse);
      } else {
        debugPrint(
          'Create PaymentIntent error: ${response.statusCode} -> ${response.body}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('Exception creating PaymentIntent: $e');
      return null;
    }
  }

  /// Confirm payment via backend
  static Future<bool> confirmPayment({
    required String paymentIntentId,
    required String type,
    required int itemId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.paymentConfirmation}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'payment_intent_id': paymentIntentId,
          'type': type,
          'item_id': itemId,
        }),
      );

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        return res['success'] ?? false;
      } else {
        debugPrint('Confirm payment error: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Exception confirming payment: $e');
      return false;
    }
  }

  /// Show Stripe Payment Sheet
  static Future<bool> showPaymentSheet({
    required BuildContext context,
    required String clientSecret,
    String merchantName = 'Navakarna',
  }) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: merchantName,
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      return true;
    } on StripeException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Payment failed: ${e.error.localizedMessage}'),
          ),
        );
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Payment error: $e')));
      }
      return false;
    }
  }
}

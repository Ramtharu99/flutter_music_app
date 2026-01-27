import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class PaymentService {
  static final _testSecretToken = dotenv.get('STRIPE_SECRET_KEY');

  static Future<String?> createTestPaymentIntent({
    required int amount,
    String currency = 'USD',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $_testSecretToken',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amount.toString(),
          'currency': currency,
          'automatic_payment_methods[enabled]': 'true',
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['client_secret'] as String?;
      } else {
        debugPrint('Stripe error : ${response.statusCode} -> ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Exception creating paymentIntent: $e');
      return null;
    }
  }

  static Future<void> showPaymentSheet({
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment successful (test mode)')),
        );
      }
    } on StripeException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${e.error.localizedMessage}'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}

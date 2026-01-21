import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class PaymentService {
  // Replace this with a fresh test PaymentIntent client secret from Stripe Dashboard
  static const String testClientSecret =
      "pi_3N7G4hJkLmnO_secret_KlMnvb..."; // TEMPORARY test secret

  static Future<bool> testPayment() async {
    try {
      // Initialize PaymentSheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: testClientSecret,
          merchantDisplayName: 'Navakarna',
        ),
      );

      // Present PaymentSheet
      await Stripe.instance.presentPaymentSheet();
      debugPrint('✅ Test payment success');
      return true;
    } on StripeException catch (e) {
      debugPrint('❌ Stripe error: ${e.error.localizedMessage}');
      return false;
    } catch (e) {
      debugPrint('❌ Payment failed: $e');
      return false;
    }
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:hawiisaac/core/config/stripe_config.dart';

class PremiumStripeService {
  const PremiumStripeService();

  Future<void> startPaymentSheet({
    required String planTitle,
    required int amountMinor,
    required String currency,
    required bool isDarkMode,
  }) async {
    if (!kDebugMode) {
      throw Exception(
        'Direct Stripe secret key flow sudhu debug mode-er jonno rakha hoyeche.',
      );
    }

    debugPrint(
      '[Stripe] Starting PaymentSheet for $planTitle, amount=$amountMinor, currency=$currency',
    );

    final clientSecret = await _createPaymentIntent(
      amountMinor: amountMinor,
      currency: currency,
      description: 'HYKX Premium $planTitle',
    );

    debugPrint('[Stripe] PaymentIntent client secret created');

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        merchantDisplayName: StripeConfig.merchantDisplayName,
        paymentIntentClientSecret: clientSecret,
        style: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      ),
    );

    debugPrint('[Stripe] PaymentSheet initialized');
    await Stripe.instance.presentPaymentSheet();
    debugPrint('[Stripe] PaymentSheet completed successfully');
  }

  Future<String> _createPaymentIntent({
    required int amountMinor,
    required String currency,
    required String description,
  }) async {
    final client = HttpClient();

    try {
      final request = await client.postUrl(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
      );
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer ${StripeConfig.secretKey}',
      );
      request.headers.set(
        HttpHeaders.contentTypeHeader,
        'application/x-www-form-urlencoded',
      );

      final body = <String, String>{
        'amount': amountMinor.toString(),
        'currency': currency,
        'description': description,
        'automatic_payment_methods[enabled]': 'true',
        'automatic_payment_methods[allow_redirects]': 'never',
      };

      final encodedBody = body.entries
          .map(
            (entry) => '${entry.key}=${Uri.encodeQueryComponent(entry.value)}',
          )
          .join('&');

      debugPrint('[Stripe] Creating PaymentIntent with body: $body');
      request.add(utf8.encode(encodedBody));

      final response = await request.close();
      final responseText = await response.transform(utf8.decoder).join();

      debugPrint(
        '[Stripe] PaymentIntent response status: ${response.statusCode}',
      );
      debugPrint('[Stripe] PaymentIntent response body: $responseText');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Stripe PaymentIntent create failed: $responseText');
      }

      final data = jsonDecode(responseText) as Map<String, dynamic>;
      final clientSecret = data['client_secret']?.toString() ?? '';
      if (clientSecret.isEmpty) {
        throw Exception('Stripe client_secret missing from response.');
      }

      return clientSecret;
    } finally {
      client.close(force: true);
    }
  }
}

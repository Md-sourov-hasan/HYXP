import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/features/profile/services/premium_stripe_service.dart';

class PremiumController extends GetxController {
  PremiumController({PremiumStripeService? stripeService})
    : _stripeService = stripeService ?? const PremiumStripeService();

  // ─── Header ──────────────────────────────────────────────────────
  final String appName = 'HYKX';
  final String tagLabel = 'Pro';
  final String headline = 'Get full access to HYKX';
  final RxBool isLoading = false.obs;
  final PremiumStripeService _stripeService;

  // ─── Feature List ────────────────────────────────────────────────
  final List<String> features = [
    'Unlimited Routines',
    '100+ machines',
    'Details Instruction, tips',
    'Advanced progress tracking',
    'Advanced analytics',
  ];

  // ─── Plans ───────────────────────────────────────────────────────
  final RxInt selectedPlanIndex = 1.obs; // 0 = Monthly, 1 = Yearly (default)

  final List<Map<String, String>> plans = [
    {
      'label': 'Pro',
      'title': 'Monthly',
      'amount_minor': '499',
      'currency_code': 'eur',
      'price': '4.99',
      'currency': '€',
      'billing': 'Billed monthly',
      'badge': 'Save 10%',
    },
    {
      'label': 'Pro',
      'title': 'Yearly',
      'amount_minor': '2499',
      'currency_code': 'eur',
      'price': '24.99',
      'currency': '€',
      'billing': 'Billed Yearly',
      'badge': 'Save 35%',
    },
  ];

  void selectPlan(int index) {
    selectedPlanIndex.value = index;
  }

  // ─── CTA ─────────────────────────────────────────────────────────
  String get ctaLabel {
    final title = plans[selectedPlanIndex.value]['title'];
    return 'Subscribe to $title plan';
  }

  Future<void> onSubscribe() async {
    if (isLoading.value) return;

    final selectedPlan = plans[selectedPlanIndex.value];
    final planTitle = selectedPlan['title'] ?? 'Premium';
    final amountMinor = int.tryParse(selectedPlan['amount_minor'] ?? '') ?? 0;
    final currency = selectedPlan['currency_code'] ?? 'eur';

    debugPrint(
      '[PremiumController] Subscribe tapped. plan=$planTitle, amountMinor=$amountMinor, currency=$currency',
    );

    if (amountMinor <= 0) {
      Get.snackbar(
        'Payment Error',
        'Plan amount invalid.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      await _stripeService.startPaymentSheet(
        planTitle: planTitle,
        amountMinor: amountMinor,
        currency: currency,
        isDarkMode: Get.isDarkMode,
      );

      Get.snackbar(
        'Payment Complete',
        '$planTitle plan payment complete.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on StripeException catch (error) {
      final message = error.error.localizedMessage?.trim();
      debugPrint('[PremiumController] StripeException: $message');
      Get.snackbar(
        'Stripe Error',
        message == null || message.isEmpty
            ? 'Card/payment process kora jai ni.'
            : message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error, stackTrace) {
      debugPrint('[PremiumController] Payment failure: $error');
      debugPrintStack(stackTrace: stackTrace);
      Get.snackbar(
        'Payment Failed',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

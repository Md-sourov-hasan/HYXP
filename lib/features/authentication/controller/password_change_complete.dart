import 'package:get/get.dart';
import 'package:hawiisaac/routes/app_routes.dart';

class PasswordChangeCompleteController extends GetxController {
  void onBackToLogin() {
    // TODO: Navigate back to login & clear stack
    Get.offAllNamed(AppRoute.loginScreen);
  }
}

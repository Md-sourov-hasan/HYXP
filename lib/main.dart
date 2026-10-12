import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:hawiisaac/core/config/stripe_config.dart';
import 'package:hawiisaac/core/services/storage_service.dart';
import 'package:hawiisaac/core/utils/theme/theme.dart';
import 'package:hawiisaac/features/splash_screen/view/splash_screen.dart';
import 'package:hawiisaac/firebase_options.dart';
import 'package:hawiisaac/routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    Stripe.publishableKey = StripeConfig.publishableKey;
    await Stripe.instance.applySettings();
    await StorageService.init();
    runApp(const MyApp());
  } catch (error, stackTrace) {
    debugPrint('App startup failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: StorageService.themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          getPages: AppRoute.routes,
          home: child,
          builder: EasyLoading.init(),
        );
      },
      child: const SplashScreen(),
    );
  }
}

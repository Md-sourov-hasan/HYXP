import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/bindings/controller_binder.dart';
import 'package:hawiisaac/core/services/storage_service.dart';
import 'package:hawiisaac/core/utils/theme/theme.dart';
import 'package:hawiisaac/routes/app_routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //Set the fit size (Find your UI design, look at the dimensions of the device screen and fill it in,unit in dp)
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      // Use builder only if you need to use library outside ScreenUtilInit context
      builder: (_, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoute.getAuthOptionsScreen(),
          getPages: AppRoute.routes,
          initialBinding: ControllerBinder(),
          themeMode: StorageService.themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          builder: EasyLoading.init(),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/features/loggin/controller/main_loggin_controller.dart';

class MainLogginScreen extends StatelessWidget {
  const MainLogginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MainLogginController());
    final appBarTitleStyle = Theme.of(context).appBarTheme.titleTextStyle;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Loggin',
          style: appBarTitleStyle?.copyWith(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Obx(() => Text(controller.message.value)),
      ),
    );
  }
}

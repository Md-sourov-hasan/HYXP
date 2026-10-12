import 'package:flutter/material.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';

class AppTextFormFieldTheme {
  AppTextFormFieldTheme._();

  static final InputDecorationTheme lightInputDecorationTheme =
      InputDecorationTheme(
        errorMaxLines: 3,
        prefixIconColor: AppColors.grey,
        suffixIconColor: AppColors.grey,
        labelStyle: const TextStyle(fontSize: 14, color: AppColors.black),
        hintStyle: const TextStyle(fontSize: 14, color: AppColors.grey),
        errorStyle: const TextStyle(fontSize: 12, color: AppColors.red),
        floatingLabelStyle: TextStyle(
          color: AppColors.black.withValues(alpha: 0.8),
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: AppColors.grey),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: AppColors.grey),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(
            color: AppColors.primaryColor,
          ), // You can replace with a specific color
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: AppColors.red),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: AppColors.orange),
        ),
      );

  static const InputDecorationTheme darkInputDecorationTheme =
      InputDecorationTheme(
        errorMaxLines: 3,
        prefixIconColor: AppColors.grey,
        suffixIconColor: AppColors.grey,
        labelStyle: TextStyle(fontSize: 14, color: AppColors.white),
        hintStyle: TextStyle(fontSize: 14, color: Colors.white70),
        errorStyle: TextStyle(fontSize: 12, color: AppColors.red),
        floatingLabelStyle: TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: AppColors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: AppColors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(
            color: AppColors.white,
          ), // You can replace with a specific color
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: AppColors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: AppColors.orange),
        ),
      );
}

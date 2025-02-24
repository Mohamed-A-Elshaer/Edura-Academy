import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mashrooa_takharog/auth/auth_service.dart';
import 'package:mashrooa_takharog/screens/ResetPassDecisionScreen.dart';
import 'package:mashrooa_takharog/screens/craetnewpass.dart';

class ForgetPasswordController extends GetxController {
  static ForgetPasswordController get instance => Get.find();
  final authService = AuthService();
  final email = TextEditingController();

  GlobalKey<FormState> forgetPasswordFormKey = GlobalKey<FormState>();

  sendPasswordResetEmail() async {
    try {
      if (!forgetPasswordFormKey.currentState!.validate()) {
        return;
      }

      await authService.resetPassword(email.text.trim());

      Get.snackbar(
        'Success', // Title of the snackbar
        'Password reset email has been sent!', // Message to display
        snackPosition: SnackPosition.BOTTOM, // Position of the snackbar
        backgroundColor: Colors.blue, // Background color
        colorText: Colors.white, // Text color
        duration: const Duration(seconds: 3), // Duration for the snackbar
      );
      Get.to(() => ResetPassDecisionScreen(email: email.text.trim()));
    } catch (e) {
      Get.snackbar(
        'Error', // Title of the snackbar
        e.toString(), // Message to display
        snackPosition: SnackPosition.BOTTOM, // Position of the snackbar
        backgroundColor: Colors.red, // Background color
        colorText: Colors.white, // Text color
        duration: const Duration(seconds: 3), // Duration for the snackbar
      );
    }
  }

  resendPasswordResetEmail(String email) async {
    try {
      await authService.resetPassword(email);

      Get.snackbar(
        'Success', // Title of the snackbar
        'Password reset email has been sent!', // Message to display
        snackPosition: SnackPosition.BOTTOM, // Position of the snackbar
        backgroundColor: Colors.blue, // Background color
        colorText: Colors.white, // Text color
        duration: const Duration(seconds: 3), // Duration for the snackbar
      );
    } catch (e) {
      Get.snackbar(
        'Error', // Title of the snackbar
        e.toString(), // Message to display
        snackPosition: SnackPosition.BOTTOM, // Position of the snackbar
        backgroundColor: Colors.red, // Background color
        colorText: Colors.white, // Text color
        duration: const Duration(seconds: 3), // Duration for the snackbar
      );
    }
  }
}

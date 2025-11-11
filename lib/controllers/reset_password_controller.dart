import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:olive_leaf_analyzer/constants/constants.dart'; 
import 'package:olive_leaf_analyzer/models/reset_password_model.dart';

class ResetPasswordController extends GetxController {
  final emailController = TextEditingController();
  final isLoading = false.obs;

  // Function to send reset code to the user's email
  void sendResetLink() async {
    if (emailController.text.isEmpty) {
      Get.snackbar(
        'Erreur'.tr, 
        'Veuillez entrer votre adresse e-mail'.tr, 
        backgroundColor: Colors.white, // White background
        colorText: Colors.black, // Black text color
      );
      return;
    }

    isLoading.value = true;

    // Create the ResetPasswordModel
    final resetPasswordData = ResetPasswordModel(email: emailController.text, code: '');

    try {
      final response = await http.post(
        Uri.parse('$baseUrlwifi/forgot-password'),  // Your Flask backend URL
        headers: {'Content-Type': 'application/json'},
        body: json.encode(resetPasswordData.toJson()),  // Send the model as JSON
      );

      isLoading.value = false;

      if (response.statusCode == 200) {
        // If the response is successful, show success and navigate to code confirmation screen
        Get.snackbar(
          'Succès'.tr,  
          'Un code de vérification a été envoyé à votre email.'.tr, 
          backgroundColor: Colors.white, // White background
          colorText: Colors.black, // Black text color
        );
        emailController.clear();
        Get.toNamed('/confirm-code');  // Navigate to a page where user can confirm the code
      } else {
        // If the response is an error (like no user found)
        final errorData = json.decode(response.body);
        Get.snackbar(
          'Erreur'.tr,  
          (errorData['error'] as String?)?.tr ?? 'Une erreur est survenue'.tr,
          backgroundColor: Colors.white, // White background
          colorText: Colors.black, // Black text color
        );
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Erreur'.tr,  
        '${'Problème de connexion'.tr} : $e', 
        backgroundColor: Colors.white, // White background
        colorText: Colors.black, // Black text color
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:olive_leaf_analyzer/constants/constants.dart'; 
import 'package:olive_leaf_analyzer/models/change_password_model.dart'; // Import the model

class ChangePasswordController extends GetxController {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;

  final isPasswordVisible = true.obs;
  final isConfirmPasswordVisible = true.obs;
  final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$');


  bool validateForm() {
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (password.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar(
        'Erreur'.tr,
        'Veuillez remplir tous les champs'.tr,
        backgroundColor: Colors.white, // White background
        colorText: Colors.black, // Black text color
      );
      return false;
    }

    if (!passwordRegex.hasMatch(password)) {
      Get.snackbar(
        'Erreur'.tr,
        'Le mot de passe doit contenir au moins 6 caractères, incluant une lettre et un chiffre'.tr,
        backgroundColor: Colors.white, // White background
        colorText: Colors.black, // Black text color
      );
      return false;
    }

    if (password != confirmPassword) {
      Get.snackbar(
        'Erreur'.tr,
        'Les mots de passe ne correspondent pas'.tr,
        backgroundColor: Colors.white, // White background
        colorText: Colors.black, // Black text color
      );
      return false;
    }

    return true;
  }

  Future<void> submitPasswordChange() async {
    if (!validateForm()) return;

    isLoading.value = true;
    final token = Get.parameters['token'];

    final changePasswordModel = ChangePasswordModel(
      token: token!,
      password: passwordController.text.trim(),
    );

    try {
      final response = await http.post(
        Uri.parse('$baseUrlwifi/change-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(changePasswordModel.toJson()), // Pass model to API
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Get.snackbar(
          'Succès'.tr,
         (responseData['message'] as String?)?.tr ?? 'Mot de passe mis à jour'.tr,
          backgroundColor: Colors.white, // White background
          colorText: Colors.black, // Black text color
        );
        Get.offNamed('/login'); // Navigate back to login page after password update
      } else {
        Get.snackbar(
          'Erreur'.tr,
          (responseData['error'] as String?)?.tr ?? 'Impossible de changer le mot de passe'.tr,
          backgroundColor: Colors.white, // White background
          colorText: Colors.black, // Black text color
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur'.tr,
        'Une erreur est survenue lors de la mise à jour'.tr,
        backgroundColor: Colors.white, // White background
        colorText: Colors.black, // Black text color
      );
    } finally {
      isLoading.value = false;
    }
  }
}

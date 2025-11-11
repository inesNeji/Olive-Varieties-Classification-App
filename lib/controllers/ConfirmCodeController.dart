import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:olive_leaf_analyzer/constants/constants.dart';
import 'package:olive_leaf_analyzer/models/ConfirmCodeModel.dart'; // Import model

class ConfirmCodeController extends GetxController {
  final codeController = TextEditingController();
  final isLoading = false.obs;

  void confirmCode() async {
    if (codeController.text.isEmpty) {
      Get.snackbar(
        'Erreur'.tr,
        'Veuillez entrer le code de vérification'.tr,
        backgroundColor: Colors.white, // White background
        colorText: Colors.black, // Black text color
      );
      return;
    }

    isLoading.value = true;

    // Create model instance
    final confirmCodeModel = ConfirmCodeModel(code: codeController.text);

    try {
      final response = await http.post(
        Uri.parse('$baseUrlwifi/verify-code'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(confirmCodeModel.toJson()), // Send model data
      );

      isLoading.value = false;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'];

        Get.snackbar(
          'Succès'.tr,
          'Code confirmé !'.tr,
          backgroundColor: Colors.white, // White background
          colorText: Colors.black, // Black text color
        );
        codeController.clear();

        // Navigate to change-password and pass token
        Get.toNamed('/change-password?token=$token');
      } else {
        final errorData = json.decode(response.body);
        Get.snackbar(
          'Erreur'.tr,
           (errorData['error'] as String?)?.tr ?? 'Code invalide'.tr,
          backgroundColor: Colors.white, // White background
          colorText: Colors.black, // Black text color
        );
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Erreur',
        '${'Problème de connexion'.tr} : $e',
        backgroundColor: Colors.white, // White background
        colorText: Colors.black, // Black text color
      );
    }
  }
}

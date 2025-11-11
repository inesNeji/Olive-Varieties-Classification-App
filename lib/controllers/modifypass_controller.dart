import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:olive_leaf_analyzer/constants/constants.dart';
import 'package:olive_leaf_analyzer/models/modifypass_model.dart';

class ModifypassController extends GetxController {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final box = GetStorage();

  var isOldPasswordVisible = true.obs;
  var isNewPasswordVisible = true.obs;
  var isConfirmPasswordVisible = true.obs;
  var isLoading = false.obs;

  bool validatePassword(String password) {
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(password);
    final hasNumber = RegExp(r'\d').hasMatch(password);
    return password.length >= 6 && hasLetter && hasNumber;
  }

  Future<void> submitPasswordChange() async {
    final email = box.read('email');

    if (email == null || email.isEmpty) {
      Get.snackbar(
        'Erreur'.tr,
        'Utilisateur non authentifié'.tr,
        backgroundColor: const Color(0xFFFFFFFF),
        colorText: const Color(0xFF000000),
      );
      return;
    }

    final oldPassword = oldPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // Check if new and confirm passwords are empty
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar(
        'Erreur'.tr,
        'Veuillez remplir tous les champs sauf l\'ancien mot de passe si vous n\'en avez pas'.tr,
        backgroundColor: const Color(0xFFFFFFFF),
        colorText: const Color(0xFF000000),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      Get.snackbar(
        'Erreur'.tr,
        'Les mots de passe ne correspondent pas'.tr,
        backgroundColor: const Color(0xFFFFFFFF),
        colorText: const Color(0xFF000000),
      );
      return;
    }

    if (oldPassword.isNotEmpty && newPassword == oldPassword) {
      Get.snackbar(
        'Erreur'.tr,
        'Le nouveau mot de passe ne peut pas être identique à l\'ancien'.tr,
        backgroundColor: const Color(0xFFFFFFFF),
        colorText: const Color(0xFF000000),
      );
      return;
    }

    if (!validatePassword(newPassword)) {
      Get.snackbar(
        'Erreur'.tr,
        'Le mot de passe doit contenir au moins 6 caractères, avec au moins une lettre et un chiffre'.tr,
        backgroundColor: const Color(0xFFFFFFFF),
        colorText: const Color(0xFF000000),
      );
      return;
    }

    isLoading.value = true;

    final modifypassModel = ModifypassModel(
      email: email,
      oldPassword: oldPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    try {
      final response = await http.post(
        Uri.parse('$baseUrlwifi/modifypass'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(modifypassModel.toMap()),
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          'Succès'.tr,
          'Mot de passe changé avec succès'.tr,
          backgroundColor: const Color(0xFFFFFFFF),
          colorText: const Color(0xFF000000),
        );
        Get.offAllNamed('/profile');
      } else {
        final errorMessage =
            jsonDecode(response.body)['error'] ?? 'Échec du changement de mot de passe'.tr;
        Get.snackbar(
          'Erreur'.tr,
          errorMessage,
          backgroundColor: const Color(0xFFFFFFFF),
          colorText: const Color(0xFF000000),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur'.tr,
        'Échec de la connexion au serveur'.tr,
        backgroundColor: const Color(0xFFFFFFFF),
        colorText: const Color(0xFF000000),
      );
    } finally {
      isLoading.value = false;
    }
  }
}

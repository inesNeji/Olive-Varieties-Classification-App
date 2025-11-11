import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:olive_leaf_analyzer/constants/constants.dart';
import 'package:olive_leaf_analyzer/models/signup_modle.dart';  // Import User model

class SignupController extends GetxController {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final acceptTerms = false.obs;
  final showPassword = false.obs;
  final showConfirmPassword = false.obs;
  final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$');
  
  bool validateForm() {
    final name = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar(
        'Erreur'.tr, 
        'Veuillez remplir tous les champs'.tr,
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
      return false;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        'Erreur'.tr,
        'Email invalide'.tr,
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
      return false;
    }

    if (!passwordRegex.hasMatch(password)) {
      Get.snackbar(
        'Erreur'.tr,
        'Le mot de passe doit contenir au moins 6 caractères, incluant une lettre et un chiffre'.tr,
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
      return false;
    }

    if (password != confirmPassword) {
      Get.snackbar(
        'Erreur'.tr, 
        'Les mots de passe ne correspondent pas'.tr,
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
      return false;
    }

    if (!acceptTerms.value) {
      Get.snackbar(
        'Erreur'.tr,
        'Veuillez accepter les conditions d\'utilisation'.tr,
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
      return false;
    }

    return true;
  }

  Future<void> signup() async {
    if (!validateForm()) return;

    isLoading.value = true;
    try {
      final user = User(
        name: fullNameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final url = Uri.parse('$baseUrlwifi/signup');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),  // Using the User model's toJson method
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        Get.snackbar(
          'Succès'.tr, 
          (responseData['message'] as String).tr,
          backgroundColor: Colors.white,
          colorText: Colors.black,
        );
        clearForm();
        Get.offNamed('/login');
      } else {
        Get.snackbar(
          'Erreur', 
          (responseData['error'] as String).tr,
          backgroundColor: Colors.white,
          colorText: Colors.black,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur', 
        'Erreur de connexion : $e'.tr,
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    fullNameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    acceptTerms.value = false;
  }
}

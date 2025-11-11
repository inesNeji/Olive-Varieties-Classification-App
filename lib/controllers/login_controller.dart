import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:olive_leaf_analyzer/constants/constants.dart';
import 'package:olive_leaf_analyzer/models/login_model.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  RxBool isLoading = false.obs;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '689248491740-o04sjop69nddqnp5p9u8gtv9qqtuod1s.apps.googleusercontent.com',
  );

  final box = GetStorage();

  void login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Erreur'.tr, 
        'Veuillez remplir tous les champs'.tr, 
        backgroundColor: Colors.white, // White background
        colorText: Colors.black, // Black text color
      );
      return;
    }

    isLoading.value = true;

    LoginModel loginData = LoginModel(email: email, password: password);

    try {
      final url = Uri.parse('$baseUrlwifi/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(loginData.toMap()),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        box.write('email', email);
        box.write('isLoggedIn', true);
        box.write('loginTime', DateTime.now().millisecondsSinceEpoch);
        Get.snackbar(
          'Succès'.tr, 
          'Connexion réussie'.tr,
          backgroundColor: Colors.white, // White background
          colorText: Colors.black, // Black text color
        );
        Get.offAllNamed('/');
      } else {
        Get.snackbar(
        'Erreur'.tr,
          (responseData['error'] as String).tr,
          backgroundColor: Colors.white, // White background
          colorText: Colors.black, // Black text color
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur'.tr, 
        'Erreur de connexion : $e'.tr,
        backgroundColor: Colors.white, // White background
        colorText: Colors.black, // Black text color
      );
    } finally {
      isLoading.value = false;
    }
  }

  void signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        Get.snackbar(
          'Annulé'.tr,
          'Connexion Google annulée'.tr, 
          backgroundColor: Colors.white, // White background
          colorText: Colors.black, // Black text color
        );
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        Get.snackbar(
          'Erreur'.tr,
          'Jeton Google non trouvé'.tr,
          backgroundColor: Colors.white, // White background
          colorText: Colors.black, // Black text color
        );
        return;
      }

      final url = Uri.parse('$baseUrlwifi/google-signin');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': idToken}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final userEmail = data['email'] ?? googleUser.email;
        box.write('email', userEmail);
        box.write('isLoggedIn', true);
        box.write('loginTime', DateTime.now().millisecondsSinceEpoch);
        Get.snackbar(
          'Succès'.tr,
          'Connecté avec Google'.tr, 
          backgroundColor: Colors.white, // White background
          colorText: Colors.black, // Black text color
        );
        Get.offAllNamed('/');
      } else {
        Get.snackbar(
          'Erreur'.tr, 
          data['error'] ?? 'Erreur de connexion Google'.tr, 
          backgroundColor: Colors.white, // White background
          colorText: Colors.black, // Black text color
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur'.tr, 
        "Erreur Google".tr,
        backgroundColor: Colors.white, // White background
        colorText: Colors.black, // Black text color
      );
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

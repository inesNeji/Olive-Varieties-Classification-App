import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:olive_leaf_analyzer/constants/constants.dart';

class MainController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  void goToAnalysis(String imagePath) {
    Get.toNamed('/analysis', arguments: imagePath);
  }

  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        await _validateImageBeforeAnalysis(image.path);
      }
    } catch (e) {
      Get.snackbar(
        'Erreur'.tr,
        "${'Échec de la sélection de l\'image'.tr} : $e",
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
    }
  }

  Future<void> takePhotoWithCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        await _validateImageBeforeAnalysis(image.path);
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        "${'Échec de la prise de photo'.tr} : $e",
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
    }
  }

  Future<void> _validateImageBeforeAnalysis(String imagePath) async {
    try {
      // Show loading indicator
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Validate if image is an olive leaf
      var validationRequest = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrlwifi/validate-olive'),
      );
      validationRequest.files.add(await http.MultipartFile.fromPath('file', imagePath));
      var validationResponse = await validationRequest.send();
      var responseBody = await validationResponse.stream.bytesToString();
      final data = json.decode(responseBody);

      final status = data['status'];
      final confidence = data['confidence'] ?? 0;

      // Close loading dialog
      Get.back();

      if (status == 'olive leaf' && confidence >= 90.0) {
        await _proceedWithContour(imagePath);
      } else {
        _showConfirmationDialog(imagePath);
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Erreur'.tr,
        "${'Erreur lors de la validation de l\'image'.tr} : $e",
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
    }
  }

  Future<void> _proceedWithContour(String imagePath) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      var contourRequest = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrlwifi/detect-contours'),
      );
      contourRequest.files.add(await http.MultipartFile.fromPath('image', imagePath));
      var contourResponse = await contourRequest.send();

      Get.back();

      if (contourResponse.statusCode == 200) {
        final bytes = await contourResponse.stream.toBytes();
        final file = File(imagePath);
        await file.writeAsBytes(bytes);
        goToAnalysis(imagePath);
      } else {
        Get.snackbar(
          'Erreur'.tr,
          'Échec de la détection des contours.'.tr,
          backgroundColor: Colors.white,
          colorText: Colors.black,
        );
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Erreur'.tr,
        "${'Erreur lors du traitement de l\'image'.tr} : $e",
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
    }
  }

  void _showConfirmationDialog(String imagePath) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children:  [
            Icon(Icons.help_outline, color: Colors.orange),
            SizedBox(width: 8),
            Text("Êtes-vous sûr ?".tr, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          "L'image ne semble pas contenir une feuille d’olivier.\n\nÊtes-vous sûr que c'en est une ?".tr,
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(), // No -> close dialog
            child: Text("Non".tr, style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () async {
              Get.back(); // Close dialog
              await _proceedWithContour(imagePath); // Yes -> continue
            },
            child: Text("Oui".tr, style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  

  void goToHistorique() => Get.toNamed('/historique');
  void goToProfile() => Get.toNamed('/profile');
}

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:olive_leaf_analyzer/constants/constants.dart';
class AnalysisController extends GetxController {
  // Function to send image to Flask API for analysis
  Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrlwifi/predict'), // Update to your Flask API URL
      );
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      return json.decode(responseBody);
    } catch (e) {
  print('Error during analysis: $e');
  Get.snackbar(
    'Erreur'.tr,
    'Échec de l\'analyse de l\'image'.tr,
    backgroundColor: Colors.white,
    colorText: Colors.black,
  );
  throw Exception('Failed to analyze image'.tr,);
}
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:olive_leaf_analyzer/models/save_result_model.dart';
import 'package:olive_leaf_analyzer/constants/constants.dart';

class ResultsController extends GetxController {
 
  final String _baseUrl = '$baseUrlwifi/save-result';

  
  Future<void> saveResults(
    String imagePath,
    String resultat,
    String confidence,
  ) async {
    try {
      
      final box = GetStorage();
      String userEmail = box.read('email') ?? '';

     
      final saveResultData = SaveResultModel(
        imagePath: imagePath,
        result: resultat,
        confidence: confidence,
        email: userEmail,
      );
      var request =
          http.MultipartRequest('POST', Uri.parse(_baseUrl))
            ..fields['result'] = saveResultData.result
            ..fields['confidence'] = saveResultData.confidence
            ..fields['email'] = saveResultData.email
            ..files.add(await http.MultipartFile.fromPath('image', imagePath));

      var response = await request.send();
      if (response.statusCode == 200) {
        Get.snackbar(
          'Enregistré'.tr,
          'Résultats enregistrés avec succès'.tr,
          backgroundColor: Colors.white, 
          colorText: Colors.black,
        );
        Get.offAllNamed('/'); 
      } else {
        Get.snackbar(
          'Erreur'.tr,
          "Impossible d'enregistrer les résultats".tr,
          backgroundColor: Colors.white, 
          colorText: Colors.black, 
        );
      }
    } catch (e) {
     
     Get.snackbar(
        'Erreur'.tr,
        '${'Échec de l\'enregistrement des résultats'.tr}: $e',
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
    }
  }
}

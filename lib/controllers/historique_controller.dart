import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:olive_leaf_analyzer/constants/constants.dart';
import 'package:olive_leaf_analyzer/models/historique_model.dart'; // Import the model

class HistoriqueController extends GetxController {
  var historiqueList = <Historique>[].obs; // Updated to a list of Historique objects
  var isLoading = true.obs;
  var isImageVisible = false.obs;
  var imageUrlToDisplay = ''.obs;
  var email = ''.obs;

  final String baseUrl = '$baseUrlwifi'; // <--- put your real server IP!
  final box = GetStorage(); // Access GetStorage

  Future<void> fetchHistorique() async {
    email.value = box.read('email') ?? '';
    print("Stored email: $email"); // Read email from GetStorage

    if (email.isEmpty) {
      return; // Handle the error appropriately, maybe show a message
    }

    try {
      isLoading.value = true;
      final response = await http.get(Uri.parse('$baseUrlwifi/get-historique?email=$email'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        historiqueList.value = List<Historique>.from(
            data['data'].map((entry) => Historique.fromJson(entry)));
      } else {
        historiqueList.clear();
      }
    } catch (e) {
      print("Erreur lors de la récupération de l'historique:".tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteHistorique(String id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/delete-historique'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'_id': id}),
      );

      if (response.statusCode == 200) {
        historiqueList.removeWhere((entry) => entry.id == id);
      }
    } catch (e) {
      print("Erreur lors de la suppression de l'historique :");
    }
  }

  void showImage(String filename) {
    imageUrlToDisplay.value = '$baseUrl/get-image/$filename';
    isImageVisible.value = true;
  }

  void hideImage() {
    isImageVisible.value = false;
    imageUrlToDisplay.value = '';
  }
}

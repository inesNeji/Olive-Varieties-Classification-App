import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:olive_leaf_analyzer/constants/constants.dart'; 
import 'package:olive_leaf_analyzer/models/profile_model.dart'; // Import the model

class ProfileController extends GetxController {
  var userProfile = Rx<UserProfile>(UserProfile(name: '', email: '', picture: null));
  var isLoading = false.obs;
  var profilePicture = Rx<Uint8List?>(null);
  final box = GetStorage();
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    fetchUserInfo();
  }

  // Fetch user information including profile picture
  Future<void> fetchUserInfo() async {
    String email = box.read('email') ?? '';
    if (email.isNotEmpty) {
      isLoading.value = true;

      try {
        final response = await http.get(
          Uri.parse('$baseUrlwifi/user?email=$email'),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          userProfile.value = UserProfile.fromJson(data);

          // Load the profile picture if it exists
          if (userProfile.value.picture != null) {
            profilePicture.value = base64Decode(userProfile.value.picture!);
          } else {
            profilePicture.value = null;
          }
        } else {
          Get.snackbar(
            'Erreur'.tr,
            'Impossible de récupérer les données utilisateur.'.tr,
            backgroundColor: const Color(0xFFFFFFFF),
            colorText: const Color(0xFF000000),
          );
        }
      } catch (e) {
        Get.snackbar(
          'Erreur'.tr,
          '${'Échec de la connexion au serveur'.tr} : $e',
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          colorText: Color.fromARGB(255, 0, 0, 0),
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  // Pick an image from the gallery or camera
  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      profilePicture.value = imageBytes;

      // Send image to backend to update profile
      await uploadImageToBackend(imageBytes);
    }
  }

  // Upload the selected image to the backend along with the email
  Future<void> uploadImageToBackend(Uint8List imageBytes) async {
    final uri = Uri.parse('$baseUrlwifi/upload-profile-picture');
    final request = http.MultipartRequest('POST', uri);

    // Get email from GetStorage (you can also use GetX to manage this)
    final email = box.read('email') ?? '';
    if (email.isEmpty) {
      Get.snackbar(
        'Erreur'.tr,
        'Email manquant!'.tr,
        backgroundColor: const Color(0xFFFFFFFF),
        colorText: const Color(0xFF000000),
      );
      return;
    }

    // Add email to the request
    request.fields['email'] = email;

    // Prepare the image as a multipart file
    final imageFile = http.MultipartFile.fromBytes('picture', imageBytes, filename: 'profile_pic.jpg');
    print('Uploading image: $imageFile');  // Debugging log

    request.files.add(imageFile);

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        
        fetchUserInfo();  // Reload user info to reflect the new profile picture
      } else {
        Get.snackbar(
          'Erreur'.tr,
          'Échec de la mise à jour de l\'image.'.tr,
          backgroundColor: const Color(0xFFFFFFFF),
          colorText: const Color(0xFF000000),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur'.tr,
        '${'Échec de la connexion au serveur'.tr} : $e',
        backgroundColor: const Color(0xFFFFFFFF),
        colorText: const Color(0xFF000000),
      );
    }
  }

  // Log the user out and clear the stored email
 void logout() async {
  final lang = box.read('lang');
  final locale = box.read('locale');

  await box.erase();

  if (lang != null) {
    await box.write('lang', lang);
  }
  if (locale != null) {
    await box.write('locale', locale);
  }

  Get.offAllNamed('/login');
}



  // Navigate to the change password page
  void goToModifypass() {
    Get.toNamed('/modifypass');
  }
}

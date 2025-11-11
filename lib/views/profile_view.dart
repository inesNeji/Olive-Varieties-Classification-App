import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:olive_leaf_analyzer/controllers/profile_controller.dart';
import 'package:olive_leaf_analyzer/widgets/nav_bar.dart';
import 'package:image_picker/image_picker.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  // List of supported languages with flags
  final List<Map<String, String>> languages = const [
    {'code': 'ar', 'label': 'العربية 🇸🇦'},
    {'code': 'en', 'label': 'English 🇺🇸'},
    {'code': 'fr', 'label': 'Français 🇫🇷'},
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    final box = GetStorage();

    // Load saved language code or default to 'fr'
    String selectedLangCode = box.read('lang') ?? 'fr';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.person, color: Colors.white),
            const SizedBox(width: 8),
            Text('Profil'.tr),
            const Spacer(),
            DropdownButton<String>(
              dropdownColor: Colors.white,
              underline: const SizedBox(),
              value: selectedLangCode,
              icon: const Icon(Icons.language, color: Colors.white),
              items: languages.map((lang) {
                return DropdownMenuItem<String>(
                  value: lang['code'],
                  child: Text(
                    lang['label']!,
                    style: const TextStyle(color: Colors.black),
                  ),
                );
              }).toList(),
              onChanged: (String? newLang) {
                  if (newLang != null) {
                    box.write('lang', newLang); // Optional
                    Locale newLocale;

                    if (newLang == 'ar') {
                      newLocale = const Locale('ar', 'SA');
                    } else if (newLang == 'en') {
                      newLocale = const Locale('en', 'US');
                    } else {
                      newLocale = const Locale('fr', 'FR');
                    }

                    box.write('locale', {
                      'languageCode': newLocale.languageCode,
                      'countryCode': newLocale.countryCode,
                    });

                    Get.updateLocale(newLocale);
                  }
                },

            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 42, 118, 53),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFEAF3EA),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Obx(() {
                          if (controller.isLoading.value) {
                            return const CircularProgressIndicator();
                          } else {
                            return CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey[300],
                              backgroundImage: controller.profilePicture.value != null
                                  ? MemoryImage(controller.profilePicture.value!)
                                  : null,
                              child: controller.profilePicture.value == null
                                  ? const Icon(Icons.person, size: 60, color: Colors.white)
                                  : null,
                            );
                          }
                        }),
                        Positioned(
                          bottom: -10,
                          right: -10,
                          child: GestureDetector(
                            onTap: () async {
                              final imageSource = await showDialog<ImageSource>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text(
                                      'Choisir la source de l\'image'.tr,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(ImageSource.camera),
                                        child: Text('Caméra'.tr),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
                                        child: Text('Galerie'.tr),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (imageSource != null) {
                                controller.pickImage(imageSource);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[600],
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text('Nom:'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Obx(() => controller.isLoading.value
                      ? const CircularProgressIndicator()
                      : _customDisplayField(
                          icon: Icons.person_outline,
                          content: controller.userProfile.value.name.isEmpty
                              ? 'Nom non disponible'.tr
                              : controller.userProfile.value.name,
                        )),
                  const SizedBox(height: 24),
                  Text('Email:'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Obx(() => controller.isLoading.value
                      ? const CircularProgressIndicator()
                      : _customDisplayField(
                          icon: Icons.email_outlined,
                          content: controller.userProfile.value.email.isEmpty
                              ? 'Email non disponible'.tr
                              : controller.userProfile.value.email,
                        )),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: controller.goToModifypass,
                      child: Text(
                        'Changer mot de passe'.tr,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: controller.logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.logout),
                      label: Text('Se déconnecter'.tr),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            bottom: 5,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: NavBar(currentPage: NavBarPage.profile),
            ),
          ),
        ],
      ),
    );
  }

  Widget _customDisplayField({required IconData icon, required String content}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(child: Text(content, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
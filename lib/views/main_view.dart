import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olive_leaf_analyzer/controllers/main_controller.dart';
import 'package:olive_leaf_analyzer/widgets/nav_bar.dart';

class MainView extends StatelessWidget {
  final MainController _controller = Get.put(MainController());

  MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF3EA),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 42, 118, 53),
        elevation: 0,
        title:  Text(
          'Accueil'.tr,
          style: TextStyle(color: Colors.white),
        ),
        leading: const Icon(
          Icons.home,
          color: Colors.white,
        ),
      ),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
               Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Analysez vos\nfeuilles d\'olivier en\nun clic !'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              _buildBlackButton(
                label: '📸 Prendre une photo'.tr,
                onTap: _controller.takePhotoWithCamera,
              ),
              const SizedBox(height: 20),
              _buildBlackButton(
                label: '🗂️ Importer une image'.tr,
                onTap: _controller.pickImageFromGallery,
              ),
              const Spacer(flex: 3),
            ],
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: SafeArea(
              top: false,
              child: NavBar(currentPage: NavBarPage.home),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlackButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

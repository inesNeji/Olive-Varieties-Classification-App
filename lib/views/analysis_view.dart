import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:olive_leaf_analyzer/controllers/AnalysisController.dart';
import 'package:olive_leaf_analyzer/widgets/nav_bar.dart';

class AnalysisView extends StatelessWidget {
  final String imagePath;

  const AnalysisView({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final AnalysisController controller = Get.put(AnalysisController());

    return Scaffold(
      backgroundColor: const Color(0xFFEAF3EA),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 42, 118, 53),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children:  [
            Icon(Icons.search, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Analyse'.tr,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(imagePath),
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      Center(child: Text('Error loading image'.tr)),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: _buildAnalyzeButton(controller),
          ),
        ],
      ),
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.only(bottom: 50),
        child: NavBar(currentPage: NavBarPage.other),
      ),
    );
  }

  Widget _buildAnalyzeButton(AnalysisController controller) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          Get.snackbar('Analysis'.tr, 'Processing image...'.tr,
          backgroundColor: Colors.white,
        colorText: Colors.black,);
          await Future.delayed(const Duration(seconds: 2));

          try {
            final result = await controller.analyzeImage(File(imagePath));
            final String predictedClass = result['class'] ?? 'No diagnosis available';
            final double confidence = result['confidence'] ?? 0.0;
            String confidenceFormatted = '${(confidence * 100).floor()}%';

            Get.toNamed(
              '/results',
              arguments: {
                'imagePath': imagePath,
                'resultat': predictedClass,
                'confidence': confidenceFormatted,
              },
            );
          }catch (e) {

}

        },
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              '🔍 Analyser'.tr,
              style: TextStyle(
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

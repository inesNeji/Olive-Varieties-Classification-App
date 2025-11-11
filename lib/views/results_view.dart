import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:olive_leaf_analyzer/controllers/ResultsController.dart';
import 'package:olive_leaf_analyzer/widgets/nav_bar.dart';

class ResultsView extends StatelessWidget {
  final String imagePath;
  final String resultat;
  final String confidence;

  final ResultsController controller = Get.put(ResultsController());

  ResultsView({
    Key? key,
    required this.imagePath,
    required this.resultat,
    required this.confidence,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF3EA),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 42, 118, 53),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Icon(Icons.analytics, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Résultat'.tr,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
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
              child: _buildResultRow('variété'.tr, resultat),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: _buildResultRow('Précision'.tr, confidence),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                children: [
                  Expanded(
                    child: _buildBlackButton(
                      '💾 Save'.tr,
                      () => controller.saveResults(imagePath, resultat, confidence),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildBlackButton(
                      '🗑️ Ignore'.tr,
                      () => Get.offAllNamed('/'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.only(bottom: 50),
        child: NavBar(currentPage: NavBarPage.other),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlackButton(String text, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              text,
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

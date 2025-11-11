import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olive_leaf_analyzer/controllers/historique_controller.dart';
import 'package:intl/intl.dart';
import 'package:olive_leaf_analyzer/widgets/nav_bar.dart';

class HistoriqueView extends StatelessWidget {
  HistoriqueView({super.key});

  final HistoriqueController controller = Get.put(HistoriqueController());

  @override
  Widget build(BuildContext context) {
    controller.fetchHistorique(); // Fetch historique without passing email

    return Scaffold(
      backgroundColor: const Color(0xFFEAF3EA),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 42, 118, 53),
        title: Row(
          children: [
            const Icon(Icons.access_time, color: Colors.white), // Clock icon
            const SizedBox(width: 8),
            Text('Historique'.tr, style: TextStyle(color: Colors.white)),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // Main content body
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.historiqueList.isEmpty) {
              return   Center(child: Text('Aucune donnée trouvée.'.tr));
            }

            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: controller.historiqueList.length,
              itemBuilder: (context, index) {
                final entry = controller.historiqueList[index];
                final imageUrl = '${controller.baseUrl}/get-image/${entry.imageFilename}';
                final timestamp = DateTime.tryParse(entry.timestamp);
                final formattedDate = timestamp != null
                    ? DateFormat('dd/MM/yyyy HH:mm').format(timestamp)
                    : 'Date inconnue';

                // Parsing confidence properly
                final confidence = int.tryParse(entry.confidence.replaceAll('%', '')) ?? 0;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Using InteractiveViewer for pinch zoom
                        InteractiveViewer(
                          minScale: 0.5,
                          maxScale: 4.0,
                          child: GestureDetector(
                            onTap: () {
                              _showImagePopup(context, imageUrl); // Show image popup on tap
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                imageUrl,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text('${'Résultat'.tr}: ${entry.result}', style: const TextStyle(fontSize: 16)),
                        Text('${'précision'.tr}: ${confidence}%', style: const TextStyle(fontSize: 16)),
                        Text('${'Date'.tr}: $formattedDate', style: const TextStyle(fontSize: 14, color: Colors.grey)),

                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _showDeleteConfirmationDialog(context, entry.id),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),

          const Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: NavBar(currentPage: NavBarPage.historique),
          ),
        ],
      ),
    );
  }

  // Show image in a separate popup (dialog)
  void _showImagePopup(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 16,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image is slightly higher than center
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    imageUrl,
                    height: 300, // Adjust image size in popup
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the popup
                  },
                  child:   Text("Fermer".tr, style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Enhanced Delete confirmation dialog with better UI
  void _showDeleteConfirmationDialog(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 16,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.delete_forever, color: Colors.red, size: 40),
                const SizedBox(height: 15),
                  Text(
                  "Êtes-vous sûr de vouloir supprimer cet élément ?".tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        controller.deleteHistorique(id); // Call the delete function
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child:   Text("Oui".tr, style: TextStyle(color: Colors.red)),
                    ),
                    const SizedBox(width: 15),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child:   Text("Non".tr, style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

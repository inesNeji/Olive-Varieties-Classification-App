import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olive_leaf_analyzer/controllers/reset_password_controller.dart';

class ResetPasswordView extends StatelessWidget {
  ResetPasswordView({super.key});

  final controller = Get.put(ResetPasswordController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF3EA),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),
                const Icon(Icons.lock_reset, color: Colors.green, size: 80),
                const SizedBox(height: 20),
                Text(
                  'Réinitialiser le mot de passe'.tr, 
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'Entrez votre adresse e-mail et nous vous enverrons un code de vérification pour réinitialiser votre mot de passe.'.tr, 
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),

                _inputField(
                  icon: Icons.email_outlined,
                  label: 'Email'.tr, 
                  controller: controller.emailController,
                ),
                const SizedBox(height: 24),

                Obx(() => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.sendResetLink,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.black12,
                          disabledForegroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: controller.isLoading.value
                            ? const CircularProgressIndicator(color: Colors.white)
                            :  Text(
                                'Envoyer le code'.tr, 
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    )),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Get.offNamed('/login'),
                  child:  Text(
                    'Retour à la connexion'.tr, 
                    style: TextStyle(color: Colors.green),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          icon: Icon(icon),
          labelText: label,
          border: InputBorder.none,
        ),
      ),
    );
  }
}

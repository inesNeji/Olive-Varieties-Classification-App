import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olive_leaf_analyzer/controllers/change_password_controller.dart';

class ChangePasswordView extends StatelessWidget {
  final controller = Get.put(ChangePasswordController());

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
                const Icon(Icons.lock_open, color: Colors.green, size: 80),
                const SizedBox(height: 20),
                Text(
                  'Entrez un nouveau mot de passe'.tr,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),

                Obx(() => _inputField(
                      label: 'Nouveau mot de passe'.tr,
                      controller: controller.passwordController,
                      isObscure: controller.isPasswordVisible.value,
                      onIconTap: () {
                        controller.isPasswordVisible.value =
                            !controller.isPasswordVisible.value;
                      },
                    )),

                const SizedBox(height: 16),

                Obx(() => _inputField(
                      label: 'Confirmer le mot de passe'.tr,
                      controller: controller.confirmPasswordController,
                      isObscure: controller.isConfirmPasswordVisible.value,
                      onIconTap: () {
                        controller.isConfirmPasswordVisible.value =
                            !controller.isConfirmPasswordVisible.value;
                      },
                    )),

                const SizedBox(height: 32),

                Obx(() => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.submitPasswordChange,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            :  Text(
                                'Enregistrer'.tr,
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    )),

                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () => Get.back(),
                  child:  Text(
                    'Retour à la réinitialisation'.tr,
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
    required String label,
    required TextEditingController controller,
    required bool isObscure,
    required VoidCallback onIconTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        decoration: InputDecoration(
          icon: const Icon(Icons.lock_outline),
          labelText: label,
          suffixIcon: GestureDetector(
            onTap: onIconTap,
            child: Icon(
              isObscure ? Icons.visibility_off : Icons.visibility,
              color: Colors.black,
            ),
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

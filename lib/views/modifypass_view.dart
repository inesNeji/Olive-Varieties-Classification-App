import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olive_leaf_analyzer/controllers/modifypass_controller.dart';

class ModifypassView extends StatelessWidget {
  final controller = Get.put(ModifypassController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF3EA),
      appBar: AppBar(
        title:  Text('Modifier mot de passe'.tr),
        backgroundColor: const Color.fromARGB(255, 42, 118, 53),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      
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

                // Old Password Field (if needed)
                Obx(() => _inputField(
                      label: 'Ancien mot de passe'.tr,
                      controller: controller.oldPasswordController,
                      isObscure: controller.isOldPasswordVisible.value,
                      onIconTap: () {
                        controller.isOldPasswordVisible.value =
                            !controller.isOldPasswordVisible.value;
                      },
                    )),

                const SizedBox(height: 16),

                // New Password Field
                Obx(() => _inputField(
                      label: 'Nouveau mot de passe'.tr,
                      controller: controller.newPasswordController,
                      isObscure: controller.isNewPasswordVisible.value,
                      onIconTap: () {
                        controller.isNewPasswordVisible.value =
                            !controller.isNewPasswordVisible.value;
                      },
                    )),

                const SizedBox(height: 16),

                // Confirm Password Field
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

                // Submit Button
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

                // Back to Profile
                GestureDetector(
                  onTap: () => Get.offAllNamed('/profile'),
                  child:Text(
                    'Retour au profil'.tr,
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Input field for password fields
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

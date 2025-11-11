import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olive_leaf_analyzer/controllers/signup_controller.dart';

class SignupView extends StatelessWidget {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());

    return Scaffold(
      backgroundColor: const Color(0xFFEAF3EA),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: kToolbarHeight), // Keeps the AppBar space
               Text(
                'Créer un compte'.tr,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Inscrivez-vous pour commencer'.tr,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              _customInputField(
                icon: Icons.person_outline,
                label: 'Nom complet'.tr,
                controller: controller.fullNameController,
              ),
              const SizedBox(height: 16),

              _customInputField(
                icon: Icons.email_outlined,
                label: 'Email'.tr,
                controller: controller.emailController,
              ),
              const SizedBox(height: 16),

              Obx(() => _customInputField(
                    icon: Icons.lock_outline,
                    label: 'Mot de passe'.tr,
                    controller: controller.passwordController,
                    obscureText: !controller.showPassword.value,
                    suffix: IconButton(
                      icon: Icon(controller.showPassword.value
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () => controller.showPassword.toggle(),
                    ),
                  )),
              const SizedBox(height: 16),

              Obx(() => _customInputField(
                    icon: Icons.lock_outline,
                    label: 'Confirmer le mot de passe'.tr,
                    controller: controller.confirmPasswordController,
                    obscureText: !controller.showConfirmPassword.value,
                    suffix: IconButton(
                      icon: Icon(controller.showConfirmPassword.value
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () => controller.showConfirmPassword.toggle(),
                    ),
                  )),
              const SizedBox(height: 16),

              Obx(() => Row(
                    children: [
                      Checkbox(
                        value: controller.acceptTerms.value,
                        onChanged: (val) =>
                            controller.acceptTerms.value = val ?? false,
                      ),
                       Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: "J'accepte les ".tr,
                            children: [
                              TextSpan(
                                text: " ".tr,
                                style: TextStyle(color: Colors.green),
                              ),
                              TextSpan(
                                text: "Conditions d'utilisation".tr,
                                style: TextStyle(color: Colors.green),
                              ),
                              TextSpan(text: " et la ".tr,),
                              TextSpan(
                                text: "Politique de confidentialité".tr,
                                style: TextStyle(color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )),
              const SizedBox(height: 16),

              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.signup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : Text("S'inscrire".tr,
                              style: TextStyle(fontSize: 16)),
                    ),
                  )),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text("Vous avez déjà un compte ? ".tr,),
                  GestureDetector(
                    onTap: () => Get.toNamed('/login'),
                    child:  Text(
                      "Se connecter".tr,
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _customInputField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          icon: Icon(icon),
          labelText: label,
          border: InputBorder.none,
          suffixIcon: suffix,
        ),
      ),
    );
  }
}

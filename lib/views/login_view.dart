import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olive_leaf_analyzer/controllers/login_controller.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    RxBool isPasswordHidden = true.obs;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF3EA),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),
                CircleAvatar(
                  radius: 60,
                  backgroundColor: const Color(0xFFEAF3EA),
                  child: Image.asset(
                    'assets/images/logo.jpg',
                    height: 125,
                  ),
                ),
                const SizedBox(height: 24),
                 Text(
                  'Connexion'.tr,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                 Text(
                  'Connectez-vous pour continuer'.tr,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // Email
                _customInputField(
                  icon: Icons.email_outlined,
                  label: 'Email'.tr,
                  controller: controller.emailController,
                ),
                const SizedBox(height: 16),

                // Password
                Obx(() => _customInputField(
                      icon: Icons.lock_outline,
                      label: 'Mot de passe'.tr,
                      controller: controller.passwordController,
                      obscureText: isPasswordHidden.value,
                      suffix: IconButton(
                        icon: Icon(
                          isPasswordHidden.value? Icons.visibility_off: Icons.visibility,
                        ),
                        onPressed: () =>
                            isPasswordHidden.value = !isPasswordHidden.value,
                      ),
                    )),
                const SizedBox(height: 8),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Get.toNamed('/reset'),
                    child:  Text(
                      'Mot de passe oublié?'.tr,
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Se connecter button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:  Text('Se connecter'.tr, style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 24),

                // Divider
                Row(
                  children:  [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('OU'.tr,),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 16),

                // Social icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: controller.signInWithGoogle,
                      child: _socialButton('assets/images/google.png'),
                    ),
                    const SizedBox(width: 20),
                    _socialButton('assets/images/logo_whatsapp.png'),
                  ],
                ),

                const SizedBox(height: 30),

                // Signup link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Vous n'avez pas de compte? ".tr,),
                    GestureDetector(
                      onTap: () => Get.toNamed('/signup'.tr,),
                      child:  Text(
                        "S'inscrire".tr,
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                )
              ],
            ),
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

  Widget _socialButton(String iconPath) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Image.asset(
        iconPath,
        height: 32,
        width: 32,
      ),
    );
  }
}

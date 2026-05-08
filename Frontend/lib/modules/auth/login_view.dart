import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_controller.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final AuthController controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Obx(() => Column( // غلفنا العمود بـ Obx ليتفاعل مع التغييرات
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.health_and_safety, size: 100, color: Colors.teal),
              const SizedBox(height: 20),
              Text(
                controller.isLoginMode.value ? 'تسجيل الدخول' : 'إنشاء حساب جديد',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              const SizedBox(height: 40),

              // 🆕 إظهار حقل الاسم فقط في وضع إنشاء الحساب
              if (!controller.isLoginMode.value) ...[
                TextField(
                  controller: controller.nameController,
                  decoration: InputDecoration(
                    labelText: 'الاسم الكامل',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              TextField(
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: controller.passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),

              // 🆕 إظهار حقل الوزن فقط في وضع إنشاء الحساب
              if (!controller.isLoginMode.value) ...[
                TextField(
                  controller: controller.weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'الوزن (كغ)',
                    prefixIcon: const Icon(Icons.monitor_weight),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 30),
              ],

              if (controller.isLoginMode.value) const SizedBox(height: 10),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: controller.isLoading.value ? null : controller.submit,
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        controller.isLoginMode.value ? 'دخول' : 'تسجيل', 
                        style: const TextStyle(fontSize: 18, color: Colors.white)
                      ),
              ),

              const SizedBox(height: 20),
              
              // 🆕 زر التبديل بين الدخول والإنشاء
              TextButton(
                onPressed: controller.toggleMode,
                child: Text(
                  controller.isLoginMode.value 
                    ? 'ليس لديك حساب؟ أنشئ حساباً جديداً' 
                    : 'لديك حساب بالفعل؟ سجل دخولك',
                  style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                ),
              )
            ],
          )),
        ),
      ),
    );
  }
}
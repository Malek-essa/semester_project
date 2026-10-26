import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/providers/api_provider.dart';

class AuthController extends GetxController {
  var isLoginMode = true.obs; 

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final weightController = TextEditingController();
  
  var isLoading = false.obs;
  final ApiProvider _apiProvider = ApiProvider();

  void toggleMode() {
    isLoginMode.value = !isLoginMode.value;
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    weightController.clear();
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('تنبيه', 'يرجى إدخال البريد الإلكتروني وكلمة المرور', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final response = await _apiProvider.login(email, password);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', response['token']);
      await prefs.setInt('user_id', response['user_id']);
      await prefs.setString('user_name', response['name']);
      
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('خطأ', e.toString().replaceAll('Exception: ', ''), backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final weightStr = weightController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || weightStr.isEmpty) {
      Get.snackbar('تنبيه', 'يرجى تعبئة كافة الحقول المطلوبة', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
      Get.snackbar('تنبيه', 'يرجى كتابة الاسم باللغة الإنجليزية فقط لتجنب أخطاء التقارير', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    final weight = double.tryParse(weightStr);
    if (weight == null || weight <= 0) {
      Get.snackbar('تنبيه', 'يرجى إدخال وزن صحيح بالأرقام', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      await _apiProvider.register(name, email, password, weight);
      Get.snackbar('نجاح 🎉', 'تم إنشاء الحساب بنجاح! جاري تسجيل الدخول...', backgroundColor: Colors.green, colorText: Colors.white);
      await login();
    } catch (e) {
      Get.snackbar('خطأ', e.toString().replaceAll('Exception: ', ''), backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void submit() {
    if (isLoginMode.value) {
      login();
    } else {
      register();
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    weightController.dispose();
    super.onClose();
  }
}
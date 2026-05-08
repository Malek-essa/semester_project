import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/providers/api_provider.dart';
import '../home/home_controller.dart';

class GoalsController extends GetxController {
  final waterGoalController = TextEditingController();
  final sleepGoalController = TextEditingController();
  
  var isLoading = false.obs;
  final ApiProvider _apiProvider = ApiProvider();

  @override
  void onInit() {
    super.onInit();
    _loadCurrentGoals();
  }

  // جلب الأهداف الحالية من HomeController لتسهيل التعديل على المستخدم
  void _loadCurrentGoals() {
    if (Get.isRegistered<HomeController>()) {
      final homeCtrl = Get.find<HomeController>();
      waterGoalController.text = homeCtrl.waterGoal.value.toString();
      sleepGoalController.text = homeCtrl.sleepGoal.value.toString();
    }
  }

  // دالة الحفظ
  Future<void> updateGoals() async {
    final waterStr = waterGoalController.text.trim();
    final sleepStr = sleepGoalController.text.trim();

    if (waterStr.isEmpty || sleepStr.isEmpty) {
      Get.snackbar('تنبيه', 'يرجى تعبئة كافة الحقول', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    final waterGoal = int.tryParse(waterStr);
    final sleepGoal = double.tryParse(sleepStr);

    if (waterGoal == null || waterGoal <= 0 || sleepGoal == null || sleepGoal <= 0) {
      Get.snackbar('تنبيه', 'يرجى إدخال أرقام صحيحة أكبر من الصفر', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final userId = prefs.getInt('user_id') ?? 0;

      // إرسال الطلب
      await _apiProvider.updateGoals(userId, token, waterGoal, sleepGoal);

      // إعادة ضبط مؤشرات التقدم بالشاشة الرئيسية فوراً
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().loadDashboardData();
      }

      Get.back(); // العودة للشاشة الرئيسية
      Get.snackbar('نجاح 🎯', 'تم تحديث الأهداف وإعادة حساب التقدم بنجاح', backgroundColor: Colors.green, colorText: Colors.white);

    } catch (e) {
      Get.snackbar('خطأ', e.toString(), backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    waterGoalController.dispose();
    sleepGoalController.dispose();
    super.onClose();
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';
import '../../data/providers/api_provider.dart';

class HomeController extends GetxController {
  var userName = ''.obs;
  var isLoading = true.obs;

  var waterCurrent = 0.obs;
  var waterGoal = 2000.obs; 
  var sleepCurrent = 0.0.obs;
  var sleepGoal = 8.0.obs; 

  var selectedSleepTime = Rxn<TimeOfDay>();
  var selectedWakeTime = Rxn<TimeOfDay>();

  var tipTitle = 'جاري التحليل...'.obs;
  var tipContent = 'يقوم المساعد الذكي بتحليل بياناتك...'.obs;

  final customWaterController = TextEditingController();

  // 🔥 قائمة المشروبات والمشروب المحدد حالياً
  var beverages = [].obs;
  var selectedBeverageId = 1.obs; // افتراضياً 1 = ماء

  final ApiProvider _apiProvider = ApiProvider();

  @override
  void onInit() {
    super.onInit();
    loadBeverages(); // تحميل المشروبات أولاً
    loadDashboardData();
  }

  // 🆕 دالة تحميل المشروبات من الذاكرة
  void loadBeverages() async {
    final prefs = await SharedPreferences.getInstance();
    final savedStr = prefs.getString('custom_beverages') ?? '[]';
    List savedList = jsonDecode(savedStr);
    
    // المشروب الأساسي دائماً موجود
    beverages.value = [{"id": 1, "name": "ماء"}];
    beverages.addAll(savedList);
  }

  void loadDashboardData() async {
    isLoading.value = true;
    final prefs = await SharedPreferences.getInstance();
    
    userName.value = prefs.getString('user_name') ?? 'مستخدم';
    final token = prefs.getString('token') ?? '';
    final userId = prefs.getInt('user_id') ?? 0; 

    String todayDate = DateTime.now().toString().split(' ')[0];

    try {
      final data = await _apiProvider.getDailyProgress(todayDate, token, userId);

      if (data['water_consumed_ml'] != null) waterCurrent.value = data['water_consumed_ml'];
      if (data['water_goal_ml'] != null) waterGoal.value = data['water_goal_ml'];
      if (data['sleep_hours_logged'] != null) sleepCurrent.value = (data['sleep_hours_logged']).toDouble();
      if (data['sleep_goal_hours'] != null) sleepGoal.value = (data['sleep_goal_hours']).toDouble();

      if (data['new_achievements'] != null) {
        List achievements = data['new_achievements'];
        if (achievements.isNotEmpty) {
          for (var badge in achievements) {
            Get.snackbar('إنجاز جديد! 🏆', badge.toString(), backgroundColor: Colors.amber.shade300, colorText: Colors.black87, duration: const Duration(seconds: 4), snackPosition: SnackPosition.TOP, margin: const EdgeInsets.all(15));
          }
        }
      }

      try {
        final tipData = await _apiProvider.getDailyTip(userId, token);
        tipTitle.value = tipData['tip_title'] ?? 'نصيحة اليوم';
        tipContent.value = tipData['tip_content'] ?? 'حافظ على أهدافك الصحية.';
      } catch (e) {
        tipTitle.value = 'نصيحة عامة';
        tipContent.value = 'شرب الماء بانتظام يحسن من صحة الجلد.';
      }

    } catch (e) {
      Get.snackbar('تنبيه', 'تعذر جلب البيانات التلقائية', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void logWater(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final userId = prefs.getInt('user_id') ?? 0;

    try {
      // 🔥 تمرير الـ selectedBeverageId
      final result = await _apiProvider.addWaterLog(amount, selectedBeverageId.value, token, userId);
      
      if (result['total_today'] != null) waterCurrent.value = result['total_today'];
      else waterCurrent.value += amount; 

      loadDashboardData();
      Get.snackbar('صحة وهنا! 💧', 'تم تسجيل الكمية بنجاح', backgroundColor: Colors.blue.shade100, colorText: Colors.blue.shade900, snackPosition: SnackPosition.TOP);
      
      // إعادة التعيين للماء كخيار افتراضي
      selectedBeverageId.value = 1;

    } catch (e) {
      Get.snackbar('خطأ التفاصيل:', e.toString(), backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> logSleep() async {
    if (selectedSleepTime.value == null || selectedWakeTime.value == null) {
      Get.snackbar('تنبيه', 'يرجى تحديد وقت النوم ووقت الاستيقاظ', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    final now = DateTime.now();
    var start = DateTime(now.year, now.month, now.day, selectedSleepTime.value!.hour, selectedSleepTime.value!.minute);
    var end = DateTime(now.year, now.month, now.day, selectedWakeTime.value!.hour, selectedWakeTime.value!.minute);

    if (start.isAfter(end)) start = start.subtract(const Duration(days: 1));

    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final userId = prefs.getInt('user_id') ?? 0;

      await _apiProvider.addSleepLog(start.toIso8601String(), end.toIso8601String(), token, userId);
      Get.back(); 
      loadDashboardData();
      Get.snackbar('نوم العوافي! 🌙', 'تم تسجيل ساعات النوم بنجاح', backgroundColor: Colors.indigo.shade100, colorText: Colors.indigo.shade900, snackPosition: SnackPosition.TOP);
    } catch (e) {
      Get.snackbar('خطأ', e.toString(), backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
      selectedSleepTime.value = null;
      selectedWakeTime.value = null;
    }
  }

  Future<void> exportWeeklyReport() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final userId = prefs.getInt('user_id') ?? 0;

      final response = await _apiProvider.exportReport(userId, token);
      final downloadUrl = response['download_url'];
      
      final fullUrl = AppConstants.baseUrl.replaceAll('/api', '') + downloadUrl;

      Get.defaultDialog(
        title: "تم تجهيز التقرير 📄",
        titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
        content: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const Text("تم إنشاء التقرير الأسبوعي بصيغة PDF بنجاح.", textAlign: TextAlign.center),
              const SizedBox(height: 15),
              SelectableText(fullUrl, style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline), textAlign: TextAlign.center),
              const SizedBox(height: 10),
              const Text("(يمكنك نسخ الرابط أو إضافته لمتصفحك لعرض التقرير)", style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        textConfirm: "حسناً",
        confirmTextColor: Colors.white,
        buttonColor: Colors.teal,
        onConfirm: () => Get.back(),
      );

    } catch (e) {
      Get.snackbar('خطأ', 'فشل استخراج التقرير', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); 
    Get.offAllNamed('/login'); 
  }

  @override
  void onClose() {
    customWaterController.dispose();
    super.onClose();
  }
}
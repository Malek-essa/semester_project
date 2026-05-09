import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/providers/api_provider.dart';
import '../home/home_controller.dart';

class HistoryController extends GetxController {
  var logs = [].obs;
  var isLoading = true.obs;
  final ApiProvider _apiProvider = ApiProvider();

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  void fetchHistory() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final userId = prefs.getInt('user_id') ?? 0;

      final response = await _apiProvider.getHistoryLogs(userId, token);
      logs.value = response['history'] ?? [];
    } catch (e) {
      Get.snackbar('خطأ', 'تعذر جلب السجل', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void updateLogEntry(String type, int id, double newValue) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      await _apiProvider.updateLog(type, id, newValue, token);
      
      Get.back(); 
      fetchHistory(); 
      
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().loadDashboardData();
      }
      
      Get.snackbar('نجاح', 'تم تعديل السجل بنجاح', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('خطأ', 'فشل التعديل، حاول مرة أخرى', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  void deleteLogEntry(String type, int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      await _apiProvider.deleteLog(type, id, token);
      
      Get.back(); 
      fetchHistory(); 
      
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().loadDashboardData();
      }
      
      Get.snackbar('نجاح', 'تم حذف السجل نهائياً', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('خطأ', 'فشل الحذف، حاول مرة أخرى', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }
}
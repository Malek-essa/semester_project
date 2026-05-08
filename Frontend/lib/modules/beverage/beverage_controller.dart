import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/providers/api_provider.dart';
import '../home/home_controller.dart';

class BeverageController extends GetxController {
  final nameController = TextEditingController();
  final factorController = TextEditingController();
  
  var isLoading = false.obs;
  final ApiProvider _apiProvider = ApiProvider();

  Future<void> saveBeverage() async {
    final name = nameController.text.trim();
    final factorStr = factorController.text.trim();

    if (name.isEmpty || factorStr.isEmpty) {
      Get.snackbar('تنبيه', 'يرجى إدخال اسم المشروب ومعامل الترطيب', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    final factor = double.tryParse(factorStr);
    if (factor == null || factor <= 0 || factor > 2) {
      Get.snackbar('تنبيه', 'معامل الترطيب يجب أن يكون رقماً (مثال: 0.8)', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await _apiProvider.addCustomBeverage(name, factor, token);
      
      // 🔥 حفظ المشروب محلياً لعرضه في شاشة الرئيسية
      final savedStr = prefs.getString('custom_beverages') ?? '[]';
      List savedList = jsonDecode(savedStr);
      savedList.add(response['beverage']); // الباك إند بيرجع كائن المشروب
      await prefs.setString('custom_beverages', jsonEncode(savedList));

      // تحديث قائمة المشروبات في الشاشة الرئيسية فوراً
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().loadBeverages();
      }
      
      Get.back();
      Get.snackbar('نجاح ☕', 'تمت إضافة مشروب "$name" بنجاح!', backgroundColor: Colors.green, colorText: Colors.white);

    } catch (e) {
      Get.snackbar('خطأ', e.toString(), backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    factorController.dispose();
    super.onClose();
  }
}
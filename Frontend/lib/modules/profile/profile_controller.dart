import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/providers/api_provider.dart';
import '../home/home_controller.dart';

class ProfileController extends GetxController {
  final nameController = TextEditingController();
  final weightController = TextEditingController();
  
  var bedTime = Rxn<TimeOfDay>();
  var wakeupTime = Rxn<TimeOfDay>();

  var isLoading = false.obs;
  final ApiProvider _apiProvider = ApiProvider();

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  void _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    nameController.text = prefs.getString('user_name') ?? '';
  }

  Future<void> pickTime(BuildContext context, bool isBedTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: Colors.teal)),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isBedTime) {
        bedTime.value = picked;
      } else {
        wakeupTime.value = picked;
      }
    }
  }

  String _formatTime(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  Future<void> saveProfile() async {
    final name = nameController.text.trim();
    final weightStr = weightController.text.trim();

    if (name.isEmpty || weightStr.isEmpty || bedTime.value == null || wakeupTime.value == null) {
      Get.snackbar('تنبيه', 'يرجى تعبئة كافة الحقول وتحديد أوقات النوم', 
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
      Get.snackbar('تنبيه', 'يرجى كتابة الاسم باللغة الإنجليزية فقط لتجنب أخطاء التقارير', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    final weight = double.tryParse(weightStr);
    if (weight == null || weight <= 0) {
      Get.snackbar('تنبيه', 'الوزن يجب أن يكون رقماً صحيحاً', 
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final userId = prefs.getInt('user_id') ?? 0;

      await _apiProvider.updateProfile(
        userId, token, name, weight, 
        _formatTime(bedTime.value!), _formatTime(wakeupTime.value!)
      );

      await prefs.setString('user_name', name);

      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().userName.value = name; 
        Get.find<HomeController>().loadDashboardData();
      }

      Get.back();
      Get.snackbar('نجاح 🎉', 'تم تحديث الملف الشخصي بنجاح', 
          backgroundColor: Colors.green, colorText: Colors.white);

    } catch (e) {
      Get.snackbar('خطأ', e.toString(), backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
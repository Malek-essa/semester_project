import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/providers/api_provider.dart';

class FastingController extends GetxController {
  var isFastingModeActive = false.obs;
  var isLoading = false.obs;
  
  var startTime = Rxn<TimeOfDay>();
  final durationController = TextEditingController();

  final ApiProvider _apiProvider = ApiProvider();

  @override
  void onInit() {
    super.onInit();
    _loadFastingState();
  }

  void _loadFastingState() async {
    final prefs = await SharedPreferences.getInstance();
    isFastingModeActive.value = prefs.getBool('is_fasting_mode') ?? false;
  }

  void toggleSwitch(bool value) {
    isFastingModeActive.value = value;
    if (!value) {
      saveFastingSettings();
    }
  }

  Future<void> pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 4, minute: 30), 
    );
    if (picked != null) {
      startTime.value = picked;
    }
  }

  String? _formatTime(TimeOfDay? time) {
    if (time == null) return null;
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  Future<void> saveFastingSettings() async {
    int? duration;
    if (isFastingModeActive.value) {
      if (startTime.value == null || durationController.text.trim().isEmpty) {
        Get.snackbar('تنبيه', 'يرجى تحديد وقت البدء وعدد ساعات الصيام', backgroundColor: Colors.redAccent, colorText: Colors.white);
        return;
      }
      duration = int.tryParse(durationController.text.trim());
      if (duration == null || duration <= 0 || duration > 24) {
        Get.snackbar('تنبيه', 'عدد الساعات غير منطقي', backgroundColor: Colors.redAccent, colorText: Colors.white);
        return;
      }
    }

    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final userId = prefs.getInt('user_id') ?? 0;

      final response = await _apiProvider.toggleFasting(
        userId, 
        token, 
        isFastingModeActive.value, 
        _formatTime(startTime.value), 
        duration
      );

      await prefs.setBool('is_fasting_mode', response['is_fasting'] ?? isFastingModeActive.value);

      Get.back();
      Get.snackbar(
        isFastingModeActive.value ? 'صوماً مقبولاً 🌙' : 'تم الإيقاف', 
        isFastingModeActive.value ? 'تم تفعيل وضع الصيام بنجاح وجدولة الإشعارات.' : 'تم إيقاف وضع الصيام.', 
        backgroundColor: isFastingModeActive.value ? Colors.indigo.shade300 : Colors.grey, 
        colorText: Colors.white
      );

    } catch (e) {
      Get.snackbar('خطأ', e.toString(), backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    durationController.dispose();
    super.onClose();
  }
}
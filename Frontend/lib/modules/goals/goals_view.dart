import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'goals_controller.dart';

class GoalsView extends StatelessWidget {
  GoalsView({super.key});

  final GoalsController controller = Get.put(GoalsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('تعديل الأهداف 🎯'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.track_changes, size: 80, color: Colors.teal),
            const SizedBox(height: 30),
            const Text(
              'حدد أهدافك اليومية بدقة لتتناسب مع نشاطك الحالي',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // حقل هدف الماء
            TextField(
              controller: controller.waterGoalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'الهدف اليومي للماء (مل)',
                prefixIcon: const Icon(Icons.water_drop, color: Colors.blue),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            // حقل هدف النوم
            TextField(
              controller: controller.sleepGoalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'الهدف اليومي للنوم (ساعات)',
                prefixIcon: const Icon(Icons.bedtime, color: Colors.indigo),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 40),

            // زر التحديث
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: controller.isLoading.value ? null : controller.updateGoals,
              child: controller.isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('تحديث الهدف', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        )),
      ),
    );
  }
}
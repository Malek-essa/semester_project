import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'beverage_controller.dart';

class BeverageView extends StatelessWidget {
  BeverageView({super.key});

  final BeverageController controller = Get.put(BeverageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('تخصيص المشروبات ☕'),
        centerTitle: true,
        backgroundColor: Colors.brown.shade400,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.local_cafe, size: 80, color: Colors.brown.shade400),
            const SizedBox(height: 20),
            const Text(
              'أضف مشروباتك المفضلة وحدد نسبة ترطيبها.\n(الماء = 1.0 ، القهوة = 0.8 مثلاً)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 40),

            TextField(
              controller: controller.nameController,
              decoration: InputDecoration(
                labelText: 'اسم المشروب (مثال: شاي أخضر)',
                prefixIcon: const Icon(Icons.coffee_maker, color: Colors.brown),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: controller.factorController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'معامل الترطيب (مثال: 0.85)',
                prefixIcon: const Icon(Icons.percent, color: Colors.brown),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 40),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.brown.shade400,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: controller.isLoading.value ? null : controller.saveBeverage,
              child: controller.isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('إضافة المشروب', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        )),
      ),
    );
  }
}
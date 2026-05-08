import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'fasting_controller.dart';

class FastingView extends StatelessWidget {
  FastingView({super.key});

  final FastingController controller = Get.put(FastingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('وضع الصيام 🌙'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.nightlight_round, size: 80, color: Colors.indigo),
            const SizedBox(height: 20),
            const Text(
              'تفعيل وضع الصيام يقوم بإيقاف تنبيهات شرب الماء نهاراً وتكثيفها خلال فترة الإفطار.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 40),

            // زر التفعيل (Switch)
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 2,
              child: SwitchListTile(
                title: const Text('تفعيل وضع الصيام', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                subtitle: Text(controller.isFastingModeActive.value ? 'نشط' : 'متوقف', style: TextStyle(color: controller.isFastingModeActive.value ? Colors.indigo : Colors.grey)),
                activeColor: Colors.indigo,
                value: controller.isFastingModeActive.value,
                onChanged: controller.toggleSwitch,
                secondary: const Icon(Icons.restaurant_menu),
              ),
            ),
            const SizedBox(height: 30),

            // تظهر الخيارات فقط إذا كان الوضع مفعلاً
            if (controller.isFastingModeActive.value) ...[
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.indigo.shade200)),
                leading: const Icon(Icons.access_time, color: Colors.indigo),
                title: const Text('وقت بدء الصيام (الإمساك)'),
                trailing: Text(
                  controller.startTime.value?.format(context) ?? 'حدد الوقت',
                  style: TextStyle(fontWeight: FontWeight.bold, color: controller.startTime.value == null ? Colors.red : Colors.black),
                ),
                onTap: () => controller.pickTime(context),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: controller.durationController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'مدة الصيام (بالساعات)',
                  prefixIcon: const Icon(Icons.hourglass_bottom, color: Colors.indigo),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 40),
            ],

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.indigo,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: controller.isLoading.value ? null : controller.saveFastingSettings,
              child: controller.isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('حفظ الإعدادات', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        )),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'profile_controller.dart';

class ProfileView extends StatelessWidget {
  ProfileView({super.key});

  final ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('إدارة الملف الشخصي ⚙️'),
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
            const Icon(Icons.account_circle, size: 80, color: Colors.teal),
            const SizedBox(height: 30),

            TextField(
              controller: controller.nameController,
              decoration: InputDecoration(
                labelText: 'الاسم الكامل',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: controller.weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'الوزن (كغ)',
                prefixIcon: const Icon(Icons.monitor_weight),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 30),

            // أزرار اختيار الوقت
            Row(
              children: [
                Expanded(
                  child: _buildTimePickerCard(
                    context, 
                    title: 'وقت النوم المعتاد', 
                    icon: Icons.bedtime, 
                    time: controller.bedTime.value, 
                    onTap: () => controller.pickTime(context, true)
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildTimePickerCard(
                    context, 
                    title: 'وقت الاستيقاظ', 
                    icon: Icons.wb_sunny, 
                    time: controller.wakeupTime.value, 
                    onTap: () => controller.pickTime(context, false)
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: controller.isLoading.value ? null : controller.saveProfile,
              child: controller.isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('حفظ التعديلات', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        )),
      ),
    );
  }

  // كارد مساعد لاختيار الوقت بشكل أنيق
  Widget _buildTimePickerCard(BuildContext context, {required String title, required IconData icon, required TimeOfDay? time, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.teal.shade200),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, spreadRadius: 1)],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.teal, size: 30),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 5),
            Text(
              time != null ? time.format(context) : 'حدد الوقت',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: time != null ? Colors.black : Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
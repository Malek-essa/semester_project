import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'home_controller.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("مراقبة التقدم اليومي 📊"), 
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ترويسة القائمة (Header)
            Obx(() => UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.teal),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.teal),
              ),
              accountName: Text(
                controller.userName.value, 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
              accountEmail: const Text('المساعد الصحي الذكي'),
            )),
            
            ListTile(
              leading: const Icon(Icons.person, color: Colors.teal),
              title: const Text('الملف الشخصي', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Get.back(); 
                Get.toNamed('/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.track_changes, color: Colors.blue),
              title: const Text('تعديل الأهداف', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Get.back();
                Get.toNamed('/goals');
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.orange),
              title: const Text('سجل التاريخ', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Get.back();
                Get.toNamed('/history');
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_cafe, color: Colors.brown),
              title: const Text('تخصيص المشروبات', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Get.back();
                Get.toNamed('/beverage');
              },
            ),
            ListTile(
              leading: const Icon(Icons.nightlight_round, color: Colors.indigo),
              title: const Text('وضع الصيام', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Get.back();
                Get.toNamed('/fasting');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
              title: const Text('تصدير التقرير الأسبوعي', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Get.back();
                controller.exportWeeklyReport();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.grey),
              title: const Text('تسجيل الخروج', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: controller.logout,
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.water_drop),
        label: const Text('إضافة ماء', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _showWaterLogSheet(context),
      ), 
      
      body: Obx(() {
        if (controller.isLoading.value && controller.waterGoal.value == 2000 && controller.waterCurrent.value == 0) {
          return const Center(child: CircularProgressIndicator(color: Colors.teal));
        }

        double waterPercent = controller.waterGoal.value > 0 ? (controller.waterCurrent.value / controller.waterGoal.value).clamp(0.0, 1.0) : 0.0;
        double sleepPercent = controller.sleepGoal.value > 0 ? (controller.sleepCurrent.value / controller.sleepGoal.value).clamp(0.0, 1.0) : 0.0;

        return RefreshIndicator(
          onRefresh: () async => controller.loadDashboardData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'مرحباً بك يا ${controller.userName.value}',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
                const SizedBox(height: 30),
                
                _buildProgressCard(
                  title: 'استهلاك الماء', icon: Icons.water_drop, color: Colors.blue, 
                  percent: waterPercent, currentText: '${controller.waterCurrent.value} مل', goalText: 'من ${controller.waterGoal.value} مل'
                ),
                const SizedBox(height: 20),

                _buildProgressCard(
                  title: 'ساعات النوم', icon: Icons.bedtime, color: Colors.indigo, 
                  percent: sleepPercent, currentText: '${controller.sleepCurrent.value} ساعة', goalText: 'من ${controller.sleepGoal.value} ساعات',
                  actionBtnText: "إضافة سجل نوم",
                  onActionPressed: () => _showSleepLogSheet(context), 
                ),
                const SizedBox(height: 20),

                Card(
                  elevation: 2,
                  color: Colors.teal.shade50,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: const Icon(Icons.lightbulb, color: Colors.amber, size: 30),
                    title: Text(controller.tipTitle.value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                    subtitle: Text(controller.tipContent.value, style: const TextStyle(height: 1.5)),
                  ),
                ),
                const SizedBox(height: 60), 
              ],
            ),
          ),
        );
      }),
    );
  }

  void _showWaterLogSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('ماذا شربت للتو؟', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            
            Obx(() => Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: controller.beverages.map((bev) {
                bool isSelected = controller.selectedBeverageId.value == bev['id'];
                return ChoiceChip(
                  label: Text(bev['name'], style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
                  selected: isSelected,
                  selectedColor: Colors.blue,
                  backgroundColor: Colors.grey.shade200,
                  onSelected: (selected) {
                    if (selected) controller.selectedBeverageId.value = bev['id'];
                  },
                );
              }).toList(),
            )),

            const SizedBox(height: 24),
            const Text('حدد الكمية:', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 15),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade100, foregroundColor: Colors.blue.shade900),
                  onPressed: () { controller.logWater(250); Get.back(); },
                  child: const Text('كوب (250 مل)'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  onPressed: () { controller.logWater(500); Get.back(); },
                  child: const Text('قارورة (500 مل)'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.customWaterController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'إدخال يدوي (مل)',
                      prefixIcon: const Icon(Icons.edit, color: Colors.blue),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final val = int.tryParse(controller.customWaterController.text);
                    if (val != null && val > 0) {
                      controller.logWater(val);
                      controller.customWaterController.clear();
                      Get.back();
                    } else {
                      Get.snackbar('خطأ', 'يرجى إدخال كمية صحيحة', backgroundColor: Colors.redAccent, colorText: Colors.white);
                    }
                  },
                  child: const Text('إضافة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )
              ],
            )
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showSleepLogSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Obx(() => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('تسجيل ساعات النوم', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo)),
            const SizedBox(height: 24),
            
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.indigo.shade200)),
              leading: const Icon(Icons.bed, color: Colors.indigo),
              title: const Text('وقت النوم'),
              trailing: Text(
                controller.selectedSleepTime.value?.format(context) ?? 'حدد الوقت',
                style: TextStyle(fontWeight: FontWeight.bold, color: controller.selectedSleepTime.value == null ? Colors.red : Colors.black),
              ),
              onTap: () async {
                final time = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 23, minute: 0));
                if (time != null) controller.selectedSleepTime.value = time;
              },
            ),
            const SizedBox(height: 15),

            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.orange.shade200)),
              leading: const Icon(Icons.wb_sunny, color: Colors.orange),
              title: const Text('وقت الاستيقاظ'),
              trailing: Text(
                controller.selectedWakeTime.value?.format(context) ?? 'حدد الوقت',
                style: TextStyle(fontWeight: FontWeight.bold, color: controller.selectedWakeTime.value == null ? Colors.red : Colors.black),
              ),
              onTap: () async {
                final time = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 7, minute: 0));
                if (time != null) controller.selectedWakeTime.value = time;
              },
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: controller.isLoading.value ? null : () => controller.logSleep(),
              child: controller.isLoading.value 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('تسجيل', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        )),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildProgressCard({required String title, required IconData icon, required Color color, required double percent, required String currentText, required String goalText, String? actionBtnText, VoidCallback? onActionPressed}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            CircularPercentIndicator(
              radius: 70.0, lineWidth: 12.0, animation: true, percent: percent,
              center: Text("${(percent * 100).toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
              circularStrokeCap: CircularStrokeCap.round, progressColor: color, backgroundColor: color.withOpacity(0.1),
            ),
            const SizedBox(height: 15),
            Text(currentText, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(goalText, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            
            if (actionBtnText != null && onActionPressed != null) ...[
              const SizedBox(height: 15),
              TextButton.icon(
                onPressed: onActionPressed,
                icon: Icon(Icons.add_circle_outline, color: color),
                label: Text(actionBtnText, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
              )
            ]
          ],
        ),
      ),
    );
  }
}
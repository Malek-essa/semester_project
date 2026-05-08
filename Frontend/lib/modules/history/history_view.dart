import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'history_controller.dart';

class HistoryView extends StatelessWidget {
  HistoryView({super.key});

  final HistoryController controller = Get.put(HistoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('سجل التاريخ ⏳'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.teal));
        }

        if (controller.logs.isEmpty) {
          return const Center(child: Text('لا توجد سجلات سابقة بعد', style: TextStyle(fontSize: 18, color: Colors.grey)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.logs.length,
          itemBuilder: (context, index) {
            final log = controller.logs[index];
            final isWater = log['type'] == 'water';
            
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isWater ? Colors.blue.shade100 : Colors.indigo.shade100,
                  child: Icon(
                    isWater ? Icons.water_drop : Icons.bedtime,
                    color: isWater ? Colors.blue : Colors.indigo,
                  ),
                ),
                title: Text(isWater ? 'استهلاك ماء' : 'ساعات نوم', style: const TextStyle(fontWeight: FontWeight.bold)),
                // 🔥 التعديل هنا: استخدام "عدد الساعات" للنوم و"الكمية" للماء
                subtitle: Text(
                  "${log['date']} ${log['time'] != null ? ' - ${log['time']}' : ''}\n${isWater ? 'الكمية:' : 'عدد الساعات:'} ${log['value']} ${isWater ? 'مل' : 'ساعة'}",
                  style: const TextStyle(color: Colors.grey),
                ),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () => _showEditDialog(context, log['type'], log['log_id'], log['value'].toDouble(), isWater),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteConfirmation(context, log['type'], log['log_id']),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _showEditDialog(BuildContext context, String type, int logId, double currentValue, bool isWater) {
    final TextEditingController valueController = TextEditingController(text: currentValue.toString());
    
    Get.defaultDialog(
      title: "تعديل السجل",
      titleStyle: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: valueController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: isWater ? 'الكمية الجديدة (مل)' : 'الساعات الجديدة',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      textConfirm: "حفظ",
      textCancel: "إلغاء",
      confirmTextColor: Colors.white,
      buttonColor: Colors.teal,
      onConfirm: () {
        final double? newValue = double.tryParse(valueController.text);
        if (newValue != null && newValue > 0) {
          controller.updateLogEntry(type, logId, newValue);
        } else {
          Get.snackbar('خطأ', 'يرجى إدخال رقم صحيح', backgroundColor: Colors.redAccent, colorText: Colors.white);
        }
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, String type, int logId) {
    Get.defaultDialog(
      title: "تأكيد الحذف",
      titleStyle: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      middleText: "هل أنت متأكد من رغبتك في حذف هذا السجل نهائياً؟",
      textConfirm: "نعم، احذف",
      textCancel: "تراجع",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () => controller.deleteLogEntry(type, logId),
    );
  }
}
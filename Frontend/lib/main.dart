import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 🆕 استدعاء مكتبة الذاكرة المحلية
import 'data/providers/api_provider.dart'; // 🆕 استدعاء مزود الـ API الخاص بنا

import 'modules/auth/login_view.dart';
import 'routes/app_pages.dart';

@pragma('vm:entry-point')
Future<void> backgroundCallback(Uri? uri) async {
  if (uri?.host == 'addwater') {
    // جلب بيانات المستخدم من الذاكرة المحلية
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getInt('user_id');

    if (token != null && userId != null) {
      try {
        final api = ApiProvider();
        // تسجيل 250 مل ماء (نعتبر المشروب رقم 1 هو الماء)
        await api.addWaterLog(250, 1, token, userId);
        debugPrint("💧 تم تسجيل الماء من الويدجت بنجاح!"); // استخدمنا debugPrint لتجنب تحذيرات الـ Linter
      } catch (e) {
        debugPrint("❌ خطأ من الويدجت: $e");
      }
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HomeWidget.registerBackgroundCallback(backgroundCallback);
  runApp(const SmartHealthApp());
}

class SmartHealthApp extends StatelessWidget {
  const SmartHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false, 
      title: 'المساعد الصحي الذكي',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        fontFamily: 'Cairo', 
      ),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}

// ==========================================
// شاشة رئيسية مؤقتة للتجربة (يمكنك حذفها لاحقاً إذا لم تعودي بحاجة لها)
// ==========================================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المساعد الصحي الذكي 💧🌙'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'أهلاً بك يا مهندس في الفرونت إند! 🚀',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.snackbar(
                  'إشعار ذكي',
                  'تم الربط مع GetX بنجاح، التطبيق جاهز للعمل!',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.teal,
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(15),
                );
              },
              child: const Text('جربني!'),
            ),
          ],
        ),
      ),
    );
  }
}
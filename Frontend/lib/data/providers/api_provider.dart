import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';

class ApiProvider {

  
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('${AppConstants.baseUrl}/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body); 
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'فشل تسجيل الدخول');
      }
    } catch (e) {
      throw Exception('تأكد من تشغيل الخادم - $e');
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password, double weight) async {
    final url = Uri.parse('${AppConstants.baseUrl}/auth/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'weight': weight,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body); 
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'فشل إنشاء الحساب');
      }
    } catch (e) {
      throw Exception('تأكد من تشغيل الخادم - $e');
    }
  }



  Future<Map<String, dynamic>> updateProfile(int userId, String token, String name, double weight, String bedTime, String wakeupTime) async {
    final url = Uri.parse('${AppConstants.baseUrl}/user/profile?user_id=$userId');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'name': name, 'weight': weight, 'bed_time': bedTime, 'wakeup_time': wakeupTime}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body); 
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('السبب من الباك إند: ${errorData['detail']}');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  Future<Map<String, dynamic>> updateGoals(int userId, String token, int waterGoal, double sleepGoal) async {
    final url = Uri.parse('${AppConstants.baseUrl}/user/goals?user_id=$userId');
    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'water_goal_ml': waterGoal, 'sleep_goal_hours': sleepGoal}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('السبب من الباك إند: ${errorData['detail']}');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }


  Future<Map<String, dynamic>> toggleFasting(int userId, String token, bool isActive, String? startTime, int? durationHours) async {
    final url = Uri.parse('${AppConstants.baseUrl}/user/fasting?user_id=$userId');
    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({
          'is_active': isActive,
          'start_time': startTime,
          'duration_hours': durationHours,
        }),
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      final errorData = jsonDecode(response.body); throw Exception('السبب من الباك إند: ${errorData['detail']}');
    } catch (e) { throw Exception('$e'); }
  }





  Future<Map<String, dynamic>> getDailyProgress(String date, String token, int userId) async {
    final url = Uri.parse('${AppConstants.baseUrl}/user/progress?date=$date&user_id=$userId');
    try {
      final response = await http.get(url, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('السبب من الباك إند: ${errorData['detail']}');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  Future<Map<String, dynamic>> addWaterLog(int amountMl, int beverageId, String token, int userId) async {
    final url = Uri.parse('${AppConstants.baseUrl}/water/add?user_id=$userId');
    final now = DateTime.now();
    final date = now.toString().split(' ')[0];
    final time = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'amount_ml': amountMl, 'beverage_id': beverageId, 'date': date, 'time': time}),
      );
      if (response.statusCode == 200) return jsonDecode(response.body); 
      final errorData = jsonDecode(response.body); throw Exception('السبب من الباك إند: ${errorData['detail']}');
    } catch (e) { throw Exception('$e'); }
  }

  Future<Map<String, dynamic>> addSleepLog(String startTime, String endTime, String token, int userId) async {
    final url = Uri.parse('${AppConstants.baseUrl}/sleep/add?user_id=$userId');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({
          'start_time': startTime,
          'end_time': endTime,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body); 
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('السبب من الباك إند: ${errorData['detail']}');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  Future<Map<String, dynamic>> getDailyTip(int userId, String token) async {
    final url = Uri.parse('${AppConstants.baseUrl}/user/tips?user_id=$userId');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('فشل جلب النصيحة');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

 
  Future<Map<String, dynamic>> getHistoryLogs(int userId, String token) async {
    final url = Uri.parse('${AppConstants.baseUrl}/logs/history/$userId');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('فشل جلب السجل');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  Future<Map<String, dynamic>> updateLog(String logType, int logId, double newValue, String token) async {
    final url = Uri.parse('${AppConstants.baseUrl}/logs/update');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'log_type': logType, 'log_id': logId, 'new_value': newValue}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('فشل التعديل');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  Future<Map<String, dynamic>> deleteLog(String logType, int logId, String token) async {
    final url = Uri.parse('${AppConstants.baseUrl}/logs/delete?log_type=$logType&log_id=$logId');
    try {
      final response = await http.delete(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('فشل الحذف');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  Future<Map<String, dynamic>> addCustomBeverage(String name, double factor, String token) async {
    final url = Uri.parse('${AppConstants.baseUrl}/beverages/custom');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'name': name, 'hydration_factor': factor}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('السبب من الباك إند: ${errorData['detail'] ?? "خطأ غير معروف"}');
      }
    } catch (e) {
      throw Exception('$e');
    }
  } 

  Future<Map<String, dynamic>> exportReport(int userId, String token) async {
    final url = Uri.parse('${AppConstants.baseUrl}/reports/export?user_id=$userId&format=pdf');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('فشل استخراج التقرير');
    } catch (e) { throw Exception('$e'); }
  }

  
}
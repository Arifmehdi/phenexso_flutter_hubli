import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hubli/models/notification.dart';
import 'package:hubli/utils/api_constants.dart';

class NotificationService {
  final String? token;

  NotificationService(this.token);

  Future<List<NotificationModel>> fetchNotifications() async {
    final response = await http.get(
      Uri.parse(ApiConstants.notificationsEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final List<dynamic> notificationsData = responseData['notifications']['data'] ?? responseData['notifications'];
      return notificationsData.map((data) => NotificationModel.fromJson(data)).toList();
    } else {
      print('Notification API Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to fetch notifications: ${response.statusCode}');
    }
  }

  Future<void> markAsRead(int id) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.notificationsEndpoint}/read/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark notification as read');
    }
  }

  Future<void> markAllRead() async {
    final response = await http.post(
      Uri.parse('${ApiConstants.notificationsEndpoint}/read-all'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark all notifications as read');
    }
  }
}

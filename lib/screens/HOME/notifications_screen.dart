import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import '/config.dart';

class NotificationsScreen extends StatefulWidget {
  final Function(int)? onNotificationCountChanged;

  const NotificationsScreen({Key? key, this.onNotificationCountChanged}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _userId = '';

  static const Color primaryColor = Color(0xFF277DA1);
  static const Color backgroundColor = Color(0xFFFFFFFB);

  @override
  void initState() {
    super.initState();
    _loadUserAndFetchNotifications();
  }

  Future<void> _loadUserAndFetchNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null && token.isNotEmpty && !JwtDecoder.isExpired(token)) {
        Map<String, dynamic> payload = JwtDecoder.decode(token);
        _userId = payload['userId']?.toString() ?? payload['id']?.toString() ?? '';

        if (_userId.isEmpty) throw Exception('User ID not found in token.');

        await _fetchNotifications();
      } else {
        throw Exception('Token is missing or invalid.');
      }
    } catch (e) {
      print('🚨 Error loading user and fetching notifications: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = '⚠️ Error verifying user: ${e.toString()}';
      });
    }
  }

  Future<void> _fetchNotifications() async {
    if (_userId.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = '⚠️ User ID not found.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final response = await http.get(
        Uri.parse('${Config.baseUrl}/notif/notifications/$_userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['notifications'] != null) {
          List<Map<String, dynamic>> loaded =
          List<Map<String, dynamic>>.from(data['notifications']);

          loaded.sort((a, b) {
            try {
              DateTime dateA = DateTime.parse(a['createdAt']);
              DateTime dateB = DateTime.parse(b['createdAt']);
              return dateB.compareTo(dateA);
            } catch (_) {
              return 0;
            }
          });

          int unreadCount = loaded.where((notif) => !(notif['isRead'] ?? true)).length;

          setState(() {
            _notifications = loaded;
            _isLoading = false;
          });

          widget.onNotificationCountChanged?.call(unreadCount);

          await _markAllNotificationsAsRead();
          widget.onNotificationCountChanged?.call(0);
        } else {
          throw Exception('No data available.');
        }
      } else {
        throw Exception('Failed to connect to server: ${response.statusCode}');
      }
    } catch (e) {
      print('🚨 Error fetching notifications: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = '⚠️ Error fetching notifications: ${e.toString()}';
      });
    }
  }

  Future<void> _markAllNotificationsAsRead() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final response = await http.patch(
        Uri.parse('${Config.baseUrl}/notif/notifications/mark-all-read/$_userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('✅ All notifications marked as read.');
      } else {
        print('❌ Failed to mark notifications as read: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error marking notifications as read: $e');
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final response = await http.delete(
        Uri.parse('${Config.baseUrl}/notif/notifications/$notificationId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Successfully deleted, refresh the notification list
        _fetchNotifications();
      } else {
        throw Exception('Failed to delete notification');
      }
    } catch (e) {
      print('❌ Error deleting notification: $e');
      setState(() {
        _errorMessage = '⚠️ Error deleting notification: ${e.toString()}';
      });
    }
  }

  Future<void> _showDeleteConfirmationDialog(String notificationId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'تأكيد الحذف',
            textAlign: TextAlign.right, // Align title to the right
          ),
          content: const Text(
            'هل أنت متأكد أنك تريد حذف هذه الإشعار؟',
            textAlign: TextAlign.right, // Align content to the right
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'إلغاء',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _deleteNotification(notificationId); // Delete the notification
              },
              child: const Text(
                'حذف',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Container(
            decoration: const BoxDecoration(
              color: backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  const Center(
                    child: Text(
                      'الإشعارات',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF277DA1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
            ? Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.red),
            ),
          ),
        )
            : RefreshIndicator(
          onRefresh: _fetchNotifications,
          child: _notifications.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.notifications_off, size: 80, color: Colors.grey),
                SizedBox(height: 20),
                Text(
                  'لا توجد إشعارات حالياً',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: _notifications.length,
            itemBuilder: (context, index) {
              final notif = _notifications[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F1F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notif['createdAt']?.substring(0, 16) ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            notif['message'] ?? 'لديك إشعار جديد.',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        String notificationId = notif['_id']; // Assuming '_id' is the identifier for the notification
                        _showDeleteConfirmationDialog(notificationId);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

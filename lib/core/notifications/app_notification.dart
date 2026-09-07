import 'dart:convert';

/// A Paned-owned notification record (not Android system history).
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.type,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final String type;
  final bool isRead;

  static const typeDailyReminder = 'daily_reminder';

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      createdAt: createdAt,
      type: type,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
        'type': type,
        'isRead': isRead,
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      type: json['type'] as String? ?? typeDailyReminder,
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  static String encodeList(List<AppNotification> items) =>
      jsonEncode(items.map((e) => e.toJson()).toList());

  static List<AppNotification> decodeList(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }
}

/// Mirrors `profiles` / user document fields (camelCase).
class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    required this.avatarEmoji,
    required this.dialect,
    required this.dailyGoal,
  });

  final String id;
  final String displayName;
  final String avatarEmoji;
  final String dialect;
  final int dailyGoal;

  factory UserProfile.fromMap(Map<String, dynamic> data, String id) {
    return UserProfile(
      id: id,
      displayName: data['displayName'] as String? ?? 'Learner',
      avatarEmoji: data['avatarEmoji'] as String? ?? '🐉',
      dialect: data['dialect'] as String? ?? 'Gogledd',
      dailyGoal: (data['dailyGoal'] as num?)?.toInt() ?? 20,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'avatarEmoji': avatarEmoji,
      'dialect': dialect,
      'dailyGoal': dailyGoal,
    };
  }
}

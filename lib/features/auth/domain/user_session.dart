/// Authenticated user snapshot (maps cleanly to Firebase `User` later).
class UserSession {
  const UserSession({
    required this.id,
    required this.email,
    this.displayName,
  });

  final String id;
  final String email;
  final String? displayName;
}

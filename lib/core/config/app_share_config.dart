/// Centralized invite / download link for native share sheet.
abstract final class AppShareConfig {
  /// Official Google Play listing for Paned.
  /// See: https://play.google.com/store/apps/details?id=com.paned.app.paned_app
  static const String downloadUrl =
      'https://play.google.com/store/apps/details?id=com.paned.app.paned_app';

  static const String inviteMessage = '''
I'm learning Welsh with Paned! 🏴
A simple and enjoyable way to build your Welsh vocabulary.
Give Paned a try!

$downloadUrl''';

  static const String inviteSubject = 'Try Paned — learn Welsh';
}

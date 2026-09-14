/// Centralized external links for Settings / support screens.
///
/// Leave a value empty until the real URL is provided — do not invent URLs.
abstract final class AppLinksConfig {
  /// Buy Us a Cuppa / tip support page.
  /// STATUS: missing — set the real tip/donation URL when available.
  static const String buyUsACuppaUrl = '';

  /// Privacy Policy page.
  static const String privacyPolicyUrl =
      'https://zamanr2a2023-rgb.github.io/paned/privacy-policy.html';

  /// Terms & Conditions page.
  /// STATUS: missing — set the real terms URL when available.
  static const String termsAndConditionsUrl = '';

  static bool get hasBuyUsACuppaUrl => buyUsACuppaUrl.trim().isNotEmpty;
  static bool get hasPrivacyPolicyUrl => privacyPolicyUrl.trim().isNotEmpty;
  static bool get hasTermsAndConditionsUrl =>
      termsAndConditionsUrl.trim().isNotEmpty;
}

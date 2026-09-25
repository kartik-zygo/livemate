import '../../core/config/env.dart';
import '../../core/utils/json_utils.dart';

/// `GET /legal` — public, no token. The links App Store and Play review expect
/// to be reachable from inside the app.
class LegalInfo {
  const LegalInfo({
    required this.privacyPolicyUrl,
    required this.deleteAccountUrl,
    required this.supportUrl,
    required this.contactEmail,
    this.policyLastUpdated,
  });

  /// Where support and privacy requests go until `GET /legal` says otherwise.
  static const String defaultContactEmail = 'support@zygonich.com';

  final String privacyPolicyUrl;
  final String deleteAccountUrl;
  final String supportUrl;
  final String contactEmail;

  /// Display text as the server sends it, e.g. "15 September 2026".
  final String? policyLastUpdated;

  /// The same pages `GET /legal` points at, derived from the server root, so
  /// the links work before that call has answered.
  factory LegalInfo.fallback() => LegalInfo(
    privacyPolicyUrl: '${Env.serverRoot}/privacy-policy',
    deleteAccountUrl: '${Env.serverRoot}/delete-account',
    supportUrl: '${Env.serverRoot}/support',
    contactEmail: defaultContactEmail,
  );

  factory LegalInfo.fromJson(Map<String, dynamic> json) {
    final fallback = LegalInfo.fallback();
    return LegalInfo(
      privacyPolicyUrl: asString(
        json['privacyPolicyUrl'],
        fallback.privacyPolicyUrl,
      ),
      deleteAccountUrl: asString(
        json['deleteAccountUrl'],
        fallback.deleteAccountUrl,
      ),
      supportUrl: asString(json['supportUrl'], fallback.supportUrl),
      contactEmail: asString(json['contactEmail'], fallback.contactEmail),
      policyLastUpdated: asStringOrNull(json['policyLastUpdated']),
    );
  }
}

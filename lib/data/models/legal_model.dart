import '../../core/config/env.dart';
import '../../core/utils/json_utils.dart';

/// `GET /legal` — public, no token. The links App Store and Play review expect
/// to be reachable from inside the app.
class LegalInfo {
  const LegalInfo({
    required this.privacyPolicyUrl,
    required this.deleteAccountUrl,
    this.contactEmail,
    this.policyLastUpdated,
  });

  final String privacyPolicyUrl;
  final String deleteAccountUrl;
  final String? contactEmail;

  /// Display text as the server sends it, e.g. "15 September 2026".
  final String? policyLastUpdated;

  /// The same pages `GET /legal` points at, derived from the server root, so
  /// the links work before that call has answered.
  factory LegalInfo.fallback() => LegalInfo(
    privacyPolicyUrl: '${Env.serverRoot}/privacy-policy',
    deleteAccountUrl: '${Env.serverRoot}/delete-account',
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
      contactEmail: asStringOrNull(json['contactEmail']),
      policyLastUpdated: asStringOrNull(json['policyLastUpdated']),
    );
  }
}

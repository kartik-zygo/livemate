import '../../core/utils/json_utils.dart';
import 'enums.dart';

class UserModel {
  const UserModel({
    required this.id,
    required this.supabaseUserId,
    required this.email,
    required this.fullName,
    required this.role,
    this.phone,
    this.avatarObjectKey,
    this.bio,
    this.occupation,
    this.gender,
    this.dateOfBirth,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String supabaseUserId;
  final String email;
  final String fullName;
  final PlatformRole role;
  final String? phone;
  final String? avatarObjectKey;
  final String? bio;
  final String? occupation;
  final ProfileGender? gender;
  final DateTime? dateOfBirth;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isAdmin => role == PlatformRole.admin;

  int? get age {
    final dob = dateOfBirth;
    if (dob == null) return null;
    final now = DateTime.now();
    var years = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      years--;
    }
    return years >= 0 && years < 130 ? years : null;
  }

  /// Everything the profile screen can prompt the user to fill in.
  double get completeness {
    final filled = [
      fullName.isNotEmpty,
      (phone ?? '').isNotEmpty,
      (bio ?? '').isNotEmpty,
      (occupation ?? '').isNotEmpty,
      gender != null,
      dateOfBirth != null,
    ].where((e) => e).length;
    return filled / 6;
  }

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'))
      ..removeWhere((e) => e.isEmpty);
    if (parts.isEmpty) return email.isNotEmpty ? email[0].toUpperCase() : '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: asString(json['id']),
    supabaseUserId: asString(json['supabaseUserId']),
    email: asString(json['email']),
    fullName: asString(json['fullName']),
    role: PlatformRole.fromWire(json['role']),
    phone: asStringOrNull(json['phone']),
    avatarObjectKey: asStringOrNull(json['avatarObjectKey']),
    bio: asStringOrNull(json['bio']),
    occupation: asStringOrNull(json['occupation']),
    gender: ProfileGender.fromWire(json['gender']),
    dateOfBirth: asDate(json['dateOfBirth']),
    createdAt: asDate(json['createdAt']),
    updatedAt: asDate(json['updatedAt']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'supabaseUserId': supabaseUserId,
    'email': email,
    'fullName': fullName,
    'role': role.wire,
    'phone': phone,
    'avatarObjectKey': avatarObjectKey,
    'bio': bio,
    'occupation': occupation,
    'gender': gender?.wire,
    'dateOfBirth': dateOfBirth?.toUtc().toIso8601String(),
  };
}

/// The public slice of a person the API attaches to listings and enquiries.
/// It never carries email or phone — those arrive only via [ContactModel].
class PersonSummary {
  const PersonSummary({
    required this.id,
    required this.fullName,
    this.bio,
    this.occupation,
    this.gender,
    this.avatarObjectKey,
  });

  final String id;
  final String fullName;
  final String? bio;
  final String? occupation;
  final ProfileGender? gender;
  final String? avatarObjectKey;

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'))
      ..removeWhere((e) => e.isEmpty);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  factory PersonSummary.fromJson(Map<String, dynamic> json) => PersonSummary(
    id: asString(json['id']),
    fullName: asString(json['fullName'], 'MyFlat Homes member'),
    bio: asStringOrNull(json['bio']),
    occupation: asStringOrNull(json['occupation']),
    gender: ProfileGender.fromWire(json['gender']),
    avatarObjectKey: asStringOrNull(json['avatarObjectKey']),
  );
}

/// Only ever non-null on an ACCEPTED enquiry. Rendering this object anywhere
/// else would leak contact details past the accept gate.
class ContactModel {
  const ContactModel({
    required this.id,
    required this.fullName,
    this.email,
    this.phone,
  });

  final String id;
  final String fullName;
  final String? email;
  final String? phone;

  bool get hasAnything => (email ?? '').isNotEmpty || (phone ?? '').isNotEmpty;

  factory ContactModel.fromJson(Map<String, dynamic> json) => ContactModel(
    id: asString(json['id']),
    fullName: asString(json['fullName']),
    email: asStringOrNull(json['email']),
    phone: asStringOrNull(json['phone']),
  );
}

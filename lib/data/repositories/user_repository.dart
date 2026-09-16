import '../models/enums.dart';
import '../models/user_model.dart';
import '../providers/auth_api_provider.dart';
import '../providers/user_api_provider.dart';

class UserRepository {
  const UserRepository(this._auth, this._users);

  final AuthApiProvider _auth;
  final UserApiProvider _users;

  /// The first authenticated call after sign-up; it is what materialises the
  /// local user row on the backend.
  Future<UserModel> bootstrap() async => UserModel.fromJson(await _auth.me());

  Future<UserModel> me() async => UserModel.fromJson(await _users.me());

  Future<UserModel> updateMe({
    String? fullName,
    String? phone,
    String? bio,
    String? occupation,
    ProfileGender? gender,
    DateTime? dateOfBirth,
  }) async {
    final body = <String, dynamic>{};
    if (fullName != null) body['fullName'] = fullName;
    if (phone != null) body['phone'] = phone;
    if (bio != null) body['bio'] = bio;
    if (occupation != null) body['occupation'] = occupation;
    if (gender != null) body['gender'] = gender.wire;
    if (dateOfBirth != null) {
      body['dateOfBirth'] = dateOfBirth.toUtc().toIso8601String();
    }
    return UserModel.fromJson(await _users.updateMe(body));
  }

  /// `DELETE /users/me` — permanently deletes the signed-in account.
  Future<void> deleteMe() => _users.deleteMe();
}

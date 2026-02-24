import 'package:ai4bmi/data/models/user_model.dart';

/// Reponse de login/register : token + user.
class AuthDataModel {
  final String token;
  final String tokenType;
  final UserModel user;

  AuthDataModel({
    required this.token,
    required this.tokenType,
    required this.user,
  });

  factory AuthDataModel.fromJson(Map<String, dynamic> json) {
    return AuthDataModel(
      token: json['token'] as String,
      tokenType: json['token_type'] as String? ?? 'Bearer',
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Object? operator [](String other) {}
}

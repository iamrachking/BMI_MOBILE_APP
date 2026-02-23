/// Utilisateur
class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? address;
  final String? profilePhotoUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.address,
    this.profilePhotoUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String? ?? 'customer',
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      profilePhotoUrl: json['profile_photo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'address': address,
  };
}

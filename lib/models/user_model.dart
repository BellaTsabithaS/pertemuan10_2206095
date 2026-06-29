// Purpose: User profile data model for auth and profile screens.
// Main callers: AuthProvider, ProfilePage.
// Key dependencies: None.
// Main/public functions: UserModel, UserModel.fromJson.
// Side effects: None.

class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  final String id;
  final String name;
  final String email;
  final String phone;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: '${json['id'] ?? ''}',
      name: '${json['full_name'] ?? json['name'] ?? ''}',
      email: '${json['email'] ?? ''}',
      phone: '${json['phone'] ?? ''}',
    );
  }
}

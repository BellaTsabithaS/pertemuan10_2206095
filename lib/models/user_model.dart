// Purpose: User profile data model for auth, profile, and admin routing screens.
// Main callers: AuthProvider, ProfilePage, SplashPage, LoginPage.
// Key dependencies: None.
// Main/public functions: UserModel, UserModel.fromJson, isAdmin.
// Side effects: None.

class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;

  bool get isAdmin => role.toLowerCase() == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final roleValue = json['role'];
    final role = roleValue is Map<String, dynamic>
        ? '${roleValue['name'] ?? ''}'
        : '${roleValue ?? ''}';

    return UserModel(
      id: '${json['id'] ?? ''}',
      name: '${json['full_name'] ?? json['name'] ?? ''}',
      email: '${json['email'] ?? ''}',
      phone: '${json['phone'] ?? ''}',
      role: role,
    );
  }
}

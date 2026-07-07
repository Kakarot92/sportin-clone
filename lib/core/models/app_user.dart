enum AppRole { client, trainer, admin }

AppRole appRoleFromString(String? value) {
  switch (value) {
    case 'admin':
      return AppRole.admin;
    case 'trainer':
      return AppRole.trainer;
    default:
      return AppRole.client;
  }
}

/// Application-level user profile stored at `users/{uid}` in Firestore,
/// separate from the Firebase Auth account.
class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    this.displayName = '',
    this.phone = '',
    this.role = AppRole.client,
  });

  final String uid;
  final String email;
  final String displayName;
  final String phone;
  final AppRole role;

  bool get isAdmin => role == AppRole.admin;
  bool get isTrainer => role == AppRole.trainer;
  bool get isClient => role == AppRole.client;

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      email: (map['email'] as String?) ?? '',
      displayName: (map['displayName'] as String?) ?? '',
      phone: (map['phone'] as String?) ?? '',
      role: appRoleFromString(map['role'] as String?),
    );
  }
}

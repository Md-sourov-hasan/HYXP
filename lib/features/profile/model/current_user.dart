class CurrentUser {
  const CurrentUser({
    required this.id,
    required this.email,
    required this.username,
    required this.name,
    required this.bio,
    required this.authProvider,
    required this.isActive,
    required this.isSuperuser,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.photo,
    required this.profileImage,
    required this.dob,
    required this.groups,
    required this.permissions,
    required this.permissionCodes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String email;
  final String username;
  final String name;
  final String bio;
  final String authProvider;
  final bool isActive;
  final bool isSuperuser;
  final String firstName;
  final String lastName;
  final String gender;
  final String photo;
  final String profileImage;
  final DateTime? dob;
  final List<dynamic> groups;
  final List<dynamic> permissions;
  final List<String> permissionCodes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get displayName {
    if (name.trim().isNotEmpty) return name.trim();
    final fullName = '$firstName $lastName'.trim();
    if (fullName.isNotEmpty) return fullName;
    if (username.trim().isNotEmpty) return username.trim();
    return email;
  }

  String get effectivePhoto {
    if (profileImage.trim().isNotEmpty) return profileImage.trim();
    return photo.trim();
  }

  factory CurrentUser.fromJson(Map<String, dynamic> json) {
    final rawDob = json['date_of_birth']?.toString() ?? json['dob']?.toString() ?? '';
    final rawPhoto = json['profile_image']?.toString() ?? json['photo']?.toString() ?? '';
    final rawName = json['name']?.toString() ?? '';

    return CurrentUser(
      id: json['id']?.toString() ?? json['user_id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      name: rawName,
      bio: json['bio']?.toString() ?? '',
      authProvider: json['auth_provider']?.toString() ?? '',
      isActive: json['is_active'] == true || json['is_active'] == null,
      isSuperuser: json['is_superuser'] == true,
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      photo: rawPhoto,
      profileImage: rawPhoto,
      dob: DateTime.tryParse(rawDob),
      groups: json['groups'] is List
          ? json['groups'] as List<dynamic>
          : const [],
      permissions: json['permissions'] is List
          ? json['permissions'] as List<dynamic>
          : const [],
      permissionCodes: json['permission_codes'] is List
          ? (json['permission_codes'] as List<dynamic>)
                .map((code) => code.toString())
                .toList()
          : const [],
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
    );
  }
}

class UserProfile {
  final String id; // UUID
  final String email;
  final String firstName;
  final String lastName;
  final String course;
  final String yearLevel;
  final String? profilePictureUrl;

  const UserProfile({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.course,
    required this.yearLevel,
    this.profilePictureUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      course: json['course'] as String,
      yearLevel: json['year_level'] as String,
      profilePictureUrl: json['profile_picture_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'course': course,
      'year_level': yearLevel,
      'profile_picture_url': profilePictureUrl,
    };
  }

  // Useful for updating profile state
  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? course,
    String? yearLevel,
    String? profilePictureUrl,
  }) {
    return UserProfile(
      id: this.id,
      email: this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      course: course ?? this.course,
      yearLevel: yearLevel ?? this.yearLevel,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    );
  }
}
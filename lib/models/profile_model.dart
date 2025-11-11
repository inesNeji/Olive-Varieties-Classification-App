class UserProfile {
  final String name;
  final String email;
  final String? picture; // The base64 encoded picture

  UserProfile({
    required this.name,
    required this.email,
    this.picture,
  });

  // Factory method to create a UserProfile object from JSON data
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? 'Nom non disponible',
      email: json['email'] ?? '',
      picture: json['picture'],
    );
  }

  // Convert UserProfile object to a Map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'picture': picture,
    };
  }
}

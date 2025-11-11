class LoginModel {
  final String email;
  final String password;

  LoginModel({
    required this.email,
    required this.password,
  });

  // Convert LoginModel to Map for JSON serialization
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
    };
  }

  // Convert a Map to LoginModel
  factory LoginModel.fromMap(Map<String, dynamic> map) {
    return LoginModel(
      email: map['email'],
      password: map['password'],
    );
  }
}

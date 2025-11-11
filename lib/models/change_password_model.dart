class ChangePasswordModel {
  String token;
  String password;

  ChangePasswordModel({required this.token, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'password': password,
    };
  }
}

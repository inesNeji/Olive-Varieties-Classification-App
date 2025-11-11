class ResetPasswordModel {
  final String email;
  final String code;

  ResetPasswordModel({
    required this.email,
    required this.code,
  });

  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'code': code,
    };
  }

  // Factory constructor to create a model from JSON
  factory ResetPasswordModel.fromJson(Map<String, dynamic> json) {
    return ResetPasswordModel(
      email: json['email'] ?? '',
      code: json['code'] ?? '',
    );
  }
}

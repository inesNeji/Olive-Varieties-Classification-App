class ModifypassModel {
  final String email;
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;

  ModifypassModel({
    required this.email,
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  // Convert the data to a map that can be sent to the API
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'old_password': oldPassword,
      'new_password': newPassword,
      'confirm_password': confirmPassword,
    };
  }

  // Factory constructor to create an instance from a map (e.g., for API response parsing)
  factory ModifypassModel.fromMap(Map<String, dynamic> map) {
    return ModifypassModel(
      email: map['email'] ?? '',
      oldPassword: map['old_password'] ?? '',
      newPassword: map['new_password'] ?? '',
      confirmPassword: map['confirm_password'] ?? '',
    );
  }
}

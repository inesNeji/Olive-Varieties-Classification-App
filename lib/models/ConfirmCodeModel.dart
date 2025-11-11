class ConfirmCodeModel {
  final String code;

  ConfirmCodeModel({required this.code});

  Map<String, dynamic> toJson() {
    return {'code': code};
  }

  static ConfirmCodeModel fromJson(Map<String, dynamic> json) {
    return ConfirmCodeModel(code: json['code'] ?? '');
  }
}

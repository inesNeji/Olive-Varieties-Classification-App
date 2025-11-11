class SaveResultModel {
  final String imagePath;
  final String result;
  final String confidence;
  final String email;

  SaveResultModel({
    required this.imagePath,
    required this.result,
    required this.confidence,
    required this.email,
  });

  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'imagePath': imagePath,
      'result': result,
      'confidence': confidence,
      'email': email,
    };
  }

  // Factory constructor to create a model from JSON
  factory SaveResultModel.fromJson(Map<String, dynamic> json) {
    return SaveResultModel(
      imagePath: json['imagePath'] ?? '',
      result: json['result'] ?? '',
      confidence: json['confidence'] ?? '',
      email: json['email'] ?? '',
    );
  }
}


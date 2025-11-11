class Historique {
  final String id;
  final String imageFilename;
  final String result;
  final String confidence;
  final String timestamp;

  Historique({
    required this.id,
    required this.imageFilename,
    required this.result,
    required this.confidence,
    required this.timestamp,
  });

  // From JSON to Historique object
  factory Historique.fromJson(Map<String, dynamic> json) {
    return Historique(
      id: json['_id'],
      imageFilename: json['image_filename'],
      result: json['result'],
      confidence: json['confidence'],
      timestamp: json['timestamp'],
    );
  }

  // To JSON from Historique object
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'image_filename': imageFilename,
      'result': result,
      'confidence': confidence,
      'timestamp': timestamp,
    };
  }
}

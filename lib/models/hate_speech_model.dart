class HateSpeechModel {
  final String classification;
  final List<double> probabilities;

  HateSpeechModel({
    required this.classification,
    required this.probabilities,
  });

  factory HateSpeechModel.fromJson(List<dynamic> json) {
    return HateSpeechModel(
      classification: json[0],
      probabilities: List<double>.from(json[1]),
    );
  }
}

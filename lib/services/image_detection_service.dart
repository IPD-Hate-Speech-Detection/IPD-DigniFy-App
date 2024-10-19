import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ImageHateDetection {
  final String apiUrl =
      'https://ipd-image-render-deploy.onrender.com/predict-image/';

  Future<String> uploadImage(String? filePath) async {
    if (filePath == null || filePath.isEmpty) {
      return 'No file selected';
    }

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      request.headers.addAll({
        'accept': 'application/json',
        'Content-Type': 'multipart/form-data',
      });

      // Attach the image file
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        filePath,
        contentType: MediaType('image', 'jpeg'),
      ));

      print("uploading image");
      var response = await request.send();

      if (response.statusCode == 200) {
        var result = await response.stream.bytesToString();
        print("Response: $result");

        // Parse the response and extract labels
        return extractLabels(result);
      } else {
        return 'Error: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  // Function to extract labels from the JSON string response
  String extractLabels(String response) {
    // Assuming the response is a JSON-like structure
    var decoded = jsonDecode(response);
    var predictions = decoded['prediction'] as List<dynamic>;

    // Extract and clean up the labels
    var labels = predictions.map((item) {
      var label = item['label'] as String;
      return label.split(',').first.replaceAll('label:', '').trim();
    }).toList();

    return labels.join(', ');
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ImageHateDetection {
  final String apiUrl = 'https://ipd-image-render-deploy.onrender.com/predict';

  Future<Map<String, dynamic>> uploadImage(String? filePath) async {
    if (filePath == null || filePath.isEmpty) {
      throw Exception('No file selected');
    }

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      request.headers.addAll({
        'accept': 'application/json',
        'Content-Type': 'multipart/form-data',
      });

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        filePath,
        contentType: MediaType('image', 'jpeg'),
      ));

      print("Uploading image...");
      var response = await request.send();

      if (response.statusCode == 200) {
        var result = await response.stream.bytesToString();
        print("Response: $result");

        var decoded = jsonDecode(result);
        if (decoded['prediction'] == null) {
          throw Exception('Invalid response format: missing prediction data');
        }

        return decoded;
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }
}

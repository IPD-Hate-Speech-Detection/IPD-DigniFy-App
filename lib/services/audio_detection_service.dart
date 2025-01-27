import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class AudioHateDetection {
  final String apiUrl = 'https://ipd-image-render-deploy.onrender.com/predict-audio';

  Future<Map<String, dynamic>> uploadAudio(String? filePath) async {
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
        contentType: MediaType('audio', 'mpeg'), // Adjust based on file type
      ));

      print("Uploading audio...");
      var response = await request.send();

      if (response.statusCode == 200) {
        var result = await response.stream.bytesToString();
        print("Response: $result");

        var decoded = jsonDecode(result);
        if (decoded == null) {
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
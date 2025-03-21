import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class AudioHateDetectionService {
  final String apiUrl =
      'https://ipd-audio-render-deploy.onrender.com/predict';

  Future<Map<String, dynamic>> uploadAudio(String? filePath) async {
    if (filePath == null || filePath.isEmpty) {
      throw Exception('No file selected');
    }

    try {
      var fileExtension = filePath.split('.').last.toLowerCase();
      MediaType? mediaType;

      // Check the file extension and assign the appropriate MediaType
      if (fileExtension == 'mp3') {
        mediaType = MediaType('audio', 'mp3');
      } else if (fileExtension == 'mpeg' || fileExtension == 'mpg') {
        mediaType = MediaType('audio', 'mpeg');
      } else if (fileExtension == 'wav') {
        mediaType = MediaType('audio', 'wav');
      } else {
        throw Exception('Unsupported file type');
      }

      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      request.headers.addAll({
        'accept': 'application/json',
        'Content-Type': 'multipart/form-data',
      });

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        filePath,
        contentType: mediaType,
      ));

      print("Uploading audio...");
      var response = await request.send();
      print(response.statusCode);

      if (response.statusCode == 200) {
        var result = await response.stream.bytesToString();
        print("Response fetched");
        print("Response: $result");
        print(result.runtimeType);

        var decoded = jsonDecode(result);
        if (decoded == null) {
          throw Exception('Invalid response format: missing prediction data');
        }
        print(decoded.runtimeType);
        return decoded;
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }
}

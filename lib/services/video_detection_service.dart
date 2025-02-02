import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class VideoHateDetectionService {
  final String apiUrl = 'https://ipd-video-render-deploy.onrender.com/predict';

  Future<Map<String, dynamic>> uploadVideo(String? filePath) async {
    if (filePath == null || filePath.isEmpty) {
      throw Exception('No file selected');
    }

    try {
      var fileExtension = filePath.split('.').last.toLowerCase();
      MediaType? mediaType;

      // Check the file extension and assign the appropriate MediaType
      switch (fileExtension) {
        case 'mp4':
          mediaType = MediaType('video', 'mp4');
          break;
        case 'avi':
          mediaType = MediaType('video', 'x-msvideo');
          break;
        case 'mov':
          mediaType = MediaType('video', 'quicktime');
          break;
        case 'wmv':
          mediaType = MediaType('video', 'x-ms-wmv');
          break;
        case 'mkv':
          mediaType = MediaType('video', 'x-matroska');
          break;
        default:
          throw Exception('Unsupported video file type: $fileExtension');
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

      print("Uploading video...");
      var response = await request.send();
      print("Response status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        var result = await response.stream.bytesToString();
        print("Response received");
        print("Response body: $result");

        var decoded = jsonDecode(result);
        if (decoded == null) {
          throw Exception('Invalid response format: missing prediction data');
        }
        return decoded;
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Video upload failed: $e');
    }
  }
}

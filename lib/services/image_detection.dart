import 'dart:io';
import 'package:http/http.dart' as http;

class ImageHateService {
  final String apiUrl =
      'https://huggingface.co/dj-dawgs-ipd/IPD-Image-ViT-Finetune/resolve/main/inference';

  Future<String> detectHateSpeech(File imageFile) async {
    try {
      print("sendig image request");
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files
          .add(await http.MultipartFile.fromPath('image', imageFile.path));

      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        return responseBody.body;
      } else {
        throw Exception('Failed to detect hate speech: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class TextDetectionService {
  static const String baseUrl =
      'https://dj-dawgs-ipd-ipd-english-text.hf.space/call/predict';

  Future<String> getEventId(String text) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "data": [text]
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = response.body;
      try {
        final data = jsonDecode(responseBody);
        return data['event_id'];
      } catch (e) {
        throw Exception('Failed to parse event ID: $e');
      }
    } else {
      throw Exception('Failed to get event ID');
    }
  }

  Future<String> getCompleteResult(String id) async {
    final uri = Uri.parse('$baseUrl/$id');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final responseBody = response.body;
      print('Raw response body: $responseBody'); // Debugging line

      try {
        // Use a regular expression to find the `data:` part
        final regex = RegExp(r'data: (\[".*?"\])');
        final match = regex.firstMatch(responseBody);
        // print("printing match: $match");

        if (match != null && match.groupCount > 0) {
          final dataLine = match.group(1)!;
          print("dataLine: $dataLine");
          RegExp regExp = RegExp(r'\"The string is classified as (.+?)\.\"');
          Match? matched = regExp.firstMatch(dataLine);
          final data = jsonDecode(dataLine);

          if (match != null) {
            String extractedString = matched!.group(0)!;
            String classification = matched.group(1)!;
            print(
                "extracted $extractedString"); // Output: The string is classified as hate speech.
            print("classify $classification");
            return extractedString; // Output: hate speech
          }
        } else {
          throw Exception('Data line not found');
        }
      } catch (e) {
        throw Exception('Failed to parse result: $e');
      }
    } else {
      throw Exception('Failed to get complete result');
    }
    return "error";
  }
}

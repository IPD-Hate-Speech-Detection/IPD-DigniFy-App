import 'dart:convert';
import 'package:http/http.dart' as http;

class EnglishTextDetectionService {
  static const String baseUrl =
      'https://dj-dawgs-ipd-ipd-text-english-finetune.hf.space/call/classify_text';

  Future<String> getEnglishEventId(String text) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "data": [text]
      }),
    );
    print("englis start");
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

  Future<List<dynamic>> getEnglishCompleteResult(String id) async {
    final uri = Uri.parse('$baseUrl/$id');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final responseBody = response.body;
      print('Raw response body: $responseBody');

      try {
        // Extract the relevant data from the raw response
        // Split the response into lines
        final lines = responseBody.split('\n');

        // Get the line with the actual data (second line)
        final dataLine = lines[1].substring(6); // remove "data: "

        // Decode the JSON data
        final List<dynamic> result = jsonDecode(dataLine);

        // Extract label and probability
        final String label = result[0];
        final double probability = result[1];

        // Return as a map
        return result;
      } catch (e) {
        throw Exception('Failed to parse result: $e');
      }
    } else {
      throw Exception('Failed to get complete result');
    }
  }
}

class HinglishTextDetectionService {
  static const String hinglishBaseUrl =
      'https://dj-dawgs-ipd-ipd-text-hinglish.hf.space/call/predict';

  // Function to send text for classification (Hinglish)
  Future<String> getHinglishEventId(String text) async {
    print(text);
    final response = await http.post(
      Uri.parse(hinglishBaseUrl),
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

  // Function to fetch complete results using event ID (Hinglish)
  Future<List<dynamic>> getHinglishCompleteResult(String id) async {
    final uri = Uri.parse('$hinglishBaseUrl/$id');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final responseBody = response.body;
      print('Raw response body: $responseBody');

      try {
        // Split the response into lines
        final lines = responseBody.split('\n');

        // Get the line with the actual data (second line)
        final dataLine = lines[1].substring(6); // remove "data: "

        // Decode the JSON data
        final List<dynamic> result = jsonDecode(dataLine);

        // Extract label and probability
        final String label = result[0];
        final double probability = result[1];

        // Return the extracted information as a list

        return [label, probability];
      } catch (e) {
        throw Exception('Failed to parse result: $e');
      }
    } else {
      throw Exception('Failed to get result');
    }
  }
}

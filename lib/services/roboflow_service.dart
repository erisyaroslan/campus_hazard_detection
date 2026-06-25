import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class RoboflowService {
  static const String apiUrl =
      "https://serverless.roboflow.com/erisyas-workspace/workflows/custom-workflow-2";

  static const String apiKey = "zfWWDUrnBOutZraquQzc";

  static Future<dynamic> predict(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "api_key": apiKey,
          "inputs": {
            "image": {"type": "base64", "value": base64Image},
          },
        }),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      throw Exception("Server Error ${response.statusCode}\n${response.body}");
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DetectScreen extends StatefulWidget {
  final File image;

  const DetectScreen({super.key, required this.image});

  @override
  State<DetectScreen> createState() => _DetectScreenState();
}

class _DetectScreenState extends State<DetectScreen> {
  bool isLoading = false;

  Future<void> detectHazard() async {
    setState(() {
      isLoading = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.0.113:5000/predict'),
      );

      request.fields['zone'] = 'Campus Road';

      request.files.add(
        await http.MultipartFile.fromPath('image', widget.image.path),
      );

      var response = await request.send();

      var body = await response.stream.bytesToString();
      print("STATUS: ${response.statusCode}");
      print("BODY: $body");

      final result = jsonDecode(body);

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(result["hazard"]),
          content: Text("""
Category: ${result["category"]}

Confidence: ${result["confidence"]}

Severity: ${result["severity"]}

Action:
${result["action"]}
"""),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: Text(e.toString()),
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Image Preview")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(
                  widget.image,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : detectHazard,
                icon: const Icon(Icons.search),
                label: Text(isLoading ? "Detecting..." : "Detect Hazard"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

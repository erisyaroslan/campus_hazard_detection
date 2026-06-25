import 'dart:io';
import 'package:flutter/material.dart';

class ReportScreen extends StatefulWidget {
  final File image;
  final String hazardClass;
  final String category;
  final String confidence;
  final String action;

  const ReportScreen({
    super.key,
    required this.image,
    required this.hazardClass,
    required this.category,
    required this.confidence,
    required this.action,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final TextEditingController descriptionController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Hazard"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.file(
                widget.image,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.warning),
                      title: const Text("Hazard Class"),
                      subtitle: Text(widget.hazardClass),
                    ),

                    ListTile(
                      leading: const Icon(Icons.category),
                      title: const Text("General Category"),
                      subtitle: Text(widget.category),
                    ),

                    ListTile(
                      leading: const Icon(Icons.analytics),
                      title: const Text("Confidence Score"),
                      subtitle: Text("${widget.confidence}/1.00"),
                    ),

                    ListTile(
                      leading: const Icon(Icons.build),
                      title: const Text("Expected Action"),
                      subtitle: Text(widget.action),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Additional Description",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Hazard Report Submitted",
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.send),
                label: const Text("Submit Report"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
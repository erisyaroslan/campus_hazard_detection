import 'dart:io';
import 'package:campus_hazard_detection/screens/report_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'services/roboflow_service.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const CampusSafeApp());
}

class CampusSafeApp extends StatelessWidget {
  const CampusSafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusSafe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2563EB),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const List<String> hazardClasses = [
    "Pothole",
    "Cracked Pavement",
    "Open Drain",
    "Sunk Road",
    "Uncovered Manhole",
  ];

  Future<void> pickImage(BuildContext context) async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1200,
    );

    if (image == null) return;

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PreviewScreen(image: File(image.path))),
    );
  }

  Future<void> captureImage(BuildContext context) async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 1200,
    );

    if (image == null) return;

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PreviewScreen(image: File(image.path))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("CampusSafe"), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HERO CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
                  ),
                ),
                child: const Column(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white24,
                      child: Icon(
                        Icons.shield_outlined,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      "AI Campus Hazard Detection",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Detect and report hazards around campus instantly",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Quick Actions",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () => captureImage(context),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text(
                    "Capture Hazard",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 60,
                child: OutlinedButton.icon(
                  onPressed: () => pickImage(context),
                  icon: const Icon(Icons.photo_library),
                  label: const Text(
                    "Upload Image",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(Icons.category, size: 30),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Supported Hazards",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${hazardClasses.length} categories available",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: hazardClasses
                    .map(
                      (hazard) => Chip(
                        avatar: const Icon(
                          Icons.warning_amber_rounded,
                          size: 18,
                        ),
                        label: Text(hazard),
                      ),
                    )
                    .toList(),
              ),

              const SizedBox(height: 25),

              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: Text("AI Detection Model"),
                  subtitle: Text("Ready for deployment"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PreviewScreen extends StatefulWidget {
  final File image;

  const PreviewScreen({super.key, required this.image});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  bool isLoading = false;
  String result = "Press Detect Hazard";

  String hazardClass = "";
  String category = "";
  String action = "";
  String confidence = "";

  List<String> zones = [
    "Campus Road",
    "Faculty Road",
    "Parking Area",
    "Cafeteria Area",
    "Student Residential Area",
  ];

  String selectedZone = "Campus Road";

  final Map<String, Map<String, String>> hazardInfo = {
    "pothole": {
      "category": "Road Surface Hazard",
      "action": "Report to campus maintenance and avoid the damaged area.",
    },

    "cracked_pavement": {
      "category": "Road Surface Hazard",
      "action": "Exercise caution while walking and notify maintenance.",
    },

    "open_drain": {
      "category": "Drainage Hazard",
      "action": "Keep away from the drain and report immediately.",
    },

    "sunk_road": {
      "category": "Road Surface Hazard",
      "action": "Avoid crossing the area and report to maintenance.",
    },

    "uncovered_manhole": {
      "category": "Infrastructure Hazard",
      "action": "Prevent access to the area and notify maintenance urgently.",
    },
  };

  Future<void> detectHazard() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await RoboflowService.predict(widget.image);
      print(response);

      final predictions = response["outputs"][0]["model_output"]["predictions"];

      if (predictions == null || predictions.isEmpty) {
        setState(() {
          isLoading = false;
          result = "No hazard detected";
        });
        return;
      }

      final prediction = predictions[0];
      hazardClass = prediction["class"].toString();
      confidence = (prediction["confidence"] ?? 0).toStringAsFixed(2);

      final location = await getCurrentLocation();
      final info =
          hazardInfo[hazardClass] ??
          {"category": "Unknown", "action": "Further inspection required."};

      category = info["category"]!;
      action = info["action"]!;

      String formatHazard(String text) {
        return text
            .split('_')
            .map(
              (word) => word[0].toUpperCase() + word.substring(1).toLowerCase(),
            )
            .join(' ');
      }

      final formattedHazard = formatHazard(hazardClass);

      setState(() {
        isLoading = false;
        result = result =
            "Hazard Class\n"
            "$formattedHazard\n\n"
            "General Category\n"
            "$category\n\n"
            "Location Zone\n"
            "$selectedZone\n\n"
            "Confidence Score\n"
            "$confidence%\n\n"
            "Expected Action\n"
            "$action";
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        result = "ERROR\n\n$e";
      });
    }
  }

  Future<String> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return "Location Disabled";
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return "Permission Denied";
    }

    Position position = await Geolocator.getCurrentPosition();

    return "${position.latitude.toStringAsFixed(5)}, "
        "${position.longitude.toStringAsFixed(5)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hazard Detection")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.file(
                  widget.image,
                  height: 320,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : detectHazard,
                icon: const Icon(Icons.auto_awesome),
                label: const Text(
                  "Analyze Hazard",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 25),

            if (isLoading)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 15),
                  Text("AI is analyzing image..."),
                ],
              ),

            if (!isLoading && result != "Press Detect Hazard")
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                      size: 70,
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      "Detection Result",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      result,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, height: 1.6),
                    ),

                    const SizedBox(height: 25),

                    ElevatedButton.icon(
                      icon: const Icon(Icons.report),
                      label: const Text("Report Hazard"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReportScreen(
                              image: widget.image,
                              hazardClass: hazardClass,
                              category: category,
                              confidence: confidence,
                              action: action,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 25),

                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Location Zone",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 10),

                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: selectedZone,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              items: zones.map((zone) {
                                return DropdownMenuItem(
                                  value: zone,
                                  child: Text(zone),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedZone = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'dart:ui' as ui;
import 'package:campus_hazard_detection/screens/report_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'widgets/bounding_box_painter.dart';

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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.auto_awesome, size: 40, color: Colors.blue),

                      SizedBox(height: 10),

                      Text(
                        "AI-Powered Hazard Detection",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 10),

                      Text(
                        "Capture or upload an image and let the system automatically identify campus hazards, assess severity, and generate recommended safety actions.",
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
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
  List<Map<String, dynamic>> detectedHazards = [];
  List<Map<String, dynamic>> boxes = [];
  double imageWidth = 0;
  double imageHeight = 0;
  bool isLoading = false;
  String result = "Press Detect Hazard";
  String severity = "";
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

  Future<void> detectHazard() async {
    setState(() {
      isLoading = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.0.113:5000/predict'),
      );

      request.fields['zone'] = selectedZone;

      request.files.add(
        await http.MultipartFile.fromPath('image', widget.image.path),
      );

      var response = await request.send();

      var body = await response.stream.bytesToString();
      print("STATUS: ${response.statusCode}");
      print("BODY: $body");

      final apiResult = jsonDecode(body);
      print(apiResult["boxes"]);
      print(apiResult);
      print(apiResult.keys);
      print("Hazard = ${apiResult["hazard"]}");
      print("Hazards = ${apiResult["hazards"]}");

      if (apiResult["hazard"] == null) {
        setState(() {
          isLoading = false;
          result = "No hazard detected";
        });
        return;
      }
      detectedHazards = List<Map<String, dynamic>>.from(
        apiResult["hazards"] ?? [],
      );

      // Primary hazard
      hazardClass = apiResult["hazard"];

      // All detected hazards
      final List<Map<String, dynamic>> hazards =
          List<Map<String, dynamic>>.from(apiResult["hazards"] ?? []);

      String hazardList = "";

      for (final h in hazards) {
        hazardList +=
            "• ${h["hazard"]} (${(h["confidence"] * 100).toStringAsFixed(1)}%)\n";
      }

      category = apiResult["category"];

      confidence = apiResult["confidence"].toString();

      action = apiResult["action"];
      if (apiResult["boxes"] != null) {
        boxes = List<Map<String, dynamic>>.from(apiResult["boxes"]);

        final decoded = await decodeImageFromList(
          widget.image.readAsBytesSync(),
        );

        imageWidth = decoded.width.toDouble();
        imageHeight = decoded.height.toDouble();
      }

      severity = apiResult["severity"];

      setState(() {
        isLoading = false;

        result =
            "Primary Hazard\n"
            "$hazardClass\n\n"
            "Detected Hazards\n"
            "$hazardList\n"
            "General Category\n"
            "$category\n\n"
            "Location Zone\n"
            "$selectedZone\n\n"
            "Confidence Score\n"
            "$confidence\n\n"
            "Severity\n"
            "$severity\n\n"
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

  Future<void> loadImageSize() async {
    final bytes = await widget.image.readAsBytes();

    final codec = await ui.instantiateImageCodec(bytes);

    final frame = await codec.getNextFrame();

    setState(() {
      imageWidth = frame.image.width.toDouble();
      imageHeight = frame.image.height.toDouble();
    });
  }

  @override
  void initState() {
    super.initState();
    loadImageSize();
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
                child: SizedBox(
                  height: 320,
                  width: double.infinity,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(widget.image, fit: BoxFit.fill),

                          if (boxes.isNotEmpty)
                            Positioned.fill(
                              child: IgnorePointer(
                                child: CustomPaint(
                                  painter: BoundingBoxPainter(
                                    boxes: boxes,
                                    imageWidth: imageWidth,
                                    imageHeight: imageHeight,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

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

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Primary Hazard",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Card(
                          color: Colors.orange.shade50,
                          child: ListTile(
                            leading: const Icon(
                              Icons.warning,
                              color: Colors.orange,
                            ),
                            title: Text(hazardClass),
                            subtitle: Text(
                              "Confidence: ${((double.tryParse(confidence) ?? 0.0) * 100).toStringAsFixed(1)}%",
                            ),
                            trailing: Text(
                              severity,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        const Text(
                          "Detected Hazards",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        ...detectedHazards.map((hazard) {
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.report_problem),

                              title: Text(hazard["hazard"]),

                              subtitle: Text(
                                "Confidence: ${(hazard["confidence"] * 100).toStringAsFixed(1)}%",
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: 25),

                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.location_on),
                            title: const Text("Campus Zone"),
                            subtitle: Text(selectedZone),
                          ),
                        ),

                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.category),
                            title: const Text("Category"),
                            subtitle: Text(category),
                          ),
                        ),

                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.auto_awesome),
                            title: const Text("Recommended Action"),
                            subtitle: Text(action),
                          ),
                        ),
                      ],
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

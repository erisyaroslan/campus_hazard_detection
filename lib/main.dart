import 'dart:io';
import 'dart:ui' as ui;
import 'package:campus_hazard_detection/screens/report_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:campus_hazard_detection/theme/app_theme.dart';
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
        colorSchemeSeed: AppColors.accent,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.accent,
            side: const BorderSide(color: AppColors.sky),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('CampusSafe')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                const Icon(
                  Icons.shield_outlined,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Campus Hazard\nDetection',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Capture, analyze, and report hazards instantly',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 36),
                _ActionButton(
                  icon: Icons.camera_alt_outlined,
                  label: 'Capture Hazard',
                  filled: true,
                  onPressed: () => captureImage(context),
                ),
                const SizedBox(height: 12),
                _ActionButton(
                  icon: Icons.photo_library_outlined,
                  label: 'Upload Image',
                  filled: false,
                  onPressed: () => pickImage(context),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.sky.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      _StepDot(label: '1', text: 'Capture'),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppColors.sky.withValues(alpha: 0.5),
                        ),
                      ),
                      _StepDot(label: '2', text: 'Analyze'),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppColors.sky.withValues(alpha: 0.5),
                        ),
                      ),
                      _StepDot(label: '3', text: 'Report'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'AI model ready',
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.9),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return SizedBox(
        height: 54,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
          ),
          icon: Icon(icon, size: 22),
          label: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return SizedBox(
      height: 54,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
        ),
        icon: Icon(icon, size: 22),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final String label;
  final String text;

  const _StepDot({required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
      ],
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
    final hasResult = !isLoading && result != "Press Detect Hazard";

    return GradientScaffold(
      title: 'Hazard Detection',
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 280,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(widget.image, fit: BoxFit.cover),
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
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Location Zone',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: selectedZone,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.background,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: zones.map((zone) {
                          return DropdownMenuItem(
                            value: zone,
                            child: Text(zone),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => selectedZone = value!);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : detectHazard,
                    icon: const Icon(Icons.auto_awesome_outlined, size: 20),
                    label: const Text(
                      'Analyze Hazard',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                if (isLoading) ...[
                  const SizedBox(height: 32),
                  const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Analyzing image…',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                ],

                if (hasResult) ...[
                  const SizedBox(height: 24),
                  SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.warning_amber_rounded,
                                color: AppColors.accent,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Primary Hazard',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    hazardClass,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SeverityBadge(severity: severity),
                          ],
                        ),
                        const SizedBox(height: 12),
                        InfoRow(
                          icon: Icons.percent_outlined,
                          label: 'Confidence',
                          value:
                              '${((double.tryParse(confidence) ?? 0.0) * 100).toStringAsFixed(1)}%',
                        ),
                      ],
                    ),
                  ),

                  if (detectedHazards.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'All Detected',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...detectedHazards.map((hazard) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.circle,
                                    size: 6,
                                    color: AppColors.accent,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      hazard['hazard'] as String,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${(hazard['confidence'] * 100).toStringAsFixed(0)}%',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  SectionCard(
                    child: Column(
                      children: [
                        InfoRow(
                          icon: Icons.location_on_outlined,
                          label: 'Zone',
                          value: selectedZone,
                        ),
                        const Divider(height: 24),
                        InfoRow(
                          icon: Icons.category_outlined,
                          label: 'Category',
                          value: category,
                        ),
                        const Divider(height: 24),
                        InfoRow(
                          icon: Icons.lightbulb_outline,
                          label: 'Recommended Action',
                          value: action,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      icon: const Icon(Icons.report_outlined, size: 20),
                      label: const Text(
                        'Report Hazard',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
                              location: selectedZone,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
    );
  }
}

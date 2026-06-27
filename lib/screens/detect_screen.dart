import 'dart:io';
import 'dart:convert';
import 'package:campus_hazard_detection/theme/app_theme.dart';
import 'package:flutter/material.dart';
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
    setState(() => isLoading = true);

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
      final body = await response.stream.bytesToString();
      final result = jsonDecode(body);

      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.sky.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
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
                          Text(
                            result['hazard'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SeverityBadge(severity: result['severity']),
                  ],
                ),
                const SizedBox(height: 16),
                InfoRow(
                  icon: Icons.category_outlined,
                  label: 'Category',
                  value: result['category'],
                ),
                const Divider(height: 24),
                InfoRow(
                  icon: Icons.percent_outlined,
                  label: 'Confidence',
                  value:
                      '${(double.parse(result['confidence'].toString()) * 100).toStringAsFixed(1)}%',
                ),
                const Divider(height: 24),
                InfoRow(
                  icon: Icons.lightbulb_outline,
                  label: 'Recommended Action',
                  value: result['action'],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      title: 'Preview Image',
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Hero(
              tag: widget.image.path,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  widget.image,
                  height: 380,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : detectHazard,
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.auto_awesome_outlined, size: 20),
                label: Text(
                  isLoading ? 'Analyzing…' : 'Analyze Hazard',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

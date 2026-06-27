import 'dart:io';
import 'package:campus_hazard_detection/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'report_success.dart';

class ReportScreen extends StatefulWidget {
  final File image;
  final String hazardClass;
  final String category;
  final String confidence;
  final String action;
  final String location;

  const ReportScreen({
    super.key,
    required this.image,
    required this.hazardClass,
    required this.category,
    required this.confidence,
    required this.action,
    required this.location,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final TextEditingController descriptionController = TextEditingController();
  String selectedRecipient = 'Campus Maintenance';

  final List<String> recipients = [
    'Campus Maintenance',
    'Security Office',
    'Facilities Management',
    'Residential Office',
    'Student Affairs',
  ];

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final confidenceValue = double.tryParse(widget.confidence) ?? 0.0;

    return GradientScaffold(
      title: 'Hazard Report',
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                widget.image,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            SectionCard(
              child: Column(
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
                              'Hazard',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              widget.hazardClass,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  InfoRow(
                    icon: Icons.category_outlined,
                    label: 'Category',
                    value: widget.category,
                  ),
                  const Divider(height: 24),
                  InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Location',
                    value: widget.location,
                  ),
                  const Divider(height: 24),
                  InfoRow(
                    icon: Icons.percent_outlined,
                    label: 'Confidence',
                    valueWidget: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: confidenceValue,
                            minHeight: 6,
                            backgroundColor: AppColors.sky.withValues(
                              alpha: 0.3,
                            ),
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${(confidenceValue * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 24),
                  InfoRow(
                    icon: Icons.lightbulb_outline,
                    label: 'Recommended Action',
                    value: widget.action,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Report To',
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
                    initialValue: selectedRecipient,
                    decoration: appInputDecoration(),
                    items: recipients.map((e) {
                      return DropdownMenuItem(value: e, child: Text(e));
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedRecipient = value!);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: appInputDecoration(
                hintText: 'Add additional description (optional)',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                icon: const Icon(Icons.send_outlined, size: 20),
                label: const Text(
                  'Submit Report',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ReportSuccessScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

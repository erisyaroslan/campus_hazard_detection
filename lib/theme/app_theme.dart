import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF1E40AF);
  static const accent = Color(0xFF3B82F6);
  static const sky = Color(0xFF93C5FD);
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFF0F6FF);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);

  static const gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6), Color(0xFFEFF6FF)],
    stops: [0.0, 0.45, 1.0],
  );
}

class GradientScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  const GradientScaffold({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text(title)),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradient),
        child: SafeArea(child: body),
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final Widget child;

  const SectionCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sky.withValues(alpha: 0.35)),
      ),
      child: child,
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? valueWidget;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    this.value = '',
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.accent),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              valueWidget ??
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

class SeverityBadge extends StatelessWidget {
  final String severity;

  const SeverityBadge({super.key, required this.severity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        severity,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

InputDecoration appInputDecoration({String? hintText}) {
  return InputDecoration(
    hintText: hintText,
    filled: true,
    fillColor: AppColors.background,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );
}

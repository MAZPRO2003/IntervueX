import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class EvidenceBadge extends StatelessWidget {
  final String label;

  const EvidenceBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;

    switch (label.toUpperCase()) {
      case 'VERIFIED FROM JOB POSTING':
        bg = AppColors.success.withOpacity(0.15);
        fg = AppColors.success;
        icon = Icons.verified_outlined;
        break;
      case 'OFFICIAL COMPANY INFORMATION':
        bg = AppColors.electricBlue.withOpacity(0.15);
        fg = AppColors.electricBlue;
        icon = Icons.business_outlined;
        break;
      case 'REPORTED BY CANDIDATES':
        bg = AppColors.indigoLight.withOpacity(0.15);
        fg = AppColors.indigoLight;
        icon = Icons.people_outline;
        break;
      case 'SUPPORTED BY MULTIPLE SOURCES':
        bg = const Color(0xFF10B981).withOpacity(0.15);
        fg = const Color(0xFF10B981);
        icon = Icons.fact_check_outlined;
        break;
      default:
        bg = AppColors.warning.withOpacity(0.15);
        fg = AppColors.warning;
        icon = Icons.auto_awesome_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withOpacity(0.3), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class ConfidenceBadge extends StatelessWidget {
  final String confidence; // High, Medium, Low

  const ConfidenceBadge({super.key, required this.confidence});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (confidence.toLowerCase()) {
      case 'high':
        color = AppColors.success;
        break;
      case 'medium':
        color = AppColors.warning;
        break;
      default:
        color = AppColors.danger;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            'Confidence: $confidence',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

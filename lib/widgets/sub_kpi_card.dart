import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SubKpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String? unit;
  final String bottomText;
  final Color valueColor;
  final Widget? customBottomWidget;

  const SubKpiCard({
    super.key,
    required this.title,
    required this.value,
    this.unit,
    required this.bottomText,
    this.valueColor = AppColors.textWhite,
    this.customBottomWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDarkBlue,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFFCBD5E1),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // Value + Unit
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: valueColor,
                  letterSpacing: -0.5,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(
                  unit!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: valueColor.withOpacity(0.85),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),

          // Bottom Widget or Text
          if (customBottomWidget != null)
            customBottomWidget!
          else
            Text(
              bottomText,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0xFF94A3B8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}

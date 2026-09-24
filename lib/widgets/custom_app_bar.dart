import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomDashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onDriversTap;
  final VoidCallback onNotificationsTap;

  const CustomDashboardAppBar({
    super.key,
    required this.onDriversTap,
    required this.onNotificationsTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(74);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardWhite,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 1.2),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Company Logo Image & Branding Badge
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderBlue, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x151E40AF),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/company_logo.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, _, __) => Container(
                      color: AppColors.primaryDarkBlue,
                      child: const Icon(
                        Icons.directions_bus_rounded,
                        color: AppColors.accentBlue,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title and Subtitle
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Flexible(
                          child: Text(
                            'مؤسسة سويقات أبو طالب',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.blueLight,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.borderBlue),
                          ),
                          child: const Text(
                            'نقل المسافرين',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accentBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'نظام متابعة سائقي الحافلات والرحلات اليومية',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Quick Actions: إدارة السائقين & Profile
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Quick Action: إدارة السائقين
                  InkWell(
                    onTap: onDriversTap,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.blueLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderBlue),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.group_rounded,
                            size: 16,
                            color: AppColors.accentBlue,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'إدارة السائقين',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accentBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Notification Bell with Badge
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      IconButton(
                        onPressed: onNotificationsTap,
                        icon: const Icon(
                          Icons.notifications_none_rounded,
                          color: AppColors.textPrimary,
                          size: 22,
                        ),
                        splashRadius: 20,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      ),
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.accentBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),

                  // User Avatar
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderBlue, width: 2),
                    ),
                    child: const Center(
                      child: Text(
                        'س.أ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

class TtAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showLogo;
  final String? title;
  final bool showAvatar;
  final bool showNotification;
  final List<Widget>? actions;

  const TtAppBar({
    super.key,
    this.showLogo = true,
    this.title,
    this.showAvatar = true,
    this.showNotification = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: showAvatar
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () => context.push(AppConstants.routeProfile),
                child: Stack(
                  children: [
                    const CircleAvatar(
                      backgroundColor: AppColors.colorPrimary,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppColors.colorXPBar,
                          shape: BoxShape.circle,
                        ),
                        child: const Text(
                          '24',
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
      title: showLogo
          ? Text(
              'TerraTech',
              style: AppTextStyles.heading.copyWith(fontSize: 20),
            )
          : (title != null
                ? Text(
                    title!,
                    style: AppTextStyles.heading.copyWith(fontSize: 20),
                  )
                : null),
      actions: [
        if (showNotification)
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: AppColors.colorPrimaryDark,
            ),
            onPressed: () {},
          ),
        if (actions != null) ...actions!,
      ],
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../theme/app_colors.dart';
import 'app_window_buttons.dart';

/// Top application bar: draggable, with the current page title on the left and
/// a search field, notification bell, user menu and window controls on the
/// right.
class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    required this.title,
    required this.isGuest,
    required this.onLogout,
  });

  final String title;
  final bool isGuest;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        children: [
          // Draggable title region (double-click to maximize/restore).
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onDoubleTap: () async {
                if (await windowManager.isMaximized()) {
                  await windowManager.unmaximize();
                } else {
                  await windowManager.maximize();
                }
              },
              child: DragToMoveArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: AppColors.heading,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
<<<<<<< HEAD
          _buildSearch(),
=======
>>>>>>> c5ce3bf (customer desing, add customer button, loan button, firebase)
          const SizedBox(width: 14),
          const _NotificationBell(),
          const SizedBox(width: 8),
          _UserMenu(isGuest: isGuest, onLogout: onLogout),
          const SizedBox(width: 12),
          const AppWindowButtons(),
          const SizedBox(width: 6),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      width: 240,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.fieldFill,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: const [
          Icon(Icons.search_rounded, size: 19, color: AppColors.muted),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              cursorColor: AppColors.primaryGreen,
              style: TextStyle(fontSize: 13.5, color: AppColors.heading),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Search…',
                hintStyle: TextStyle(fontSize: 13.5, color: AppColors.muted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationBell extends StatefulWidget {
  const _NotificationBell();

  @override
  State<_NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<_NotificationBell> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Notifications',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _hovering ? AppColors.fieldFill : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.notifications_none_rounded,
                  size: 22, color: AppColors.heading),
              Positioned(
                top: 10,
                right: 11,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserMenu extends StatelessWidget {
  const _UserMenu({required this.isGuest, required this.onLogout});

  final bool isGuest;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final String name = isGuest ? 'Guest' : 'Admin';
    final String role = isGuest ? 'Guest mode' : 'Administrator';

    return PopupMenuButton<String>(
      tooltip: '',
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (v) {
        if (v == 'logout') onLogout();
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.heading)),
              Text(role,
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.muted)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'profile',
          child: Row(children: [
            Icon(Icons.person_outline, size: 18, color: AppColors.heading),
            SizedBox(width: 10),
            Text('Profile'),
          ]),
        ),
        const PopupMenuItem(
          value: 'logout',
          child: Row(children: [
            Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
            SizedBox(width: 10),
            Text('Logout', style: TextStyle(color: AppColors.error)),
          ]),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.fieldFill,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: AppColors.primaryGreen,
              child: Text(
                name[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.heading,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.keyboard_arrow_down_rounded,
                size: 18, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

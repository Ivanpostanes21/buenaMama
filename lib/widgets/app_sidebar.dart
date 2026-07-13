import 'package:flutter/material.dart';

import '../models/nav_item.dart';
import '../theme/app_colors.dart';

const double _kExpandedWidth = 240;
const double _kCollapsedWidth = 74;
const double _kItemExtent = 54; // pill (44) + vertical margins (2 x 5)

/// Dark, collapsible navigation rail. Renders [kNavItems], a moving lime
/// selection indicator, guest-locked items and a pinned logout button.
class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.collapsed,
    required this.isGuest,
    required this.onSelect,
    required this.onToggleCollapse,
    required this.onLogout,
  });

  final int selectedIndex;
  final bool collapsed;
  final bool isGuest;
  final ValueChanged<int> onSelect;
  final VoidCallback onToggleCollapse;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOutCubic,
      width: collapsed ? _kCollapsedWidth : _kExpandedWidth,
      color: AppColors.sidebar,
      child: Column(
        children: [
          const SizedBox(height: 10),
          _buildToggle(),
          const SizedBox(height: 6),
          _buildBrand(),
          const SizedBox(height: 10),
          Divider(color: Colors.white.withValues(alpha: 0.07), height: 1),
          const SizedBox(height: 8),
          Expanded(child: _buildNav()),
          Divider(color: Colors.white.withValues(alpha: 0.07), height: 1),
          const SizedBox(height: 8),
          _SidebarButton(
            icon: Icons.logout_rounded,
            label: 'Logout',
            collapsed: collapsed,
            danger: true,
            onTap: onLogout,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: collapsed ? Alignment.center : Alignment.centerRight,
        child: _HoverIcon(
          icon: collapsed ? Icons.menu_rounded : Icons.menu_open_rounded,
          tooltip: collapsed ? 'Expand' : 'Collapse',
          onTap: onToggleCollapse,
        ),
      ),
    );
  }

  Widget _buildBrand() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 40,
        child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset('assets/logo.png', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.centerLeft,
                minWidth: 0,
                maxWidth: double.infinity,
                child: AnimatedOpacity(
                  opacity: collapsed ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: const Text(
                    'BuenaMama',
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildNav() {
    // Fixed-height Stack (so the moving indicator aligns) inside a scroll view,
    // keeping the rail robust on short windows.
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 6),
      child: SizedBox(
        height: kNavItems.length * _kItemExtent,
        child: Stack(
          children: [
            // Moving 4px lime indicator on the left edge.
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOutCubic,
              top: selectedIndex * _kItemExtent + 16,
              left: 0,
              child: Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Column(
              children: [
                for (int i = 0; i < kNavItems.length; i++)
                  _SidebarItem(
                    item: kNavItems[i],
                    selected: selectedIndex == i,
                    collapsed: collapsed,
                    locked: isGuest && kNavItems[i].lockedForGuest,
                    onTap: () => onSelect(i),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  const _SidebarItem({
    required this.item,
    required this.selected,
    required this.collapsed,
    required this.locked,
    required this.onTap,
  });

  final NavItem item;
  final bool selected;
  final bool collapsed;
  final bool locked;
  final VoidCallback onTap;

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final bool selected = widget.selected;
    final bool locked = widget.locked;

    final Color fg = locked
        ? AppColors.sidebarMuted.withValues(alpha: 0.5)
        : selected
            ? Colors.white
            : (_hovering ? Colors.white : AppColors.sidebarMuted);

    Widget content = Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        gradient: selected ? AppColors.logoGradient : null,
        color: !selected && _hovering && !locked
            ? Colors.white.withValues(alpha: 0.05)
            : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.centerLeft,
          minWidth: 0,
          maxWidth: double.infinity,
          child: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.item.icon, size: 21, color: fg),
                const SizedBox(width: 14),
                AnimatedOpacity(
                  opacity: widget.collapsed ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    widget.item.label,
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                      color: fg,
                      fontSize: 14,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (locked && !widget.collapsed) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.lock_rounded,
                      size: 13, color: AppColors.sidebarMuted),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    Widget item = MouseRegion(
      cursor:
          locked ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: locked ? null : widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      ),
    );

    // Tooltip: label when collapsed; "Login required" when locked.
    final String tip = locked
        ? 'Login required'
        : (widget.collapsed ? widget.item.label : '');
    if (tip.isEmpty) return item;
    return Tooltip(
      message: tip,
      waitDuration: const Duration(milliseconds: 400),
      child: item,
    );
  }
}

/// Bottom logout button (and any full-width sidebar action).
class _SidebarButton extends StatefulWidget {
  const _SidebarButton({
    required this.icon,
    required this.label,
    required this.collapsed,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final bool collapsed;
  final VoidCallback onTap;
  final bool danger;

  @override
  State<_SidebarButton> createState() => _SidebarButtonState();
}

class _SidebarButtonState extends State<_SidebarButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final Color fg = _hovering
        ? (widget.danger ? AppColors.error : Colors.white)
        : AppColors.sidebarMuted;

    Widget button = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 44,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: _hovering
                ? (widget.danger
                    ? AppColors.error.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.05))
                : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRect(
            child: OverflowBox(
              alignment: Alignment.centerLeft,
              minWidth: 0,
              maxWidth: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.icon, size: 21, color: fg),
                    const SizedBox(width: 14),
                    AnimatedOpacity(
                      opacity: widget.collapsed ? 0 : 1,
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        widget.label,
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                          color: fg,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (!widget.collapsed) return button;
    return Tooltip(
      message: widget.label,
      waitDuration: const Duration(milliseconds: 400),
      child: button,
    );
  }
}

class _HoverIcon extends StatefulWidget {
  const _HoverIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  State<_HoverIcon> createState() => _HoverIconState();
}

class _HoverIconState extends State<_HoverIcon> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 400),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _hovering
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              widget.icon,
              size: 20,
              color: _hovering ? Colors.white : AppColors.sidebarMuted,
            ),
          ),
        ),
      ),
    );
  }
}

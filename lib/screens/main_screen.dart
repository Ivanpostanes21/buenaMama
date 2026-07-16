import 'package:flutter/material.dart';

import '../models/nav_item.dart';
import '../theme/app_colors.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/app_topbar.dart';
import 'login/login_screen.dart';
import 'pages/customers_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/loans_page.dart';
import 'pages/payments_page.dart';
import 'pages/reports_page.dart';
import 'pages/settings_page.dart';
import 'pages/users_page.dart';
import '../window_setup.dart';

/// The main application shell shown after login / guest entry.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.isGuest});

  final bool isGuest;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late int _selectedIndex = widget.isGuest ? 1 : 0;
  bool _collapsed = false;

  // Replays a fade + slight upward slide whenever the page changes.
  late final AnimationController _pageController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
    value: 1,
  );
  late final Animation<double> _pageFade =
      CurvedAnimation(parent: _pageController, curve: Curves.easeOut);
  late final Animation<Offset> _pageSlide = Tween<Offset>(
    begin: const Offset(0, 0.03),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _pageController, curve: Curves.easeOutCubic));

  late final List<Widget> _pages = [
    DashboardPage(),
    CustomersPage(isGuest: widget.isGuest),
    LoansPage(),
    PaymentsPage(),
    ReportsPage(),
    UsersPage(),
    SettingsPage(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onSelect(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    _pageController.forward(from: 0);
  }

  Future<void> _logout() async {
    await exitToLoginWindow();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, _, _) => const LoginScreen(),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = kNavItems[_selectedIndex].label;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Column(
        children: [
          // Thin lime brand strip across the very top of the window.
          Container(
            height: 3,
            decoration:
                const BoxDecoration(gradient: AppColors.buttonGradient),
          ),
          Expanded(
            child: Row(
              children: [
                AppSidebar(
                  selectedIndex: _selectedIndex,
                  collapsed: _collapsed,
                  isGuest: widget.isGuest,
                  onSelect: _onSelect,
                  onToggleCollapse: () =>
                      setState(() => _collapsed = !_collapsed),
                  onLogout: _logout,
                ),
                Expanded(
                  child: Column(
                    children: [
                      AppTopBar(
                        title: title,
                        isGuest: widget.isGuest,
                        onLogout: _logout,
                      ),
                      Expanded(
                        child: FadeTransition(
                          opacity: _pageFade,
                          child: SlideTransition(
                            position: _pageSlide,
                            child: IndexedStack(
                              index: _selectedIndex,
                              children: _pages,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

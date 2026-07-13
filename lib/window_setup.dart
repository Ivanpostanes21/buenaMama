import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

/// Fixed dimensions for the frameless login window. Tall enough to fit the
/// full login card (including the error banner) without scrolling.
const Size kWindowSize = Size(400, 630);

/// Initializes [window_manager] and applies the frameless, fixed-size,
/// centered, non-resizable window configuration required for the login screen.
///
/// Call this from `main()` after `WidgetsFlutterBinding.ensureInitialized()`
/// and before `runApp()`.
Future<void> setupWindow() async {
  await windowManager.ensureInitialized();

  const options = WindowOptions(
    size: kWindowSize,
    minimumSize: kWindowSize,
    maximumSize: kWindowSize,
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    // Hide the OS title bar so we can draw our own frameless header.
    titleBarStyle: TitleBarStyle.hidden,
  );

  await windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.setResizable(false);
    await windowManager.setMaximizable(false);
    await windowManager.setMinimizable(true);
    await windowManager.center();
    await windowManager.show();
    await windowManager.focus();
  });
}

/// Size for the main application window shown after login / guest entry.
const Size kAppWindowSize = Size(1280, 800);
const Size kAppMinSize = Size(1100, 700);

/// Expands the small login window into the resizable main app window.
/// Called during the login → dashboard transition.
Future<void> enterAppWindow() async {
  // Lift the fixed-size lock the login window used.
  await windowManager.setMaximumSize(const Size(4000, 3000));
  await windowManager.setMinimumSize(kAppMinSize);
  await windowManager.setResizable(true);
  await windowManager.setMaximizable(true);
  await windowManager.setSize(kAppWindowSize);
  await windowManager.center();
}

/// Collapses the app window back to the fixed login window (used on logout).
Future<void> exitToLoginWindow() async {
  if (await windowManager.isMaximized()) {
    await windowManager.unmaximize();
  }
  await windowManager.setResizable(false);
  await windowManager.setMaximizable(false);
  await windowManager.setMinimumSize(kWindowSize);
  await windowManager.setMaximumSize(kWindowSize);
  await windowManager.setSize(kWindowSize);
  await windowManager.center();
}

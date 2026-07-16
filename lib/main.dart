import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
<<<<<<< HEAD

=======
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
>>>>>>> c5ce3bf (customer desing, add customer button, loan button, firebase)
import 'theme/app_colors.dart';
import 'window_setup.dart';
import 'screens/login/login_screen.dart';

Future<void> main() async {
  // Must run before any async work so the engine is ready for the
  // window_manager platform-channel calls below.
  WidgetsFlutterBinding.ensureInitialized();
<<<<<<< HEAD

=======
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
>>>>>>> c5ce3bf (customer desing, add customer button, loan button, firebase)
  // Configure the desktop window (fixed size, frameless, centered,
  // non-resizable) before the first frame is shown, so the user never sees a
  // flash of the default 1280x720 titled window.
  await setupWindow();

  runApp(const BuenaMamaApp());
}

class BuenaMamaApp extends StatelessWidget {
  const BuenaMamaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryGreen),
    );
    return MaterialApp(
      title: 'BuenaMama',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        // Poppins everywhere; individual widgets keep their explicit sizes.
        textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
      ),
      home: const LoginScreen(),
    );
  }
}

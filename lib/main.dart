
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/router/router.dart'; // Import the new router
import 'package:myapp/services/user_profile_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Make sure this file exists and is correctly configured

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileService()),
      ],
      child: const MyApp(),
    ),
  );
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Color _seedColor = Colors.deepPurple;

  ThemeMode get themeMode => _themeMode;
  Color get seedColor => _seedColor;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setSeedColor(Color color) {
    _seedColor = color;
    notifyListeners();
  }
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final Color primarySeedColor = themeProvider.seedColor;

        final TextTheme appTextTheme = TextTheme(
          displayLarge: GoogleFonts.oswald(fontSize: 57, fontWeight: FontWeight.bold),
          titleLarge: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500),
          bodyMedium: GoogleFonts.openSans(fontSize: 14),
          labelLarge: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
        );

        final ThemeData lightTheme = ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: primarySeedColor,
            brightness: Brightness.light,
          ),
          textTheme: appTextTheme,
          appBarTheme: AppBarTheme(
            backgroundColor: primarySeedColor,
            foregroundColor: Colors.white,
            titleTextStyle: GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: primarySeedColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        );

        final ColorScheme darkColorScheme = ColorScheme.fromSeed(
          seedColor: primarySeedColor,
          brightness: Brightness.dark,
        );

        final ThemeData darkTheme = ThemeData(
          useMaterial3: true,
          colorScheme: darkColorScheme,
          textTheme: appTextTheme,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.grey[900],
            foregroundColor: Colors.white,
            titleTextStyle: GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: darkColorScheme.primaryContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        );

        return MaterialApp.router(
          title: 'Flutter Dating App',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          routerConfig: router, // Use the new router
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'providers/theme_provider.dart';

void main() async {
  // Makes sure Flutter is ready before we start drawing the app.
  WidgetsFlutterBinding.ensureInitialized();

  // Locks the phone screen so it doesn't flip sideways when rotated.
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (_) async {
      await dotenv.load(fileName: 'assets/.env');
      runApp(const RecintoAdvMobProg());
    },
  );
}

class RecintoAdvMobProg extends StatelessWidget {
  const RecintoAdvMobProg({super.key});

  @override
  Widget build(BuildContext context) {
    // This provider acts like a global light switch we can reach from anywhere in the app.
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: ScreenUtilInit(
        designSize: const Size(412, 715),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          final themeProvider = context.watch<ThemeProvider>();
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            // The bright, daytime colors for the app.
            theme: ThemeData.light(),
            // The sleek, pitch-black nighttime colors to match your reference image.
            darkTheme: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: const Color(0xFF000000), 
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF000000),
                elevation: 0,
              ),
              cardColor: const Color(0xFF1C1C1C), 
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: Color(0xFF000000),
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.grey,
              ),
            ),
            themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
            title: 'E-Commerce App',
            initialRoute: '/home',
            routes: {
              '/home': (context) => const HomeScreen(),
              '/settings': (context) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}
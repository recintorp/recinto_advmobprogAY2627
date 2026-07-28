import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recinto_mobile/settings_screen.dart'; // Import the new settings screen

// main() is the entry point of the Flutter application.
// Its purpose is to initialize the app and wrap the root widget with ChangeNotifierProvider 
// so the ThemeModel state is available throughout the entire app.
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeModel(),
      child: const MyApp(),
    ),
  );
}

// ThemeModel is a class that manages the app-wide (global) state for the theme.
// It mixes in ChangeNotifier to alert any listening widgets whenever the state changes.
class ThemeModel with ChangeNotifier {
  // A private boolean variable to hold the current theme state (false = light, true = dark).
  bool _isDark = false;

  // A getter function that allows other parts of the app to safely read the _isDark value.
  bool get isDark => _isDark;

  // toggleTheme() is a function used to switch the theme state.
  // It flips the boolean value and calls notifyListeners() to trigger a UI rebuild for listening widgets.
  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}

// MyApp is the root widget of the application.
// Its purpose is to configure the MaterialApp and listen to the ThemeModel to apply the correct theme.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // The build() function describes the part of the user interface represented by this widget.
  @override
  Widget build(BuildContext context) {
    // We use Provider.of to listen to ThemeModel. When the theme toggles, this rebuilds the MaterialApp.
    final themeModel = Provider.of<ThemeModel>(context);

    return MaterialApp(
      // Dynamically setting the theme based on the isDark property from ThemeModel.
      theme: themeModel.isDark ? ThemeData.dark() : ThemeData.light(),
      home: const MyHomePage(),
    );
  }
}

// MyHomePage is a StatefulWidget that holds the ephemeral (local) state of the UI.
// Its purpose is to represent the main screen that contains both the local counter and the theme switch.
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  // createState() creates the mutable state instance for this widget.
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// _MyHomePageState manages the state for MyHomePage, specifically the ephemeral counter value.
class _MyHomePageState extends State<MyHomePage> {
  // An integer variable to hold the ephemeral state (the number of times the button was pressed).
  int _counter = 0;

  // _incrementCounter() is a function that increases the counter variable by 1.
  // It is wrapped in setState() to tell the Flutter framework to rebuild this specific widget.
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  // The build() function constructs the UI layout for the home screen.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ephemeral vs App State'),
        actions: [
          // Replaced the Switch with an IconButton that navigates to Settings
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // Triggers the _incrementCounter function when the user presses the button.
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
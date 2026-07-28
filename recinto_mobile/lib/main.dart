import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recinto_mobile/settings_screen.dart'; 

// setState is usually an in-built method of Flutter whereas Provider is the third-party package.

// main() is the entry point (usually the landing page, but it can always be configured.) of the Flutter application. Its purpose is to initialize the app and wrap the root widget with ChangeNotifierProvider so that the ThemeModel state is available throughout the entire app.
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeModel(),
      child: const MyApp(),
    ),
  );
}

// ThemeModel is a class that manages the app-wide or the global state for the theme, it can either be dark, light or default mode.
// It mixes in ChangeNotifier to alert any listening widgets whenever the state changes, basically it calls the application to change state depending on the user's choice.
class ThemeModel with ChangeNotifier {
// A private boolean variable to hold the current theme state (false = light, true = dark). This is the most efficient rule to apply the function.
  bool _isDark = false;

// I had use a getter function that allows other parts of the app to safely read the _isDark value.
  bool get isDark => _isDark;

// toggleTheme() is a function used to switch the theme state of the application screen.
// It flips the boolean value and calls notifyListeners() to trigger a UI rebuild for listening widgets.
  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}

// My App's purpose is to configure the MaterialApp and listen to the ThemeModel to apply the correct theme.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

// The build() function often describes the part of the user interface represented by this widget.
  @override
  Widget build(BuildContext context) {
// I had use Provider.of to listen to ThemeModel. When the theme toggles, this rebuilds the MaterialApp.
    final themeModel = Provider.of<ThemeModel>(context);

    return MaterialApp(
      theme: themeModel.isDark ? ThemeData.dark() : ThemeData.light(),
      home: const MyHomePage(),
    );
  }
}

// MyHomePage is a StatefulWidget that holds the ephemeral state of the UI. Its purpose is to represent the main screen that contains both the local counter and the theme switch.
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

// createState() creates the mutable state instance for this widget.
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// _MyHomePageState manages the state for MyHomePage, specifically the ephemeral counter value.
class _MyHomePageState extends State<MyHomePage> {
// An integer variable to hold the ephemeral state (the number of times the button was pressed). We can see this in the main screen of the application.
  int _counter = 0;

// _incrementCounter() is a function that increases the counter variable by 1, so basically 1, 2, 3, 4 and so on...
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ephemeral vs App State'),
        actions: [
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

        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
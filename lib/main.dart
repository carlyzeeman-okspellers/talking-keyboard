import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Talking Keyboard',
      theme: ThemeData.dark(), // Black background
      home: KeyboardPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class KeyboardPage extends StatefulWidget {
  @override
  _KeyboardPageState createState() => _KeyboardPageState();
}

class _KeyboardPageState extends State<KeyboardPage> {
  final FlutterTts flutterTts = FlutterTts();
  String typedLetters = '';

  // ABC and QWERTY layouts
  final List<List<String>> abcRows = [
    ['A','B','C','D','E'],
    ['F','G','H','I','J'],
    ['K','L','M','N','O'],
    ['P','Q','R','S','T'],
    ['U','V','W','X','Y','Z'],
  ];

  final List<List<String>> qwertyRows = [
    ['Q','W','E','R','T','Y','U','I','O','P'],
    ['A','S','D','F','G','H','J','K','L'],
    ['Z','X','C','V','B','N','M'],
  ];

  bool useABC = true;

  @override
  void initState() {
    super.initState();
    // Listen to keyboard events
    RawKeyboard.instance.addListener(_handleKey);
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_handleKey);
    super.dispose();
  }

  void _handleKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      String key = event.logicalKey.keyLabel.toUpperCase();
      if (RegExp(r'^[A-Z]$').hasMatch(key)) {
        _speak(key);
      }
    }
  }

  void _speak(String letter) async {
    await flutterTts.speak(letter);
    setState(() {
      typedLetters += letter;
    });
  }

  void _done() {
    setState(() {
      typedLetters += '.';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Done!')),
    );
  }

  Widget _buildKeyboard(List<List<String>> rows) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: rows.map((row) {
            return Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: row.map((letter) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: GestureDetector(
                        onTap: () => _speak(letter),
                        child: Container(
                          alignment: Alignment.center,
                          color: Colors.grey[800],
                          child: Text(
                            letter,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 60, // Fixed font size
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<List<String>> currentLayout = useABC ? abcRows : qwertyRows;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top white bar
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: EdgeInsets.all(8),
              child: Text(
                typedLetters,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
            SizedBox(height: 8),
            // Toggle button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      useABC = !useABC;
                    });
                  },
                  child: Text(useABC ? 'Switch to QWERTY' : 'Switch to ABC'),
                ),
              ),
            ),
            // Keyboard
            _buildKeyboard(currentLayout),
            // Done button
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _done,
                  child: Text('Done'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

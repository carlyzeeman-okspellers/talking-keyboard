import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(TalkingKeyboardApp());
}

class TalkingKeyboardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Talking Keyboard',
      home: KeyboardHomePage(),
    );
  }
}

class KeyboardHomePage extends StatefulWidget {
  @override
  _KeyboardHomePageState createState() => _KeyboardHomePageState();
}

class _KeyboardHomePageState extends State<KeyboardHomePage> {
  FlutterTts flutterTts = FlutterTts();
  String typedText = '';
  bool isQwerty = false;
  bool showNumbers = false;

  final abcRows = [
    ['A', 'B', 'C', 'D', 'E'],
    ['F', 'G', 'H', 'I', 'J'],
    ['K', 'L', 'M', 'N', 'O'],
    ['P', 'Q', 'R', 'S', 'T'],
    ['U', 'V', 'W', 'X', 'Y', 'Z']
  ];

  final qwertyRows = [
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['Z', 'X', 'C', 'V', 'B', 'N', 'M']
  ];

  final numberRows = [
    ['0', '1', '2', '3', '4'],
    ['5', '6', '7', '8', '9'],
    ['+', '-', '×', '÷', '=']
  ];

  @override
  void initState() {
    super.initState();
    // Listen for physical keyboard input
    RawKeyboard.instance.addListener(_handleKey);
    flutterTts.setSpeechRate(1.0); // Adjust speed if needed
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_handleKey);
    flutterTts.stop();
    super.dispose();
  }

  void _handleKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      String key = event.logicalKey.keyLabel.toUpperCase();
      if ((key.length == 1 && RegExp(r'[A-Z0-9+\-×÷=]').hasMatch(key)) || key == 'X') {
        _speakAndAddKey(key);
      }
    }
  }

  Future<void> _speakAndAddKey(String key) async {
    setState(() {
      if (key == 'X') {
        typedText = '';
      } else {
        typedText += key;
      }
    });
    await flutterTts.speak(key);
  }

  Widget buildKey(String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            textStyle: TextStyle(fontSize: 65, fontWeight: FontWeight.bold),
          ),
          child: Text(label),
          onPressed: () => _speakAndAddKey(label),
        ),
      ),
    );
  }

  Widget buildRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.map((k) => buildKey(k)).toList(),
    );
  }

  Widget buildKeyboard() {
    List<List<String>> rows;
    if (showNumbers) {
      rows = numberRows;
    } else if (isQwerty) {
      rows = qwertyRows;
    } else {
      rows = abcRows;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Add X button on top row
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  textStyle: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                ),
                child: Text('X'),
                onPressed: () {
                  setState(() {
                    typedText = '';
                  });
                  flutterTts.speak('Clear');
                },
              ),
            ],
          ),
        ),
        ...rows.map((r) => buildRow(r)).toList(),
        SizedBox(height: 10),
        // DONE button
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                textStyle: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
              ),
              child: Text('DONE'),
              onPressed: () {
                setState(() {
                  typedText += '.';
                });
                flutterTts.speak('Period');
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Toggle buttons
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isQwerty ? Colors.blue : Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('ABC'),
                    onPressed: () {
                      setState(() {
                        isQwerty = false;
                        showNumbers = false;
                      });
                    },
                  ),
                  SizedBox(width: 5),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isQwerty ? Colors.grey : Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('QWERTY'),
                    onPressed: () {
                      setState(() {
                        isQwerty = true;
                        showNumbers = false;
                      });
                    },
                  ),
                  SizedBox(width: 5),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: showNumbers ? Colors.blue : Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('123'),
                    onPressed: () {
                      setState(() {
                        showNumbers = true;
                        isQwerty = false;
                      });
                    },
                  ),
                ],
              ),
            ),
            // Text display
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.all(8),
              width: double.infinity,
              child: Text(
                typedText,
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            Expanded(child: buildKeyboard()),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:word_selectable_text/word_selectable_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'dart:math' as math;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BulletNote',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.deepOrange,
      ),
      home: const MyHomePage(title: 'BulletNote'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  int counter = 0;
  String buffer = '';
  String testWords =
      "Flutter transforms the app development process. Build, test, and deploy beautiful mobile, web, desktop, and embedded apps from a single codebase.";

  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  List<String> bullets = [];

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    bullets.add(_lastWords);
    setState(() {
      _lastWords = "";
    });
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    if (_speechToText.isListening == true) {
      setState(() {
        _lastWords = result.recognizedWords;
      });
    }
  }

  void incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      counter++;
      buffer += 'Test.. ';
    });
  }

  void splitText(String word, int index, int pointIndex) {
    setState(() {
      List<String> splitPoint = bullets[pointIndex].split(' ');

      if (index != 0) {
        //bullets.add(splitPoint[index - 1]);
        // splitPoint[index - 1] = '${splitPoint[index - 1]}\n';

        List<String> beforeSplit = [];
        List<String> afterSplit = [];

        for (int i = 0; i < splitPoint.length; i++) {
          if (i < index) {
            beforeSplit.add(splitPoint[i]);
          } else {
            afterSplit.add(splitPoint[i]);
          }
        }
        bullets.remove(bullets[pointIndex]);
        //bullets.remove(bullets[bullets.length - 1]);
        bullets.insert(pointIndex, beforeSplit.join(' '));
        bullets.insert(pointIndex + 1, afterSplit.join(' '));
      } else {
        bullets[pointIndex] = splitPoint.join(' ');
      }
      //bullets.add(splitPoint.join(' '));
      // bullets.clear();
      // bullets.add(_lastWords);
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: ListView(
          // ignore: sort_child_properties_last
          children: [
            for (String point in bullets)
              Row(
                children: [
                  SpaceChanger(),
                  Text(
                    "\u2022",
                    style: TextStyle(fontSize: 30),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: WordSelectableText(
                      selectable: true,
                      highlight: true,
                      highlightColor: Colors.deepOrangeAccent,
                      text: point,
                      onWordTapped: (word, index) {
                        // print(word);
                        // print(index);
                        splitText(word, index!, bullets.indexOf(point));
                      },
                    ),
                  ),
                ],
              ),
            Text(_lastWords),
          ],
          // This trailing comma makes auto-formatting nicer for build methods.
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      // onPressed:
      //     // If not yet listening for speech start, otherwise stop
      //     _speechToText.isNotListening ? _startListening : _stopListening,
      // tooltip: 'Listen',
      // child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
      // ),
      // ignore: prefer_const_constructors
      floatingActionButton: ExpandableFab(
        distance: 112.0,
        // ignore: prefer_const_literals_to_create_immutables
        children: [
          // ignore: prefer_const_constructors
          ActionButton(
            onPressed: () => showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                      title: const Text("How to use BulletNote:"),
                      content: const Text(
                          "Press record in menu button to start recording speech.\n\nTap on a word to create new bullet point.\n\nSingle tap before bullet to increase indentation.\n\nDouble tap before bullet to decrease indentation."),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, "OK"),
                          child: const Text("OK"),
                        )
                      ],
                    )),
            icon: const Icon(Icons.help_outline_rounded),
          ),
          // ignore: prefer_const_constructors
          ActionButton(
            // onPressed: () => _showAction(context, 1),
            icon: Icon(_speechToText.isNotListening
                ? Icons.mic_off_outlined
                : Icons.mic_outlined),
            onPressed:
                // If not yet listening for speech start, otherwise stop
                _speechToText.isNotListening ? _startListening : _stopListening,
          ),
          // ignore: prefer_const_constructors
          ActionButton(
            // onPressed: () => {},
            icon: const Icon(Icons.save_outlined),
          ),
        ],
      ),
    );
  }
}

class SpaceChanger extends StatefulWidget {
  //final Widget child;

  const SpaceChanger({Key? key}) : super(key: key);
  @override
  State<SpaceChanger> createState() => _SpaceChangerState();
}

class _SpaceChangerState extends State<SpaceChanger> {
  double size = 50;

  void _increaseSize() {
    setState(() {
      if (size >= 50) {
        size += 50;
      }
    });
  }

  void _decreaseSize() {
    setState(() {
      if (size > 50) {
        size -= 50;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: 50,
      child: GestureDetector(
        onTap: _increaseSize,
        onDoubleTap: _decreaseSize,
      ),
    );
  }
}

@immutable
class ExpandableFab extends StatefulWidget {
  const ExpandableFab({
    super.key,
    this.initialOpen,
    required this.distance,
    required this.children,
  });

  final bool? initialOpen;
  final double distance;
  final List<Widget> children;

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen ?? false;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    return SizedBox(
      width: 56.0,
      height: 56.0,
      child: Center(
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4.0,
          child: InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.close,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    final step = 90.0 / (count - 1);
    for (var i = 0, angleInDegrees = 0.0;
        i < count;
        i++, angleInDegrees += step) {
      children.add(
        _ExpandingActionButton(
          directionInDegrees: angleInDegrees,
          maxDistance: widget.distance,
          progress: _expandAnimation,
          child: widget.children[i],
        ),
      );
    }
    return children;
  }

  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _open ? 0.7 : 1.0,
          _open ? 0.7 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton(
            onPressed: _toggle,
            child: const Icon(Icons.menu_rounded),
          ),
        ),
      ),
    );
  }
}

@immutable
class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionInDegrees * (math.pi / 180.0),
          progress.value * maxDistance,
        );
        return Positioned(
          right: 4.0 + offset.dx,
          bottom: 4.0 + offset.dy,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * math.pi / 2,
            child: child!,
          ),
        );
      },
      child: FadeTransition(
        opacity: progress,
        child: child,
      ),
    );
  }
}

@immutable
class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    this.onPressed,
    required this.icon,
  });

  final VoidCallback? onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: theme.colorScheme.secondary,
      elevation: 4.0,
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
        color: Colors.white,
      ),
    );
  }
}

@immutable
class FakeItem extends StatelessWidget {
  const FakeItem({
    super.key,
    required this.isBig,
  });

  final bool isBig;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
      height: isBig ? 128.0 : 36.0,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        color: Colors.grey.shade300,
      ),
    );
  }
}

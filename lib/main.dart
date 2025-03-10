import 'package:flutter/material.dart';
import 'helper.dart';
/*
  Objective: card-matching game w animation+state management, player shld match cards from
    a grid of face-down cards -> flip to find pairs
  UI: gridview or smth else 
    - grid of face-down cards (4x4 or 6x6)
    - back design [common pattern]
  state management: eg Provider to manage it
    data model for cards with 
      front+back design properties
      current state [face up or down]
  animation:   animatedbuilder or animatedcontainer
    flip from down -> up and vice versa
  game logic: track if currently up or down
    when player taps 2 face-down cards, check if they match
      MATCH -> keep face up
      NOT MATCH -> flip face-down again
  win condition: check if all pairs r matched -> display victory msg
*/
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
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

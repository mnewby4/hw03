import 'package:flutter/material.dart';
import 'helper.dart';
import 'dart:math';
DatabaseHelper myHelper = DatabaseHelper();
/*
  Objective: card-matching game w animation+state management, player shld match cards from
    a grid of face-down cards -> flip to find pairs
  UI: gridview or smth else 
    - grid of face-down cards (4x4 or 6x6)
    - back design [common pattern]
  Xstate management: eg Provider to manage it
    Xdata model for cards with 
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
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await myHelper.init();
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
      home: const MyHomePage(title: 'Card Game'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class Card {
  final int cardID; 
  final int isCardUp;
  final String backDesign;
  final String frontDesign;

  Card({
    required this.cardID, 
    required this.isCardUp, 
    required this.backDesign, 
    required this.frontDesign
  });

  Map<String, Object?> toMap() {
    return {'_id': cardID, 'isCardUp': isCardUp, 'backDesign': backDesign, 'frontDesign': frontDesign};
  }
  @override
  String toString() {
    return 'Card{_id: $cardID, isCardUp: $isCardUp, backDesign: $backDesign, frontDesign: $frontDesign}';
  }
  
}

class _MyHomePageState extends State<MyHomePage> {
  List<Card> sessionCards = [];
  List<int> takenNums = [];
  int cardsMax = 16;

  @override
  void initState() {
    super.initState();
    _generateCards();
  }

  void _generateCards() async {
    //setState(() {
      //generate 8 different numbers, create them 2x -> 16 total
      Random random = new Random();
      for (int i = 0; sessionCards.length < cardsMax; i++) {
        //make each property so they can be created 2x
        //pick random from 1-8 [ids 1-13] and ALSO make sure that num ISNT alrdy taken
        int randomNum = random.nextInt(13) + 1;
        if (!takenNums.contains(randomNum)) {
          takenNums.add(randomNum);
          //List<Map<String, dynamic>> fetchCard = await myHelper.queryOneRow(randomNum);
          //Card currentCard = 
          Card? currentCard = await myHelper.queryOneRow(randomNum);
          sessionCards.add(currentCard!);
          sessionCards.add(currentCard!);
          //print('CURRENT SESSION CARDS; $sessionCards');
        }
      }
        sessionCards.shuffle();
        setState(() {});
  }

  Future<List<Map<String, dynamic>>> _display() async {
    return await myHelper.queryAllRows();
  }
  Future<int> _countReturn() async {
    return await myHelper.queryRowCount();
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
        children: [
          Text("\nFind all the matching pairs!\n\n",
          style: Theme.of(context).textTheme.headlineLarge),
          Expanded(
            child: GridView.builder(
              itemCount: sessionCards.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                return Center(
                  child: Column(
                    children: [                      
                      Image.network(
                        sessionCards[index].isCardUp == 1
                            ? sessionCards[index].frontDesign
                            : sessionCards[index].backDesign,
                        width: 90,
                        height: 93,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
}
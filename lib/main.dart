import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'helper.dart';
import 'dart:math' as math;
DatabaseHelper myHelper = DatabaseHelper();
/*
  Objective: card-matching game w animation+state management, player shld match cards from
    a grid of face-down cards -> flip to find pairs
  XUI: gridview or smth else 
    X- grid of face-down cards (4x4 or 6x6)
    X- back design [common pattern]
  Xstate management: eg Provider to manage it
    Xdata model for cards with 
      Xfront+back design properties
      Xcurrent state [face up or down]
  Xanimation:   animatedbuilder or animatedcontainer
   X flip from down -> up and vice versa
  Xgame logic: track if currently up or down
    Xwhen player taps 2 face-down cards, check if they match
      XMATCH -> keep face up
      XNOT MATCH -> flip face-down again
 X win condition: check if all pairs r matched -> display victory msg
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
  int isCardUp;
  final String backDesign;
  final String frontDesign;
  int duplicateId;

  Card({
    required this.cardID, 
    required this.isCardUp, 
    required this.backDesign, 
    required this.frontDesign,
    required this.duplicateId,
  });

  /*Map<String, Object?> toMap() {
    return {'_id': cardID, 'isCardUp': isCardUp, 'backDesign': backDesign, 'frontDesign': frontDesign};
  }*/
  @override
  String toString() {
    return 'Card{_id: $cardID, isCardUp: $isCardUp, backDesign: $backDesign, frontDesign: $frontDesign, duplicateId: $duplicateId}';
  }
  
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  List<Card> sessionCards = [];
  List<int> takenNums = [];
  int cardsMax = 16;
  List<Card> matchedCards = [];
  List<Card> tappedCards = [];
  String message = "Find all the matching pairs!";
  
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {}); 
      });
    _generateCards();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _generateCards() async {
    math.Random random = math.Random();
    while (sessionCards.length < cardsMax) {
      int randomNum = random.nextInt(13) + 1;
      if (!takenNums.contains(randomNum)) {
        takenNums.add(randomNum);
        Card? currentCard = await myHelper.queryOneRow(randomNum);
        if (currentCard != null) {
          sessionCards.addAll([
            Card(
              cardID: currentCard.cardID,
              isCardUp: 0,
              frontDesign: currentCard.frontDesign,
              backDesign: currentCard.backDesign,
              duplicateId: sessionCards.length,
            ),
            Card(
              cardID: currentCard.cardID,
              isCardUp: 0,
              frontDesign: currentCard.frontDesign,
              backDesign: currentCard.backDesign,
              duplicateId: sessionCards.length + 1,
            ),
          ]);
        }
      }
    }
    sessionCards.shuffle();
    setState(() {});
  }

  void _flipCard(int index) {
    setState(() {
      if (tappedCards.length >= 2 || matchedCards.contains(sessionCards[index]) || tappedCards.contains(sessionCards[index])) {
        return;
      }
      sessionCards[index].isCardUp = (sessionCards[index].isCardUp == 1) ? 0 : 1;
      tappedCards.add(sessionCards[index]);
      if (tappedCards.length == 2) {
        int firstIndex = tappedCards[0].duplicateId;
        int secondIndex = tappedCards[1].duplicateId;
        if (tappedCards[0].cardID == tappedCards[1].cardID) {
          message = "Match found!";
          matchedCards.add(sessionCards[firstIndex]);
          matchedCards.add(sessionCards[secondIndex]);
          tappedCards.clear();
        } else {
          Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              tappedCards[0].isCardUp = 0;
              tappedCards[1].isCardUp = 0;
              tappedCards.clear();
              message = "Try again.";
            });
          });
        }
        if (matchedCards.length == cardsMax) {
          message = "You won! Congrats!!";
        }
      }
    });
  }

  Widget _buildCard(int index) {
    bool isFaceUp = sessionCards[index].isCardUp == 1;
    return GestureDetector(
      onTap: () => _flipCard(index),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform(
            transform: Matrix4.rotationY(isFaceUp ? 0 : math.pi),
            alignment: Alignment.center,
            child: Container(
              width: 80,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: isFaceUp
                  ? Image.network(sessionCards[index].frontDesign)
                  : Image.network(sessionCards[index].backDesign),
            ),
          );
        },
      ),
    );
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
            Text("\n$message\n\n",
                style: Theme.of(context).textTheme.headlineLarge),
            Expanded(
              child: GridView.builder(
                itemCount: sessionCards.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                ),
                itemBuilder: (context, index) => _buildCard(index),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

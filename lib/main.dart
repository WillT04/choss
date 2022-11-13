import 'package:choss/chess_board.dart';
import 'package:choss/data.dart';
import 'package:choss/end_screen.dart';
import 'package:choss/intro_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Board().startGame();

    // Board().board[0][4]!.move(4, 3);

    return MaterialApp(
      title: 'Choss',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        backgroundColor: Colors.lightBlueAccent,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: {
        "/": (context) => const IntroScreen(),
        "/game": (context) => const HomePage(),
        "/end": (context) => const EndScreen(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  // Its like chess but better - Volunteer
  // Slay -  MW
  // I like it - CompSoc
  // Shit - MW

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    TextStyle currentPlayerTextStyle = const TextStyle(
      fontSize: 35,
      fontWeight: FontWeight.bold,
    );

    TextStyle otherPlayerTextStyle = const TextStyle(
      fontSize: 35,
      color: Colors.black26,
    );

    bool isWhite = Board().isWhite;

    return Scaffold(
      backgroundColor: Colors.blue[200],
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(builder: (context, constraint) {
          double width = constraint.maxHeight;
          double height = constraint.maxWidth;

          double size = width < height ? width : height;

          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Player 1's Turn",
                    style:
                        isWhite ? currentPlayerTextStyle : otherPlayerTextStyle,
                  ),
                  Text(
                    "Turn ${(Board().turnCount / 2).floor() + 1}",
                    style: currentPlayerTextStyle,
                  ),
                  Text(
                    "Player 2's Turn",
                    style:
                        isWhite ? otherPlayerTextStyle : currentPlayerTextStyle,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: size * 0.85,
                height: size * 0.85,
                child: ChessBoard(voidCallback: rebuild),
              ),
              // Board().special
              //     ? Align(
              //         alignment: Alignment(0, 1),
              //         child: Text("You got a powerup!\n ${Board().powerUp}"),
              //       )
              //     : Container(),
            ],
          );
        }),
      ),
    );
  }

  void rebuild() {
    setState(() => build(context));
  }
}

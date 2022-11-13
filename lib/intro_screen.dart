import 'package:choss/data.dart';
import 'package:flutter/material.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[200],
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 150),
            const Text(
              "Welcome to Choss!",
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Board().startGame();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  "/game",
                  (route) => false,
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Play Now!",
                  style: TextStyle(
                    fontSize: 40,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 100),
            Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                children: const [
                  Text(
                    "What is Choss?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    "Choss is the next big thing! We have brought the best of chess and esports together into this amalgamation of fun!",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "How to play?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    "Choss is easy to play as it combines the classic game of chess with fast paced and frantic suprises. Watch how one mystery box can transform the entire game.",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "What are in the mystery boxes?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    "Oh I'm glad you asked! These mystery boxes contain the biggest suprise of all! Your piece can change! Our proprietry algorithm (patent pending) helps to  reinvigorate the game!",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:choss/data.dart';
import 'package:flutter/material.dart';

class EndScreen extends StatelessWidget {
  const EndScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[200],
      body: Center(
        child: Text(
          "The winner is ${Board().isWhite ? "Player 1" : "Player 2"}",
          style: TextStyle(fontSize: 32),
        ),
      ),
    );
  }
}

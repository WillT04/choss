import 'package:choss/data.dart';
import 'package:choss/pieces/pieces.dart';
import 'package:flutter/material.dart';

class ChessBoard extends StatefulWidget {
  final VoidCallback voidCallback;

  const ChessBoard({super.key, required this.voidCallback});

  @override
  State<ChessBoard> createState() => _ChessBoardState();
}

class _ChessBoardState extends State<ChessBoard> {
  List<List<int>> validMoves = [];
  List<int> currentPiece = [];

  List<int> powerupPos = [];

  bool done = false;

  @override
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Board().isMate) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/end",
          (route) => false,
        );
      }
      // } else if (Board().special) {
      //   done = true;
      //   setState(() => build(context));
      // } else {
      //   done = false;
      // }
    });

    powerupPos = [Board().powerupI, Board().powerupJ];

    return LayoutBuilder(builder: (context, constraint) {
      return Padding(
        padding: const EdgeInsets.all(30),
        child: Stack(
          children: [
            GridView.count(
              primary: false,
              // crossAxisSpacing: 5,
              // mainAxisSpacing: 5,
              crossAxisCount: 8,
              children: getBoard(),
            ),
            GridView.count(
              primary: false,
              // crossAxisSpacing: 5,
              // mainAxisSpacing: 5,
              crossAxisCount: 8,
              children: getPieces(),
            ),
            GridView.count(
              primary: false,
              // crossAxisSpacing: 5,
              // mainAxisSpacing: 5,
              crossAxisCount: 8,
              children: getValidMoves(),
            ),
            GridView.count(
              primary: false,
              // crossAxisSpacing: 5,
              // mainAxisSpacing: 5,
              crossAxisCount: 8,
              children: getButtons(),
            ),
          ],
        ),
      );
    });
  }

  List<Widget> getBoard() {
    List<Widget> children = [];
    int count = 0;
    Color colour = const Color.fromARGB(255, 253, 233, 176);

    for (int i = 0; i < 64; i++) {
      int y = i ~/ 8;
      int x = i % 8;

      Color tempColour = colour;
      if (Board().inCheck) {
        if (y == Board().checkPiece[0] && x == Board().checkPiece[1]) {
          tempColour = Colors.red;
        }
      }

      if (Board().special) {
        if (Board().specialPiece.isNotEmpty) {
          if (y == Board().specialPiece[0] && x == Board().specialPiece[1]) {
            tempColour = Colors.purple;
          }
        }
      }

      if (y == powerupPos[0] && x == powerupPos[1]) tempColour = Colors.green;

      children.add(
        Container(
          color: tempColour,
        ),
      );

      count++;
      if (count < 8) {
        colour = colour == const Color.fromARGB(255, 253, 233, 176)
            ? Colors.brown
            : const Color.fromARGB(255, 253, 233, 176);
      } else {
        count = 0;
      }
    }
    return children;
  }

  List<Widget> getPieces() {
    List<Widget> children = [];
    List<List<Piece?>> board = Board().board;

    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        Piece? piece = board[i][j];

        if (piece != null) {
          Widget pieceWidget = PieceManager.getPieceWidget(piece)!;
          children.add(pieceWidget);
        } else {
          children.add(Container());
        }
      }
    }
    return children;
  }

  List<Widget> getValidMoves() {
    List<Widget> children = [];

    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        bool done = false;
        for (List<int> move in validMoves) {
          if (move[0] == i && move[1] == j) {
            children.add(
              LayoutBuilder(builder: (context, constraints) {
                return Padding(
                  padding: EdgeInsets.all(constraints.maxHeight * 0.4),
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                      color: Colors.red,
                    ),
                  ),
                );
              }),
            );
            done = true;
            break;
            // }
          }
        }
        if (!done) {
          children.add(Container());
        }
      }
    }
    return children;
  }

  List<Widget> getButtons() {
    List<Widget> children = [];

    for (int i = 0; i < 64; i++) {
      children.add(
        InkWell(
          onTap: () => tappedSpace(i),
        ),
      );
    }
    return children;
  }

  void tappedSpace(int squareNumber) {
    int i = squareNumber ~/ 8;
    int j = squareNumber % 8;

    List<List<Piece?>> board = Board().board;

    if (currentPiece.isNotEmpty) {
      for (List<int> validMove in validMoves) {
        if (i == validMove[0] && j == validMove[1]) {
          Board().board[currentPiece[1]][currentPiece[0]]!.move(i, j);
          currentPiece = [];
          validMoves = [];
          Board().turnCount++;

          widget.voidCallback();
          return;
        }
      }
    }

    Piece? piece = board[i][j];

    List<List<int>> newValidMoves = [];
    currentPiece = [];

    if (piece != null && piece.isWhite == Board().isWhite) {
      currentPiece = [j, i];
      List<List<int>> tempValidMoves = piece.validMoves();

      print("b: " + Board().specialPiece.toString());
      print("c: " + currentPiece.toString());

      if (Board().inCheck) {
        Board().getOutOfCheck.forEach((key, value) {
          if (key[0] == currentPiece[1] && key[1] == currentPiece[0]) {
            for (List<int> tempValidMove in tempValidMoves) {
              for (List<int> avaliableMove in value) {
                if (tempValidMove[0] == avaliableMove[0] &&
                    tempValidMove[1] == avaliableMove[1]) {
                  newValidMoves.add(tempValidMove);
                }
              }
            }
          }
        });

        // for (List<int> tempValidMove in tempValidMoves) {
        //   Board().getOutOfCheck.forEach((key, value) {
        //     if (currentPiece == key) {
        //       for (List<int> avaliableMove in value) {
        //         if (tempValidMove[0] == avaliableMove[0] &&
        //             tempValidMove[1] == avaliableMove[1]) {
        //           newValidMoves.add(tempValidMove);
        //         }
        //       }
        //     }
        //   });
        // }
      } else if (Board().special) {
        if (currentPiece[1] == Board().specialPiece[0] &&
            currentPiece[0] == Board().specialPiece[1]) {
          newValidMoves = tempValidMoves;
        }
      } else {
        newValidMoves = tempValidMoves;
      }
    }

    setState(() => validMoves = newValidMoves);
  }
}

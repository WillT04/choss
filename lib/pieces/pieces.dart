import 'package:choss/data.dart';
import 'package:choss/pieces/general_piece.dart';
import 'package:flutter/material.dart';

class PieceManager {
  static Widget? getPieceWidget(Piece piece) {
    switch (piece.id) {
      case 5:
        return Queen(piece: piece);
      case 6:
        return King(piece: piece);
      case 4:
        return Knight(piece: piece);
      case 3:
        return Rook(piece: piece);
      case 2:
        return Bishop(piece: piece);
      case 1:
        return Pawn(piece: piece);
      default:
        return null;
    }
  }
}

// 5
class Queen extends StatelessWidget {
  // final int id = 5;
  final Piece piece;

  const Queen({super.key, required this.piece});

  @override
  Widget build(BuildContext context) {
    return GeneralPiece(piece: piece);
  }
}

// 6
class King extends StatelessWidget {
  // final int id = 6;
  final Piece piece;

  const King({super.key, required this.piece});

  @override
  Widget build(BuildContext context) {
    return GeneralPiece(piece: piece);
  }
}

// 4
class Knight extends StatelessWidget {
  // final int id = 4;
  final Piece piece;

  const Knight({super.key, required this.piece});

  @override
  Widget build(BuildContext context) {
    return GeneralPiece(piece: piece);
  }
}

// 3
class Rook extends StatelessWidget {
  // final int id = 3;
  final Piece piece;

  const Rook({super.key, required this.piece});

  @override
  Widget build(BuildContext context) {
    return GeneralPiece(piece: piece);
  }
}

// 2
class Bishop extends StatelessWidget {
  // final int id = 2;
  final Piece piece;

  const Bishop({super.key, required this.piece});

  @override
  Widget build(BuildContext context) {
    return GeneralPiece(piece: piece);
  }
}

// 1
class Pawn extends StatelessWidget {
  // final int id = 1;
  final Piece piece;

  const Pawn({super.key, required this.piece});

  @override
  Widget build(BuildContext context) {
    return GeneralPiece(piece: piece);
  }
}

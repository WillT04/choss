import 'package:flutter/material.dart';
import 'package:choss/data.dart';

class GeneralPiece extends StatelessWidget {
  final Piece piece;

  const GeneralPiece({
    super.key,
    required this.piece,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double size = constraints.maxHeight;
      return Padding(
        padding: EdgeInsets.all((size * 0.15)),
        child: Center(
            child: Image.asset(
          piece.imageAsset,
          fit: BoxFit.fill,
        )),
      );
    });
  }
}

import 'dart:collection';
import 'dart:math';

class Board {
  static final Board _board = Board._internal();

  factory Board() {
    return _board;
  }

  Board._internal();

  int turnCount = 0;
  bool inCheck = false;
  bool isMate = false;
  List<int> checkPiece = [];
  List<int> blackTaken = [];
  List<int> whiteTaken = [];
  List<int> blackKingPosition = [0, 4];
  List<int> whiteKingPosition = [7, 4];
  HashMap<List<int>, List<List<int>>> getOutOfCheck = HashMap();
  List<List<Piece?>> board = [[], [], [], [], [], [], [], []];

  int powerupI = -1;
  int powerupJ = -1;

  bool special = false;
  List<int> specialPiece = [];

  String powerUp = "";

  bool isWhite = true;
  // 3: rook, 4: knight, 2: bishop, 5: queen, 6: king, 1:pawn

  void startGame() {
    turnCount = 0;
    inCheck = false;
    checkPiece = [];
    blackTaken = [];
    whiteTaken = [];
    blackKingPosition = [0, 4];
    whiteKingPosition = [7, 4];
    getOutOfCheck = HashMap();
    board = [[], [], [], [], [], [], [], []];
    isWhite = true;
    isMate = false;

    powerupI = Random().nextInt(4) + 2;
    powerupJ = Random().nextInt(8);

    special = false;
    specialPiece = [];

    makeBoard();
  }

  void newPowerup() {
    powerupI = Random().nextInt(4) + 2;
    powerupJ = Random().nextInt(8);

    if (board[powerupI][powerupJ] != null) {
      powerupI = -1;
      powerupJ = -1;
    }
  }

  void makeBoard() {
    board[0].add(Rook([0, 0], 1, "r-b.png"));
    board[0].add(Knight([0, 1], 1, "h-b.png"));
    board[0].add(Bishop([0, 2], 1, "b-b.png"));
    board[0].add(Queen([0, 3], 1, "q-b.png"));
    board[0].add(King([0, 4], 1, "K-b.png"));
    board[0].add(Bishop([0, 5], 1, "b-b.png"));
    board[0].add(Knight([0, 6], 1, "h-b.png"));
    board[0].add(Rook([0, 7], 1, "r-b.png"));

    board[7].add(Rook([7, 0], 0, "r-w.png"));
    board[7].add(Knight([7, 1], 0, "h-w.png"));
    board[7].add(Bishop([7, 2], 0, "b-w.png"));
    board[7].add(Queen([7, 3], 0, "q-w.png"));
    board[7].add(King([7, 4], 0, "k-w.png"));
    board[7].add(Bishop([7, 5], 0, "b-w.png"));
    board[7].add(Knight([7, 6], 0, "h-w.png"));
    board[7].add(Rook([7, 7], 0, "r-w.png"));

    for (int i = 1; i < 7; i++) {
      for (int j = 0; j < 8; j++) {
        if (i == 1) {
          board[i].add(Pawn([i, j], 1, "p-b.png"));
        } else if (i == 6) {
          board[i].add(Pawn([i, j], 0, "p-1.png"));
        } else {
          board[i].add(null);
        }
      }
    }
  }
}

abstract class Piece {
  int colour;
  int pieceNum;
  List<List<int>> offsets;
  List<int> coordinates;

  bool isWhite;
  int id;

  String imageAsset;

  Piece(this.colour, this.pieceNum, this.offsets, this.coordinates,
      String imageAsset)
      : isWhite = colour == 0 ? true : false,
        id = pieceNum,
        imageAsset = "assets/images/$imageAsset";

  void move(int i, int j) {
    List<List<Piece?>> board = Board().board;

    if (board[coordinates[0]][coordinates[1]] is Pawn) {
      if ((coordinates[0] == 1 && i == 3) || (coordinates[0] == 6 && i == 4)) {
        (board[coordinates[0]][coordinates[1]] as Pawn).enpassant =
            Board().turnCount;
      }
    } else if (board[coordinates[0]][coordinates[1]] is King) {
      if (isWhite) {
        Board().whiteKingPosition = [i, j];
      } else {
        Board().blackKingPosition = [i, j];
      }
    }

    if (board[coordinates[0]][coordinates[1]] is King &&
        (board[coordinates[0]][coordinates[1]]! as King).hasMoved == false) {
      (board[coordinates[0]][coordinates[1]]! as King).hasMoved = true;
    } else if (board[coordinates[0]][coordinates[1]] is Rook &&
        (board[coordinates[0]][coordinates[1]]! as Rook).hasMoved == false) {
      (board[coordinates[0]][coordinates[1]]! as Rook).hasMoved == true;
    }

    // Between castling validMoveChecker and here, Will must make clicking king -> castle turn isCastling true
    if (board[coordinates[0]][coordinates[1]] != null) {
      if (board[coordinates[0]][coordinates[1]] is King) {
        print(coordinates[1]);
        print(j);
        if (coordinates[1] + 2 == j) {
          board[i][j - 1] = board[i][j + 1];
          board[i][j + 1] = null;
        } else if (coordinates[1] - 2 == j) {
          board[i][j + 1] = board[i][j - 2];
          board[i][j - 2] = null;
        }
      }
    }

    // FUNCTION FOR TAKING DURING EN PASSE

    if (board[i][j] != null) {
      take(i, j);
    }

    board[i][j] = board[coordinates[0]][coordinates[1]];
    board[coordinates[0]][coordinates[1]] = null;
    coordinates = [i, j];

    Board().isWhite = !Board().isWhite;

    bool inCheck = checkCheck();
    if (inCheck) {
      Board().inCheck = true;
      Board().checkPiece = coordinates;

      HashMap<List<int>, List<List<int>>> getOutOfCheck = checkCheckMate();

      if (getOutOfCheck.isEmpty) {
        Board().isWhite = !Board().isWhite;
        Board().isMate = true;
      } else {
        Board().getOutOfCheck = getOutOfCheck;
      }
    } else {
      Board().inCheck = false;
      Board().checkPiece = [];
      Board().getOutOfCheck = HashMap();
    }

    if (board[i][j] is Pawn) {
      if (board[i][j]!.colour == 0 && i == 0) {
        board[i][j] = Queen([i, j], 0, "q-w.png");
      } else if (board[i][j]!.colour == 1 && i == 7) {
        board[i][j] = Queen([i, j], 1, "q-b.png");
      }
    }

    if (Board().special) {
      Board().special = false;
      Board().specialPiece = [];
    }

    if (i == Board().powerupI &&
        j == Board().powerupJ &&
        board[i][j] is! King) {
      int powerupRand = Random().nextInt(100);

      Board().powerupI = -1;
      Board().powerupJ = -1;

      if (Random().nextInt(3) == 0) {
        Board().newPowerup();
      }

      // Board().powerUp = "Your piece has changed!";
      // Board().special = true;
      if (powerupRand < 20) {
        //go twice
        // Board().special = true;
        // Board().specialPiece = [i, j];

        Board().powerUp = "You can move the piece twice!";

        Board().turnCount--;
        Board().isWhite = !Board().isWhite;
      } else if (powerupRand < 21) {
        board[coordinates[0]][coordinates[1]] = null;
      } else if (powerupRand < 23) {
        board[coordinates[0]][coordinates[1]] = Queen(
          coordinates,
          colour,
          isWhite ? "q-w.png" : "q-b.png",
        );
      } else if (powerupRand < 30) {
        board[i][j] = Knight(
          coordinates,
          colour,
          isWhite ? "h-w.png" : "h-b.png",
        );
      } else if (powerupRand < 35) {
        board[i][j] = Rook(
          coordinates,
          colour,
          isWhite ? "r-w.png" : "r-b.png",
        );
      } else if (powerupRand < 45) {
        board[i][j] = Pawn(
          coordinates,
          colour,
          isWhite ? "p-1.png" : "p-b.png",
        );
      } else {
        board[i][j] = Bishop(
          coordinates,
          colour,
          isWhite ? "b-w.png" : "b-b.png",
        );
      }
    } else if (Board().powerupI == -1) {
      if (Random().nextInt(3) == 0) {
        Board().newPowerup();
      }
    }
  }

  void take(int i, int j) {
    //x y are place its moving to, not from
    if (colour == 0) {
      Board().blackTaken.add(pieceNum);
    } else {
      Board().whiteTaken.add(pieceNum);
    }
    Board().board[i][j] = null;
  }

  List<List<int>> validMoves() {
    List<List<Piece?>> board = Board().board;

    List<List<int>> validMovesList = [];
    for (List<int> offset in offsets) {
      int newX = coordinates[1] + offset[1];
      int newY = coordinates[0] + offset[0];
      bool running = true;
      while (running) {
        if (newX >= 0 && newX <= 7 && newY >= 0 && newY <= 7) {
          if (board[newY][newX] == null) {
            validMovesList.add([newY, newX]);
          } else {
            running = false;
            if (board[newY][newX]!.isWhite == !isWhite) {
              validMovesList.add([newY, newX]);
            }
          }
        } else {
          running = false;
        }
        newX += offset[1];
        newY += offset[0];
      }
    }
    return validMovesList;
  }

  bool checkCheck() {
    List<List<Piece?>> board = Board().board;

    Piece piece = board[coordinates[0]][coordinates[1]]!;
    List<List<int>> validMovesLists = [];

    if (piece is Pawn) {
      validMovesLists = piece.attackingMoves();
    } else {
      validMovesLists = piece.validMoves();
    }

    for (List<int> validMove in validMovesLists) {
      if (colour == 0) {
        if ((validMove[0] == Board().blackKingPosition[0]) &&
            (validMove[1] == Board().blackKingPosition[1])) {
          return true;
        }
      } else {
        if ((validMove[0] == Board().whiteKingPosition[0]) &&
            (validMove[1] == Board().whiteKingPosition[1])) {
          return true;
        }
      }
    }
    return false;
  }

  HashMap<List<int>, List<List<int>>> getout() {
    List<List<Piece?>> board = Board().board;
    HashMap<List<int>, List<List<int>>> validMovesHashMap = HashMap();
    //get all values for us
    List<List<int>> teamValidMoves = [];
    List<List<int>> teamValidMovesFinal = [];

    List<int> checkPiece = Board().checkPiece;
    List<int> kingPiece =
        Board().isWhite ? Board().whiteKingPosition : Board().blackKingPosition;

    List<int> offset;
    if (checkPiece[0] > kingPiece[0]) {
      if (checkPiece[1] > kingPiece[1]) {
        offset = [-1, -1];
      } else if (checkPiece[1] < kingPiece[1]) {
        offset = [-1, 1];
      } else {
        offset = [-1, 0];
      }
    } else if (checkPiece[0] < kingPiece[0]) {
      if (checkPiece[1] > kingPiece[1]) {
        offset = [1, -1];
      } else if (checkPiece[1] < kingPiece[1]) {
        offset = [1, 1];
      } else {
        offset = [1, 0];
      }
    } else if (checkPiece[1] > kingPiece[1]) {
      offset = [0, -1];
    } else {
      offset = [0, 1];
    }

    List<List<int>> interceptPos = [];

    bool notDone = true;
    int checkI = checkPiece[0];
    int checkJ = checkPiece[1];

    while (notDone) {
      checkI += offset[0];
      checkJ += offset[1];

      if (checkI == kingPiece[0] && checkJ == kingPiece[1]) {
        notDone = false;
        break;
      }

      interceptPos.add([checkI, checkJ]);
    }

    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[i][j] != null &&
            board[i][j]?.isWhite == Board().isWhite &&
            board[i][j] is! King) {
          Piece piece = board[i][j]!;
          List<List<int>> temp = [];

          if (piece is Pawn) {
            temp = piece.validMoves();
          } else {
            temp = piece.validMoves();
          }

          for (int j = 0; j < temp.length; j++) {
            teamValidMoves.add(temp[j]);
            // Check if we can kill piece causing check
            // Check if we can intercept piece causing check (exc. pawn and knight)
          }

          for (List<int> teamMove in teamValidMoves) {
            if (teamMove[0] == Board().checkPiece[0] &&
                teamMove[1] == Board().checkPiece[1]) {
              teamValidMovesFinal.add(teamMove);
            }
          }

          if (board[Board().checkPiece[0]][Board().checkPiece[1]] is! Knight &&
              board[Board().checkPiece[0]][Board().checkPiece[1]] is! Pawn) {
            for (List<int> teamMove in teamValidMoves) {
              for (List<int> pos in interceptPos) {
                if (pos[0] == teamMove[0] && pos[1] == teamMove[1]) {
                  teamValidMovesFinal.add(teamMove);
                }
              }
            }
          }

          if (teamValidMovesFinal.isNotEmpty) {
            validMovesHashMap[piece.coordinates] = teamValidMovesFinal;
          }
        }
      }
    }
    return validMovesHashMap;
  }

  HashMap<List<int>, List<List<int>>> checkCheckMate() {
    List<List<Piece?>> board = Board().board;
    HashMap<List<int>, List<List<int>>> escapeMoves = HashMap();
    //Checking if white king is in check
    //can I move out of mate
    List<int> kingPos =
        Board().isWhite ? Board().whiteKingPosition : Board().blackKingPosition;
    List<List<int>> temp = board[kingPos[0]][kingPos[1]]!.validMoves();

    if (temp.isNotEmpty) {
      escapeMoves[kingPos] = temp;
    }

    HashMap<List<int>, List<List<int>>> getOutHash = getout();
    escapeMoves.addAll(getOutHash);

    return escapeMoves;
  }
}

class Rook extends Piece {
  bool hasMoved = false;

  Rook(List<int> coordinates, int colour, String imageAsset)
      : super(
          colour,
          3,
          [
            [1, 0],
            [-1, 0],
            [0, 1],
            [0, -1]
          ],
          coordinates,
          imageAsset,
        );
}

class Bishop extends Piece {
  Bishop(List<int> coordinates, int colour, String imageAsset)
      : super(
          colour,
          2,
          [
            [1, 1],
            [1, -1],
            [-1, 1],
            [-1, -1]
          ],
          coordinates,
          imageAsset,
        );
}

class Queen extends Piece {
  Queen(List<int> coordinates, int colour, String imageAsset)
      : super(
          colour,
          5,
          [
            [1, 0],
            [1, 1],
            [0, 1],
            [-1, 1],
            [-1, 0],
            [-1, -1],
            [0, -1],
            [1, -1]
          ],
          coordinates,
          imageAsset,
        );
}

class Knight extends Piece {
  Knight(List<int> coordinates, int colour, String imageAsset)
      : super(
          colour,
          4,
          [/*Empty array for knight*/],
          coordinates,
          imageAsset,
        );

  @override
  List<List<int>> validMoves() {
    List<List<int>> validMoveList = [];
    List<List<Piece?>> board = Board().board;
    int i = coordinates[0];
    int j = coordinates[1];

    if ((i - 1 >= 0) && (j - 2 >= 0)) {
      if (board[i - 1][j - 2] == null) {
        validMoveList.add([i - 1, j - 2]);
      } else if (board[i - 1][j - 2]!.colour != colour) {
        validMoveList.add([i - 1, j - 2]);
      }
    }

    if ((i - 2 >= 0) && (j - 1 >= 0)) {
      if (board[i - 2][j - 1] == null) {
        validMoveList.add([i - 2, j - 1]);
      } else if (board[i - 2][j - 1]!.colour != colour) {
        validMoveList.add([i - 2, j - 1]);
      }
    }

    if ((i - 2 >= 0) && (j + 1 < 8)) {
      if (board[i - 2][j + 1] == null) {
        validMoveList.add([i - 2, j + 1]);
      } else if (board[i - 2][j + 1]!.colour != colour) {
        validMoveList.add([i - 2, j + 1]);
      }
    }

    if ((i - 1 >= 0) && (j + 2 < 8)) {
      if (board[i - 1][j + 2] == null) {
        validMoveList.add([i - 1, j + 2]);
      } else if (board[i - 1][j + 2]!.colour != colour) {
        validMoveList.add([i - 1, j + 2]);
      }
    }

    if ((i + 1 < 8) && (j + 2 < 8)) {
      if (board[i + 1][j + 2] == null) {
        validMoveList.add([i + 1, j + 2]);
      } else if (board[i + 1][j + 2]!.colour != colour) {
        validMoveList.add([i + 1, j + 2]);
      }
    }

    if ((i + 2 < 8) && (j + 2 < 8)) {
      if (board[i + 2][j + 1] == null) {
        validMoveList.add([i + 2, j + 1]);
      } else if (board[i + 2][j + 1]!.colour != colour) {
        validMoveList.add([i + 2, j + 1]);
      }
    }

    if ((i + 2 < 8) && (j - 1 >= 0)) {
      if (board[i + 2][j - 1] == null) {
        validMoveList.add([i + 2, j - 1]);
      } else if (board[i + 2][j - 1]!.colour != colour) {
        validMoveList.add([i + 2, j - 1]);
      }
    }

    if ((i + 1 < 8) && (j - 2 >= 0)) {
      if (board[i + 1][j - 2] == null) {
        validMoveList.add([i + 1, j - 2]);
      } else if (board[i + 1][j - 2]!.colour != colour) {
        validMoveList.add([i + 1, j - 2]);
      }
    }

    return validMoveList;
  }
}

class Pawn extends Piece {
  int enpassant = -2;
  Pawn(List<int> coordinates, int colour, String imageAsset)
      : super(
          colour,
          1,
          [/*Empty array for pawn*/],
          coordinates,
          imageAsset,
        );

  List<List<int>> attackingMoves() {
    List<List<int>> validMoveList = [];
    List<List<Piece?>> board = Board().board;
    int left = (coordinates[1] - 1);
    int right = (coordinates[1] + 1);

    if (colour == 0) {
      int forward = (coordinates[0] - 1);
      if ((forward >= 0) && (left >= 0)) {
        if (board[forward][left] == null || board[forward][left]!.colour == 1) {
          validMoveList.add([forward, left]);
        }
      }
      if ((forward >= 0) && (right < 8)) {
        if (board[forward][right] == null ||
            board[forward][right]!.colour == 1) {
          validMoveList.add([forward, right]);
        }
      }
    } else {
      int down = (coordinates[0] + 1);
      if ((down < 8) && (left >= 0)) {
        if (board[down][left] == null || board[down][left]!.colour == 0) {
          validMoveList.add([down, left]);
        }
      }
      if ((down < 8) && (right < 8)) {
        if (board[down][right] == null || board[down][right]!.colour == 0) {
          validMoveList.add([down, right]);
        }
      }
    }

    return validMoveList;
  }

  @override
  List<List<int>> validMoves() {
    List<List<int>> validMoveList = [];
    List<List<Piece?>> board = Board().board;
    int left = (coordinates[1] - 1);
    int right = (coordinates[1] + 1);

    int turnCount = Board().turnCount;

    if (colour == 0) {
      int forward = (coordinates[0] - 1);
      if (forward >= 0) {
        if (board[forward][coordinates[1]] == null) {
          validMoveList.add([forward, coordinates[1]]);
        }
      }
      if ((forward >= 0) && (left >= 0)) {
        if ((board[forward][left] != null) &&
            (board[forward][left]!.colour == 1)) {
          validMoveList.add([forward, left]);
        } else if ((board[forward][left] == null) &&
            ((board[coordinates[0]][left] is Pawn) &&
                ((board[coordinates[0]][left] as Pawn).enpassant + 1 ==
                    Board().turnCount))) {
          validMoveList.add([forward, left]); // TODO: Take piece
        }
      }
      if ((forward >= 0) && (right < 8)) {
        if ((board[forward][right] != null) &&
            (board[forward][right]!.colour == 1)) {
          validMoveList.add([forward, right]);
        } else if ((board[forward][right] == null) &&
            ((board[coordinates[0]][right] is Pawn) &&
                ((board[coordinates[0]][right] as Pawn).enpassant + 1 ==
                    Board().turnCount))) {
          validMoveList.add([forward, right]);
        }
      }
      if ((coordinates[0] == 6) &&
          (board[forward][coordinates[1]] == null) &&
          (board[forward - 1][coordinates[1]] == null)) {
        validMoveList.add([forward - 1, coordinates[1]]);
      }
    } else {
      int down = (coordinates[0] + 1);
      if (down < 8) {
        if (board[down][coordinates[1]] == null) {
          validMoveList.add([down, coordinates[1]]);
        }
      }
      if ((down < 8) && (left >= 0)) {
        if ((board[down][left] != null) && (board[down][left]!.colour == 0)) {
          validMoveList.add([down, left]);
        } else if ((board[down][left] == null) &&
            ((board[coordinates[0]][left] is Pawn) &&
                (((board[coordinates[0]][left] as Pawn).enpassant + 1) ==
                    turnCount))) {
          validMoveList.add([down, left]);
        }
      }
      if ((down < 8) && (right < 8)) {
        if ((board[down][right] != null) && (board[down][right]!.colour == 0)) {
          validMoveList.add([down, right]);
        } else if ((board[down][right] == null) &&
            ((board[coordinates[0]][right] is Pawn) &&
                (board[coordinates[0]][right] as Pawn).enpassant + 1 ==
                    turnCount)) {
          validMoveList.add([down, right]);
        }
      }
      if ((coordinates[0] == 1) &&
          (board[down][coordinates[1]] == null) &&
          (board[down + 1][coordinates[1]] == null)) {
        validMoveList.add([down + 1, coordinates[1]]);
      }
    }
    return validMoveList;
  }
}

class King extends Piece {
  bool hasMoved = false;
  bool isCastling = false;

  King(List<int> coordinates, int colour, String imageAsset)
      : super(
          colour,
          6,
          [
            [1, 0],
            [1, 1],
            [0, 1],
            [-1, 1],
            [-1, 0],
            [-1, -1],
            [0, -1],
            [1, -1]
          ],
          coordinates,
          imageAsset,
        );
  @override
  List<List<int>> validMoves() {
    List<List<Piece?>> board = Board().board;

    List<List<int>> validMovesListKing = [];
    List<List<int>> validMovesListFoes = [];

    for (List<int> offset in offsets) {
      int newX = coordinates[1] + offset[1];
      int newY = coordinates[0] + offset[0];
      if (newX >= 0 && newX <= 7 && newY >= 0 && newY <= 7) {
        if (board[newY][newX] == null) {
          validMovesListKing.add([newY, newX]);
        } else {
          if (board[newY][newX]!.isWhite == !isWhite) {
            validMovesListKing.add([newY, newX]);
          }
        }
      }
      newX += offset[1];
      newY += offset[0];
    }

    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[i][j] != null &&
            board[i][j]?.colour != colour &&
            board[i][j] is! King) {
          List<List<int>> temp = board[i][j]!.validMoves();
          for (int j = 0; j < temp.length; j++) {
            validMovesListFoes.add(temp[j]);
          }
        }
      }
    }

    for (int i = 0; i < validMovesListFoes.length; i++) {
      if (validMovesListFoes[i][0] == coordinates[0] &&
          validMovesListFoes[i][1] == coordinates[1]) {
        break;
      }
      if (hasMoved == false) {
        if (colour == 1) {
          if (board[0][1] == null &&
              board[0][2] == null &&
              board[0][3] == null &&
              (board[0][0] as Rook).hasMoved == false) {
            validMovesListKing.add([0, 2]);
          } else if (board[0][5] == null &&
              board[0][6] == null &&
              (board[0][7] as Rook).hasMoved == false) {
            validMovesListKing.add([0, 6]);
          }
        } else {
          if (board[7][1] == null &&
              board[7][2] == null &&
              board[7][3] == null &&
              (board[7][0] as Rook).hasMoved == false) {
            validMovesListKing.add([7, 2]);
          } else if (board[7][5] == null &&
              board[7][6] == null &&
              (board[7][7] as Rook).hasMoved == false) {
            validMovesListKing.add([7, 6]);
          }
        }
      }
    }

    for (int i = 0; i < validMovesListFoes.length; i++) {
      for (int j = 0; j < validMovesListKing.length; j++) {
        if (validMovesListFoes[i][0] == validMovesListKing[j][0] &&
            validMovesListFoes[i][1] == validMovesListKing[j][1]) {
          validMovesListKing.removeAt(j);
        }
      }
    }

    List<List<int>> temp = [];

    for (int n = 0; n < validMovesListKing.length; n++) {
      List<int> kingCoords = Board().isWhite
          ? Board().whiteKingPosition
          : Board().blackKingPosition;
      Piece? tempKing = board[kingCoords[0]][kingCoords[1]];
      board[kingCoords[0]][kingCoords[1]] = null;

      Piece? temppiece =
          board[validMovesListKing[n][0]][validMovesListKing[n][1]];
      board[validMovesListKing[n][0]][validMovesListKing[n][1]] = King(
          [validMovesListKing[n][1], validMovesListKing[n][0]],
          colour,
          colour == 0 ? "k-w.png" : "K-b.png");
      for (int i = 0; i < 8; i++) {
        for (int j = 0; j < 8; j++) {
          if (board[i][j] != null &&
              board[i][j]?.colour != colour &&
              board[i][j] is! King) {
            List<List<int>> validMoveList = board[i][j]!.validMoves();
            for (List<int> validMove in validMoveList) {
              if ((validMove[0] == validMovesListKing[n][0]) &&
                  (validMove[1] == validMovesListKing[n][1])) {
                temp.add(validMovesListKing[n]);
              }
            }
          }
        }
      }
      board[validMovesListKing[n][0]][validMovesListKing[n][1]] = temppiece;
      board[kingCoords[0]][kingCoords[1]] = tempKing;

      for (int i = 0; i < temp.length; i++) {
        validMovesListKing.remove(temp[i]);
      }
    }
    return validMovesListKing;
  }
}

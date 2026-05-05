import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameState {
  final List<String> board; // 9 squares
  final String nextPlayer; // 'X' or 'O'
  final String? winner;
  final bool isDraw;

  GameState({
    required this.board,
    required this.nextPlayer,
    this.winner,
    this.isDraw = false,
  });

  Map<String, dynamic> toJson() => {
    'board': board,
    'nextPlayer': nextPlayer,
    'winner': winner,
    'isDraw': isDraw,
  };

  factory GameState.fromJson(Map<String, dynamic> j) => GameState(
    board: List<String>.from(j['board']),
    nextPlayer: j['nextPlayer'],
    winner: j['winner'],
    isDraw: j['isDraw'] ?? false,
  );
}

class GameService {
  /// Initialize a new Tic-Tac-Toe game.
  GameState createGame() {
    return GameState(
      board: List.filled(9, ''),
      nextPlayer: 'X',
    );
  }

  /// Process a move and return the new state.
  GameState makeMove(GameState current, int index, String player) {
    if (current.board[index] != '' || current.winner != null) return current;
    if (current.nextPlayer != player) return current;

    final newBoard = List<String>.from(current.board);
    newBoard[index] = player;

    final winner = _checkWinner(newBoard);
    final isDraw = !newBoard.contains('') && winner == null;

    return GameState(
      board: newBoard,
      nextPlayer: player == 'X' ? 'O' : 'X',
      winner: winner,
      isDraw: isDraw,
    );
  }

  String? _checkWinner(List<String> b) {
    const lines = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Cols
      [0, 4, 8], [2, 4, 6]             // Diagonals
    ];
    for (var l in lines) {
      if (b[l[0]] != '' && b[l[0]] == b[l[1]] && b[l[0]] == b[l[2]]) return b[l[0]];
    }
    return null;
  }

  String serialize(GameState state) => jsonEncode(state.toJson());
  GameState deserialize(String json) => GameState.fromJson(jsonDecode(json));
}

final gameServiceProvider = Provider<GameService>((ref) => GameService());

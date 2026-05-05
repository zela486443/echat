import 'dart:convert';

enum GamePlayer { x, o }
enum GameResult { xWins, oWins, draw, ongoing }

class TicTacToeState {
  final List<String?> board; // 9 cells: null, 'X', or 'O'
  final GamePlayer currentTurn;
  final String startedBy;
  final String playerX;
  final String playerO;
  final GameResult result;

  TicTacToeState({required this.board, required this.currentTurn, required this.startedBy, required this.playerX, required this.playerO, required this.result});

  factory TicTacToeState.initial(String startedBy, String playerX, String playerO) => TicTacToeState(
    board: List.filled(9, null), currentTurn: GamePlayer.x, startedBy: startedBy, playerX: playerX, playerO: playerO, result: GameResult.ongoing,
  );
}

class GameService {
  static final GameService _instance = GameService._internal();
  factory GameService() => _instance;
  GameService._internal();

  static const _winPatterns = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // cols
    [0, 4, 8], [2, 4, 6],            // diags
  ];

  TicTacToeState createGame(String startedBy, String playerX, String playerO) {
    return TicTacToeState.initial(startedBy, playerX, playerO);
  }

  TicTacToeState makeMove(TicTacToeState state, int index) {
    if (state.result != GameResult.ongoing || state.board[index] != null) return state;
    final newBoard = List<String?>.from(state.board);
    newBoard[index] = state.currentTurn == GamePlayer.x ? 'X' : 'O';
    final result = _checkResult(newBoard);
    return TicTacToeState(
      board: newBoard, currentTurn: state.currentTurn == GamePlayer.x ? GamePlayer.o : GamePlayer.x,
      startedBy: state.startedBy, playerX: state.playerX, playerO: state.playerO, result: result,
    );
  }

  GameResult _checkResult(List<String?> board) {
    for (final p in _winPatterns) {
      if (board[p[0]] != null && board[p[0]] == board[p[1]] && board[p[1]] == board[p[2]]) {
        return board[p[0]] == 'X' ? GameResult.xWins : GameResult.oWins;
      }
    }
    if (board.every((c) => c != null)) return GameResult.draw;
    return GameResult.ongoing;
  }

  String serializeGame(TicTacToeState state) {
    return jsonEncode({
      'board': state.board, 'turn': state.currentTurn.index,
      'startedBy': state.startedBy, 'playerX': state.playerX, 'playerO': state.playerO, 'result': state.result.index,
    });
  }

  TicTacToeState? deserializeGame(String str) {
    try {
      final j = jsonDecode(str);
      return TicTacToeState(
        board: List<String?>.from(j['board']),
        currentTurn: GamePlayer.values[j['turn']],
        startedBy: j['startedBy'], playerX: j['playerX'], playerO: j['playerO'],
        result: GameResult.values[j['result']],
      );
    } catch (_) { return null; }
  }
}

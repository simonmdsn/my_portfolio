import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_portfolio/page/base_page.dart';

class P2048Page extends ConsumerStatefulWidget {
  const P2048Page({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _P2048PageState();
}

class _P2048PageState extends ConsumerState<P2048Page> {
  final List<List<Tile?>> board = List.generate(4, (index) => List.generate(4, (index) => null));
  bool checkingAvailableMoves = false;
  int highest = 0;
  int score = 0;
  GameState gameState = GameState.going;

  final colors = <int, Color>{
    2: const Color(0xFFD3C270),
    math.pow(2, 2).toInt(): const Color(0xFFA66A5F),
    math.pow(2, 3).toInt(): const Color(0xFFD39370),
    math.pow(2, 4).toInt(): const Color(0xFF8B9A5F),
    math.pow(2, 5).toInt(): const Color(0xFF6C9A5F),
    math.pow(2, 6).toInt(): const Color(0xFF9A5F5F),
    math.pow(2, 7).toInt(): const Color(0xff831b1b),
    math.pow(2, 8).toInt(): const Color(0xffb25010),
    math.pow(2, 9).toInt(): const Color(0xefd70303),
    math.pow(2, 10).toInt(): const Color(0xff540e0f),
    math.pow(2, 11).toInt(): const Color(0xffff6e00),
    math.pow(2, 12).toInt(): const Color(0xfff65f66),
    math.pow(2, 13).toInt(): const Color(0xff650c62),
    math.pow(2, 14).toInt(): const Color(0xff2e1b33),
    math.pow(2, 15).toInt(): const Color(0xffb2148d),
    math.pow(2, 16).toInt(): const Color(0xffb600ff),
    math.pow(2, 17).toInt(): const Color(0xff000000),
  };

  final keyboardFocusNode = FocusNode();

  @override
  void initState() {
    _spawnRandomTile();
    setState(() {});
    keyboardFocusNode.requestFocus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => keyboardFocusNode.requestFocus(),
      child: BasePage(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints.expand(width: 800, height: 800),
            child: RawKeyboardListener(
              focusNode: keyboardFocusNode,
              autofocus: true,
              onKey: (key) {
                if (key.runtimeType == RawKeyUpEvent) {
                  return;
                }
                if (gameState != GameState.going) {
                  return;
                }
                if (key.physicalKey == PhysicalKeyboardKey.arrowLeft) {
                  _move(0, 0, -1);
                  return;
                }
                if (key.physicalKey == PhysicalKeyboardKey.arrowRight) {
                  _move(board.length * board[0].length - 1, 0, 1);
                  return;
                }
                if (key.physicalKey == PhysicalKeyboardKey.arrowUp) {
                  _move(0, -1, 0);
                  return;
                }
                if (key.physicalKey == PhysicalKeyboardKey.arrowDown) {
                  _move(board.length * board[0].length - 1, 1, 0);
                  return;
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: SizedBox(
                      width: 250,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [Text('Score: $score'),SizedBox(width: 60,), Text('Highest: $highest')],
                      ),
                    ),
                  ),
                  for (int i = 0; i < 4; i++)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: board[i]
                          .map(
                            (e) => Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Container(
                                width: 60,
                                height: 60,
                                color: e == null ? Colors.grey : colors[e.value],
                                //color: e.closeness.color,
                                child: e != null
                                    ? FittedBox(
                                        fit: BoxFit.contain,
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Text(
                                            e.value.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  if (gameState == GameState.lose) Text('You are out of moves!'),
                  TextButton(
                    onPressed: () => _reset(),
                    child: Text('Reset'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _spawnRandomTile() {
    final List<List<int>> indexOfNulls = [];
    for (int i = 0; i < board.length; i++) {
      for (int j = 0; j < board[i].length; j++) {
        if (board[i][j] == null) {
          indexOfNulls.add([i, j]);
        }
      }
    }
    var nextInt = math.Random().nextInt(indexOfNulls.length);
    board[indexOfNulls[nextInt][0]][indexOfNulls[nextInt][1]] = Tile();
  }

  bool _move(int countDownFrom, int yIncr, int xIncr) {
    var moved = false;

    for (int i = 0; i < board.length * board[0].length; i++) {
      int j = (countDownFrom - i).abs();
      int r = j ~/ board.length;
      int c = j % board[0].length;

      if (board[r][c] == null) continue;

      int nextR = r + yIncr;
      int nextC = c + xIncr;

      while (nextR >= 0 && nextR < board.length && nextC >= 0 && nextC < board[0].length) {
        var next = board[nextR][nextC];
        var curr = board[r][c];

        if (next == null) {
          if (checkingAvailableMoves) {
            return true;
          }

          board[nextR][nextC] = curr;
          board[r][c] = null;
          r = nextR;
          c = nextC;
          nextR += yIncr;
          nextC += xIncr;
          moved = true;
        } else if (next.canMergeWith(curr)) {
          if (checkingAvailableMoves) {
            return true;
          }

          int value = next.mergeWith(curr!);
          if (value > highest) highest = value;
          score += value;
          board[r][c] = null;
          moved = true;
          break;
        } else {
          break;
        }
      }
    }

    if (moved) {
      if (highest < colors.keys.last) {
        _clearMerged();
        _spawnRandomTile();
        if (!_canMove()) {
          gameState = GameState.lose;
        }
      } else if (highest > colors.keys.last) {
        gameState = GameState.won;
      }
      setState(() {});
    }

    return moved;
  }

  bool _canMove() {
    checkingAvailableMoves = true;
    bool hasMoves = _move(0, 0, -1) ||
        _move(board.length * board[0].length - 1, 0, 1) ||
        _move(0, -1, 0) ||
        _move(board.length * board[0].length - 1, 1, 0);
    checkingAvailableMoves = false;
    return hasMoves;
  }

  _clearMerged() {
    for (var rows in board) {
      for (var cols in rows) {
        cols?.merged = false;
      }
    }
  }

  _reset() {
    for (int i = 0; i < board.length; i++) {
      for (int j = 0; j < board[0].length; j++) {
        board[i][j] = null;
      }
    }
    highest = 0;
    score = 0;
    gameState = GameState.going;
    keyboardFocusNode.requestFocus();
    _spawnRandomTile();
    setState(() {});
  }
}

enum GameState { going, lose, won }

class Tile {
  int value = 2;
  bool merged = false;

  void increase() => value = value * 2;

  bool canMergeWith(Tile? other) =>
      !merged && other != null && !other.merged && value == other.value;

  int mergeWith(Tile other) {
    increase();
    merged = true;
    return value;
  }
}

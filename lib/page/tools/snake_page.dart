import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_portfolio/page/base_page.dart';

class SnakePage extends ConsumerStatefulWidget {
  const SnakePage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _SnakePageState();
}

class _SnakePageState extends ConsumerState<SnakePage> {
  int size = 10;
  int tileSize = 50;
  int updateRate = 200;
  late var snake = Snake(x: 0, y: 0, boardSize: size);
  late List<List<TileState>> board =
      List.generate(size, (_) => List.generate(size, (_) => TileState.empty));
  GameState gameState = GameState.going;
  late final ListQueue<Direction> directionQueue = ListQueue()..add(Direction.right);
  late Position apple;
  Timer? gameTimer;
  final keyboardFocusNode = FocusNode();
  late final sizeInputController = TextEditingController()..text = size.toString();
  late final updateRateController = TextEditingController()..text = updateRate.toString();
  late final tileSizeController = TextEditingController()..text = tileSize.toString();

  _reset() {
    board = List.generate(size, (_) => List.generate(size, (_) => TileState.empty));
    gameState = GameState.going;
    directionQueue
      ..clear()
      ..add(Direction.right);
    _spawnApple();
    snake = Snake(x: 0, y: 0, boardSize: size);
    board[snake.head.x][snake.head.y] = TileState.snake;
    gameTimer?.cancel();
    _startGameTimer();
    keyboardFocusNode.requestFocus();
  }

  @override
  void initState() {
    _spawnApple();
    board[snake.head.x][snake.head.y] = TileState.snake;
    _startGameTimer();
    keyboardFocusNode.requestFocus();
    super.initState();
  }

  _startGameTimer() {
    gameTimer = Timer.periodic(Duration(milliseconds: updateRate), (timer) {
      bool ateApple;
      if (directionQueue.length > 1) {
        ateApple = snake.move(directionQueue.removeFirst(), apple);
      } else {
        ateApple = snake.move(directionQueue.first, apple);
      }
      if (snake.collided()) {
        gameState = GameState.lose;
        timer.cancel();
        setState(() {});
        return;
      }
      board = List.generate(size, (_) => List.generate(size, (_) => TileState.empty));
      board[apple.x][apple.y] = TileState.apple;
      snake.snakeTiles.forEach((element) {
        board[element.x][element.y] = TileState.snake;
      });
      if (ateApple) {
        _spawnApple();
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => keyboardFocusNode.requestFocus(),
      child: BasePage(
        child: Center(
          child: RawKeyboardListener(
            focusNode: keyboardFocusNode,
            autofocus: true,
            onKey: (key) {
              if (key.runtimeType == RawKeyUpEvent) {
                return;
              }
              if (key.physicalKey == PhysicalKeyboardKey.arrowLeft) {
                directionQueue.add(Direction.left);
                return;
              }
              if (key.physicalKey == PhysicalKeyboardKey.arrowRight) {
                directionQueue.add(Direction.right);
                return;
              }
              if (key.physicalKey == PhysicalKeyboardKey.arrowUp) {
                directionQueue.add(Direction.up);
                return;
              }
              if (key.physicalKey == PhysicalKeyboardKey.arrowDown) {
                directionQueue.add(Direction.down);
                return;
              }
            },
            child: ConstrainedBox(
              constraints: const BoxConstraints.expand(width: 1200, height: 1200),
              child: Column(
                children: [
                  if (gameState == GameState.lose) const Text('You lost!'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Score ${snake.snakeTiles.length}'),
                      TextButton(
                        onPressed: () => _reset(),
                        child: Text('Reset'),
                      ),
                      Text(' Size: '),
                      Container(
                        width: 45,
                        child: TextFormField(
                          controller: sizeInputController,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          ],

                          decoration: const InputDecoration(
                            hintText: "Size",
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.all(6.0),
                          ),
                          onFieldSubmitted: (submit) {
                            size = int.parse(submit);
                            _reset();
                          },
                        ),
                      ),
                      Text('Tile size:'),
                      Container(
                        width: 45,
                        child: TextFormField(
                          controller: tileSizeController,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          ],

                          decoration: const InputDecoration(
                            hintText: "Tile",
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.all(6.0),
                          ),
                          onFieldSubmitted: (submit) {
                            tileSize = int.parse(submit);
                            _reset();
                          },
                        ),
                      ),
                      Text(' Update rate: '),
                      Container(
                        width: 45,
                        child: TextFormField(
                          controller: updateRateController,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          ],
                          decoration: const InputDecoration(
                            hintText: "Speed",
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.all(6.0),
                          ),
                          onFieldSubmitted: (submit) {
                            updateRate = int.parse(submit);
                            _reset();
                          },
                        ),
                      ),
                    ],
                  ),
                  for (int i = 0; i < board.length; i++)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: board[i]
                          .map(
                            (e) => Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Container(
                                width: tileSize.toDouble(),
                                height: tileSize.toDouble(),
                                color: e == TileState.empty
                                    ? Colors.grey
                                    : e == TileState.snake
                                        ? Colors.green
                                        : Colors.red,
                              ),
                            ),
                          )
                          .toList(),
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _spawnApple() {
    final List<List<int>> indexOfEmpties = [];
    for (int i = 0; i < board.length; i++) {
      for (int j = 0; j < board[i].length; j++) {
        if (board[i][j] == TileState.empty) {
          indexOfEmpties.add([i, j]);
        }
      }
    }
    var nextInt = math.Random().nextInt(indexOfEmpties.length);
    apple = Position(x: indexOfEmpties[nextInt][0], y: indexOfEmpties[nextInt][1]);
    board[indexOfEmpties[nextInt][0]][indexOfEmpties[nextInt][1]] = TileState.apple;
  }
}

enum Direction { left, right, up, down }
enum GameState { going, lose, won }
enum TileState { empty, snake, apple }

class Position {
  int x;
  int y;

  Position({required this.x, required this.y});
}

class Snake {
  final int boardSize;
  final List<Position> snakeTiles = [];
  Direction previousDirection;

  Snake({
    required int x,
    required int y,
    required this.boardSize,
    this.previousDirection = Direction.right,
  }) {
    snakeTiles.add(Position(x: x, y: y));
  }

  Position get head => snakeTiles[0];

  bool move(Direction direction, Position apple) {
    int previousX = head.x;
    int previousY = head.y;
    if (direction == Direction.left) {
      head.y--;
      if (head.y < 0) head.y = boardSize - 1;
    }
    if (direction == Direction.right) {
      head.y++;
      if (head.y > boardSize - 1) head.y = 0;
    }
    if (direction == Direction.up) {
      head.x--;
      if (head.x < 0) head.x = boardSize - 1;
    }
    if (direction == Direction.down) {
      head.x++;
      if (head.x > boardSize - 1) head.x = 0;
    }
    snakeTiles.skip(1).forEach((element) {
      int tempX = element.x;
      int tempY = element.y;
      element.x = previousX;
      element.y = previousY;
      previousX = tempX;
      previousY = tempY;
    });
    if (apple.x == head.x && head.y == apple.y) {
      snakeTiles.add(Position(x: previousX, y: previousY));
      return true;
    }
    return false;
  }

  bool collided() {
    return snakeTiles.skip(1).any((element) => element.x == head.x && element.y == head.y);
  }
}

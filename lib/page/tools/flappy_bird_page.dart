import 'dart:async';
import 'dart:html';
import 'dart:math' as math;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_portfolio/page/base_page.dart';

class FlappyBirdPage extends ConsumerStatefulWidget {
  const FlappyBirdPage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _FlappyBirdPageState();
}

class _FlappyBirdPageState extends ConsumerState<FlappyBirdPage> {
  final keyboardFocusNode = FocusNode();
  final obstacleWidth = 75.0;
  final obstacleHeight = 100.0;
  final random = Random();
  var gameState = GameState.going;
  var score = 0;

  final height = 800.0;
  final width = 600.0;

  double yPosition = 400.0;
  double rotation = 0;

  bool isFalling = true;

  Timer? liftTimer;
  Timer? fallTimer;
  Timer? obstacleTimer;
  Timer? collisionTimer;
  double liftAcceleration = 16;
  double fallAcceleration = 2;

  late double obstacleX = 400;
  late double obstacleY = 300;
  late double obstacle2X = 600;
  late double obstacle2Y = randomHeight();
  late double obstacle3X = 800;
  late double obstacle3Y = randomHeight();
  late double obstacle4X = 1000;
  late double obstacle4Y = randomHeight();

  double randomHeight() {
    return random.nextInt(550).toDouble();
  }

  @override
  void initState() {
    _startFallTimer();
    _startObstacleTimer();
    _startCollisionTimer();
    super.initState();
  }

  _startFallTimer() {
    isFalling = true;
    fallTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (isFalling) {
        setState(() {
          fallAcceleration = fallAcceleration * 1.007;
          rotation = math.sin(fallAcceleration / pi);
          yPosition += 2 * fallAcceleration;
        });
      }
    });
  }

  _startLiftTimer() {
    isFalling = false;
    liftTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (liftAcceleration < 1) {
        timer.cancel();
        liftAcceleration = 10;
        fallAcceleration = 2;
        isFalling = true;
      }
      setState(() {
        rotation = -1;
        yPosition -= liftAcceleration;
      });
      liftAcceleration = 0.9 * liftAcceleration;
    });
  }

  _startObstacleTimer() {
    obstacleTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() {
        obstacleX -= 1;
        obstacle2X -= 1;
        obstacle3X -= 1;
        obstacle4X -= 1;
        if (obstacleX < -obstacleWidth) {
          var nextInt = randomHeight();
          obstacleX = 750;
          obstacleY = nextInt;
        }
        if (obstacle2X < -obstacleWidth) {
          obstacle2Y = randomHeight();
          obstacle2X = 750;
        }
        if (obstacle3X < -obstacleWidth) {
          obstacle3Y = randomHeight();
          obstacle3X = 750;
        }
        if (obstacle4X < -obstacleWidth) {
          obstacle4Y = randomHeight();
          obstacle4X = 750;
        }
      });
    });
  }

  _startCollisionTimer() {
    collisionTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      score++;
      if (yPosition < 0 || yPosition > height) {
        collide();
        return;
      }

      if (obstacleX + (obstacleWidth / 2) > width / 2 + 15 &&
          obstacleX - (obstacleWidth / 2) < width / 2 + 15) {
        if (yPosition < obstacleY + 30 || yPosition > obstacleY + 190) {
          collide();
        }
        return;
      }

      if (obstacle2X + (obstacleWidth / 2) > width / 2 + 15 &&
          obstacle2X - (obstacleWidth / 2) < width / 2 + 15) {
        if (yPosition < obstacle2Y + 30 || yPosition > obstacle2Y + 190) {
          collide();
        }
        return;
      }

      if (obstacle3X + (obstacleWidth / 2) > width / 2 + 15 &&
          obstacle3X - (obstacleWidth / 2) < width / 2 + 15) {
        if (yPosition < obstacle3Y + 30 || yPosition > obstacle3Y + 190) {
          collide();
        }
        return;
      }

      if (obstacle4X + (obstacleWidth / 2) > width / 2 + 15 &&
          obstacle4X - (obstacleWidth / 2) < width / 2 + 15) {
        if (yPosition < obstacle4Y + 30 || yPosition > obstacle4Y + 190) {
          collide();
        }
        return;
      }
    });
  }

  collide() {
    setState(() {
      gameState = GameState.lost;
    });
    stopAllTimers();
  }

  stopAllTimers() {
    liftTimer?.cancel();
    obstacleTimer?.cancel();
    fallTimer?.cancel();
    obstacleTimer?.cancel();
    collisionTimer?.cancel();
  }

  resetGame() {
    stopAllTimers();
    score = 0;
    gameState = GameState.going;
    yPosition = 400;
    obstacleX = 400;
    obstacleY = 300;
    obstacle2X = 600;
    obstacle2Y = randomHeight();
    obstacle3X = 800;
    obstacle3Y = randomHeight();
    obstacle4X = 1000;
    obstacle4Y = randomHeight();
    liftAcceleration = 16;
    fallAcceleration = 2;
    _startFallTimer();
    _startObstacleTimer();
    _startCollisionTimer();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => keyboardFocusNode.requestFocus(),
      child: BasePage(
        child: RawKeyboardListener(
          focusNode: keyboardFocusNode,
          autofocus: true,
          onKey: (key) {
            if (key.runtimeType == RawKeyUpEvent) {
              return;
            }
            if(key.physicalKey == PhysicalKeyboardKey.keyR) {
              stopAllTimers();
              resetGame();
            }
            if(gameState == GameState.lost) {
              return;
            }
            if (key.physicalKey == PhysicalKeyboardKey.keyP) {
              if (gameState == GameState.paused) {
                setState(() {
                  gameState = GameState.going;
                });
                _startFallTimer();
                _startObstacleTimer();
                _startCollisionTimer();
              } else if (gameState == GameState.going) {
                setState(() {
                  gameState = GameState.paused;
                });
                stopAllTimers();
              }
            }
            if (key.physicalKey == PhysicalKeyboardKey.enter && gameState == GameState.going) {
              _startLiftTimer();
            }
          },
          child: Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('"Enter" to jump, "P" to pause, "R" to reset'),
                    TextButton(onPressed: () => resetGame(), child: Text('Reset')),
                  ],
                ),
                ConstrainedBox(
                  constraints: BoxConstraints.expand(width: width, height: height),
                  child: Stack(
                    children: [
                      Image.asset(
                        'images/flappy-background.png',
                        height: height,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        child: Transform.rotate(
                          angle: rotation,
                          child: Image.asset(
                            'images/flappy.png',
                            height: 50,
                            width: 50,
                            fit: BoxFit.fill,
                          ),
                        ),
                        // Container(
                        //   width: 50,
                        //   height: 50,
                        //   color: Colors.blue,
                        // ),
                        left: width / 2,
                        top: yPosition,
                      ),
                      Positioned(
                        child: Transform.rotate(
                          angle: pi,
                          child: Column(
                            children: [
                              Image.asset(
                                'images/flappy-pipe-head.png',
                                height: 30,
                              ),
                              Image.asset(
                                'images/flappy-pipe.png',
                                width: obstacleWidth,
                                height: obstacleY,
                                repeat: ImageRepeat.repeatY,
                                fit: BoxFit.fill,
                              ),
                            ],
                          ),
                        ),

                        // Container(
                        //   color: Colors.red,
                        //   width: obstacleWidth,
                        //   height: obstacleY,
                        // ),
                        top: 0,
                        left: obstacleX,
                      ),
                      Positioned(
                        child: Column(
                          children: [
                            Image.asset(
                              'images/flappy-pipe-head.png',
                              height: 30,
                            ),
                            Image.asset(
                              'images/flappy-pipe.png',
                              width: obstacleWidth,
                              height: height - 250,
                              repeat: ImageRepeat.repeatY,
                              fit: BoxFit.fill,
                            ),
                          ],
                        ),
                        // Container(
                        //   color: Colors.red,
                        //   width: obstacleWidth,
                        //   height: height - 250,
                        // ),
                        top: obstacleY + 250,
                        left: obstacleX,
                      ),
                      Positioned(
                        child: Transform.rotate(
                          angle: pi,
                          child: Column(
                            children: [
                              Image.asset(
                                'images/flappy-pipe-head.png',
                                height: 30,
                              ),
                              Image.asset(
                                'images/flappy-pipe.png',
                                width: obstacleWidth,
                                height: obstacle2Y,
                                repeat: ImageRepeat.repeatY,
                                fit: BoxFit.fill,
                              ),
                            ],
                          ),
                        ),
                        top: 0,
                        left: obstacle2X,
                      ),
                      Positioned(
                        child: Column(
                          children: [
                            Image.asset(
                              'images/flappy-pipe-head.png',
                              height: 30,
                            ),
                            Image.asset(
                              'images/flappy-pipe.png',
                              width: obstacleWidth,
                              height: height - 250,
                              repeat: ImageRepeat.repeatY,
                              fit: BoxFit.fill,
                            ),
                          ],
                        ),
                        top: obstacle2Y + 250,
                        left: obstacle2X,
                      ),
                      Positioned(
                        child: Transform.rotate(
                          angle: pi,
                          child: Column(
                            children: [
                              Image.asset(
                                'images/flappy-pipe-head.png',
                                height: 30,
                              ),
                              Image.asset(
                                'images/flappy-pipe.png',
                                width: obstacleWidth,
                                height: obstacle3Y,
                                repeat: ImageRepeat.repeatY,
                                fit: BoxFit.fill,
                              ),
                            ],
                          ),
                        ),
                        top: 0,
                        left: obstacle3X,
                      ),
                      Positioned(
                        child: Column(
                          children: [
                            Image.asset(
                              'images/flappy-pipe-head.png',
                              height: 30,
                            ),
                            Image.asset(
                              'images/flappy-pipe.png',
                              width: obstacleWidth,
                              height: height - 250,
                              repeat: ImageRepeat.repeatY,
                              fit: BoxFit.fill,
                            ),
                          ],
                        ),
                        top: obstacle3Y + 250,
                        left: obstacle3X,
                      ),
                      Positioned(
                        child: Transform.rotate(
                          angle: pi,
                          child: Column(
                            children: [
                              Image.asset(
                                'images/flappy-pipe-head.png',
                                height: 30,
                              ),
                              Image.asset(
                                'images/flappy-pipe.png',
                                width: obstacleWidth,
                                height: obstacle4Y,
                                repeat: ImageRepeat.repeatY,
                                fit: BoxFit.fill,
                              ),
                            ],
                          ),
                        ),
                        top: 0,
                        left: obstacle4X,
                      ),
                      Positioned(
                        child: Column(
                          children: [
                            Image.asset(
                              'images/flappy-pipe-head.png',
                              height: 30,
                            ),
                            Image.asset(
                              'images/flappy-pipe.png',
                              width: obstacleWidth,
                              height: height - 250,
                              repeat: ImageRepeat.repeatY,
                              fit: BoxFit.fill,
                            ),
                          ],
                        ),
                        top: obstacle4Y + 250,
                        left: obstacle4X,
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Text(score.toString(),
                          style: TextStyle(color: Colors.white, shadows: [
                            Shadow(offset: Offset(-1, -1), color: Colors.black),
                            Shadow(offset: Offset(1, -1), color: Colors.black),
                            Shadow(offset: Offset(-1, 1), color: Colors.black),
                            Shadow(offset: Offset(1, 1), color: Colors.black),
                          ]),
                          textAlign: TextAlign.center,),
                      ),
                      if (gameState == GameState.paused)
                        Positioned(
                          top: 100,
                          left: 0,
                          right: 0,
                          child: Text('Paused! Press "P" to unpause.',
                              style: TextStyle(color: Colors.white, shadows: [
                                Shadow(offset: Offset(-1, -1), color: Colors.black),
                                Shadow(offset: Offset(1, -1), color: Colors.black),
                                Shadow(offset: Offset(-1, 1), color: Colors.black),
                                Shadow(offset: Offset(1, 1), color: Colors.black),
                              ]),
                          textAlign: TextAlign.center,),
                        ),
                      if (gameState == GameState.lost)
                        Positioned(
                          top: 100,
                          left: 0,
                          right: 0,
                          child: Text('You died!',
                            style: TextStyle(color: Colors.white, shadows: [
                              Shadow(offset: Offset(-1, -1), color: Colors.black),
                              Shadow(offset: Offset(1, -1), color: Colors.black),
                              Shadow(offset: Offset(-1, 1), color: Colors.black),
                              Shadow(offset: Offset(1, 1), color: Colors.black),
                            ]),
                            textAlign: TextAlign.center,),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum GameState { going, paused, lost }

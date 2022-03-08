import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:my_portfolio/page/base_page.dart';
import 'package:my_portfolio/widget/media_bar.dart';

class WordlePage extends ConsumerStatefulWidget {
  const WordlePage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _WordlePageState();
}

class _WordlePageState extends ConsumerState<WordlePage> {
  late String word;
  List<List<WordleTile>> wordleTiles =
      List.generate(6, (index) => List.generate(5, (index) => WordleTile()));
  int row = 0;
  int col = 0;
  bool gameFinished = false;
  final wordCountMap = <String, int>{};

  final keyboardTiles = List.of('qwertyuiopasdfghjklzxcvbnm'
      .toUpperCase()
      .split('')
      .map((e) => KeyboardTile(e))
      .toList());

  final keyBoardFocusNode = FocusNode();

  @override
  void initState() {
    fetchWord();
    keyBoardFocusNode.requestFocus();
    super.initState();
  }

  fetchWord() async {
    final response =
        await http.get(Uri.parse('/assets/dict/five-letter-words.txt'));
    final allWords = response.body.split('\n');
    final nextInt = Random().nextInt(allWords.length);
    word = allWords[nextInt];
    word.split('').forEach((character) =>
        wordCountMap[character] = (wordCountMap[character] ?? 0) + 1);
    //print('Word is $word');
  }

  void reset() {
    fetchWord();
    row = 0;
    col = 0;
    gameFinished = false;
    wordleTiles.forEach((list) {
      list.forEach((tile) {
        tile.letter = '';
        tile.closeness = WordleTileCloseness.nonExistent;
      });
    });
    keyboardTiles.forEach((element) {
      element.closeness = WordleTileCloseness.notChecked;
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=> keyBoardFocusNode.requestFocus(),
      child: BasePage(
        withMediaBar: true,
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Text('Wordle',style: TextStyle(fontSize: 64),),
                ConstrainedBox(
                  constraints: BoxConstraints.expand(
                    width: 800,
                    height: MediaQuery.of(context).size.height - MediaBar.height - 300,
                  ),
                  child: RawKeyboardListener(
                    focusNode: keyBoardFocusNode,
                    autofocus: true,
                    onKey: (key) {
                      if (gameFinished) {
                        print(word);
                        return;
                      }
                      if (key.runtimeType == RawKeyUpEvent ||
                          col >= wordleTiles.length) {
                        return;
                      }
                      if (row < wordleTiles[0].length &&
                          RegExp(r'[a-zA-Z]').hasMatch(key.data.keyLabel)) {
                        setState(() {
                          wordleTiles[col][row].letter = key.data.keyLabel;
                        });
                        row++;
                      }
                      if (key.data.physicalKey == PhysicalKeyboardKey.enter &&
                          wordleTiles[col]
                                  .map((e) => e.letter.isNotEmpty ? 1 : 0)
                                  .reduce((value, element) => value + element) ==
                              wordleTiles[col].length) {
                        final cloneMap = Map.from(wordCountMap);
                        for (int i = 0; i < wordleTiles[col].length; i++) {
                          if (cloneMap.containsKey(wordleTiles[col][i].letter) &&
                              cloneMap[wordleTiles[col][i].letter] > 0) {
                            wordleTiles[col][i].closeness =
                                WordleTileCloseness.wrongSpot;
                            if (cloneMap.keys
                                        .toList()
                                        .indexOf(wordleTiles[col][i].letter) ==
                                    i ||
                                word.split('')[i] == wordleTiles[col][i].letter) {
                              wordleTiles[col][i].closeness =
                                  WordleTileCloseness.correctSpot;
                            }
                            cloneMap[wordleTiles[col][i].letter]--;
                          }
                          keyboardTiles[keyboardTiles.indexWhere((element) =>
                                  element.letter ==
                                  wordleTiles[col][i].letter.toUpperCase())]
                              .changeCloseness(wordleTiles[col][i].closeness);
                          setState(() {});
                        }
                        if (wordleTiles[col].every((wordleTile) =>
                            wordleTile.closeness == WordleTileCloseness.correctSpot)) {
                          gameFinished = true;
                        }
                        row = 0;
                        col++;
                        if (col >= wordleTiles.length) {
                          gameFinished = true;
                        }
                      }
                      if (key.data.physicalKey == PhysicalKeyboardKey.backspace) {
                        if (row > 0) {
                          row--;
                        }
                        setState(() {
                          wordleTiles[col][row].letter = '';
                        });
                      }
                    },
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = 0; i < wordleTiles.length; i++)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: wordleTiles[i]
                                  .map(
                                    (e) => Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        color: e.closeness.color,
                                        child: e.letter.isNotEmpty
                                            ? Center(
                                                child: Text(
                                                  e.letter.toUpperCase(),
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 30),
                                                  textAlign: TextAlign.center,
                                                ),
                                              )
                                            : Container(),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          if (gameFinished)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Word was: $word'),
                                TextButton(
                                    onPressed: () => reset(), child: const Text('Reset')),
                              ],
                            ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: keyboardTiles
                                .getRange(0, 10)
                                .map((e) => Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Container(
                                        width: 40,
                                        height: 50,
                                        color: e.closeness.color,
                                        child: Center(child: Text(e.letter)),
                                      ),
                                    ))
                                .toList(),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: keyboardTiles
                                .getRange(10, 19)
                                .map((e) => Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Container(
                                        width: 40,
                                        height: 50,
                                        color: e.closeness.color,
                                        child: Center(child: Text(e.letter)),
                                      ),
                                    ))
                                .toList(),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: keyboardTiles
                                .getRange(19, 26)
                                .map((e) => Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Container(
                                        width: 40,
                                        height: 50,
                                        color: e.closeness.color,
                                        child: Center(child: Text(e.letter)),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
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

enum WordleTileCloseness { correctSpot, wrongSpot, nonExistent, notChecked }

extension WordleTileClosenessExtension on WordleTileCloseness {
  String get name => describeEnum(this);

  Color get color {
    switch (this) {
      case WordleTileCloseness.correctSpot:
        return Colors.green;
      case WordleTileCloseness.wrongSpot:
        return Colors.orangeAccent;
      case WordleTileCloseness.notChecked:
        return Colors.grey;
      default:
        return const Color(0xFF3F3F3F);
    }
  }
}

class WordleTile {
  String letter = '';
  WordleTileCloseness closeness = WordleTileCloseness.nonExistent;
}

class KeyboardTile {
  final String letter;
  WordleTileCloseness closeness = WordleTileCloseness.notChecked;

  void changeCloseness(WordleTileCloseness closeness) {
    if (this.closeness == WordleTileCloseness.correctSpot) return;
    if (this.closeness == WordleTileCloseness.wrongSpot &&
        closeness == WordleTileCloseness.nonExistent) return;
    this.closeness = closeness;
  }

  KeyboardTile(this.letter);
}

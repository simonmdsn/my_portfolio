import 'package:flutter/cupertino.dart';

abstract class Lexer {
  late final CharacterRange charIterator;
  late String currentChar;
  bool finished = false;

  /// TODO make for file?
  Lexer(String content) {
    charIterator = Characters(content).iterator;
    advance();
  }

  void advance() {
    charIterator.moveNext()
        ? currentChar = charIterator.current
        : finished = true;
  }

  List<Token> lex();
}

class Token {
  final dynamic type;
  final dynamic value;

  Token(
    this.type,
    this.value,
  );

  @override
  String toString() => 'Token(type: $type, value: $value)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Token && other.type == type && other.value == value;
  }

  @override
  int get hashCode => type.hashCode ^ value.hashCode;
}


import 'package:generator/lexer.dart';

class DartLexer extends Lexer {
  DartLexer(String content) : super(content);

  @override
  List<Token> lex() {
    final tokens = <Token>[];

    while (!finished) {
      if (' \t'.contains(currentChar)) {
      } else if (RegExp(r'[_a-zA-Z]').hasMatch(currentChar)) {
        Token symbolToken = lexSymbol();
        tokens.add(symbolToken);
      }
      advance();
    }
    return tokens;
  }

  Token lexSymbol() {
    String symbol = '';
    while (!finished && RegExp(r'[_a-zA-Z0-9]').hasMatch(currentChar)) {
      symbol += currentChar;
      advance();
    }
    if (symbol == 'int') {
      return DartIntToken('int');
    }
    if (symbol == 'double') {
      return DartDoubleToken('double');
    }
    return DartNameToken(symbol);
  }
}

enum DartTokenTypes {
  int,
  double,
  string,
  dynamic,
  list,
  set,
  map,
  symbol,
  name,
}

class DartIntToken extends Token {
  DartIntToken(value) : super(DartTokenTypes.int, value);
}

class DartDoubleToken extends Token {
  DartDoubleToken(value) : super(DartTokenTypes.double, value);
}

class DartSymbolToken extends Token {
  DartSymbolToken(value) : super(DartTokenTypes.symbol, value);
}

class DartNameToken extends Token {
  DartNameToken(value) : super(DartTokenTypes.name, value);
}

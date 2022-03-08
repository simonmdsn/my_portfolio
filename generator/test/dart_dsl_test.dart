import 'package:generator/dart_dsl.dart';
import 'package:test/test.dart';

void main() {
  test('Dart DSL', () {
    String content = 'int hello';
    final lex = DartLexer(content).lex();
    print(lex);
  });
}
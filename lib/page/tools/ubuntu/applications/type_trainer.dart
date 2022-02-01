import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_portfolio/widget/window_manager/window_manager.dart';
import 'package:http/http.dart' as http;

class TypeTrainer extends ConsumerStatefulWidget {
  TypeTrainer({
    Key? key,
  }) : super(key: UniqueKey());

  @override
  ConsumerState createState() => _TypeTrainerState();
}

class _TypeTrainerState extends ConsumerState<TypeTrainer> {
  final _textInputController = TextEditingController();
  final _textReadOnlyController = TextEditingController();
  String _text = '';
  final _focusNode = FocusNode();
  Timer? _stopWatch;
  int _elapsedMilliseconds = 0;
  bool _finished = false;

  int offset = 0;

  @override
  void initState() {
    fetchWords();
    moveCursor(offset);
    _focusNode.requestFocus();
    super.initState();
  }

  Future<void> fetchWords() async {
    final random = Random();
    var response = await http.get(Uri.parse('/assets/dict/american-english'));
    var split = response.body.split('\n');
    var list =
        List.generate(1, (index) => split[random.nextInt(split.length)]);
    _text = list.join(' ');
    _textReadOnlyController.text = _text;
  }

  void moveCursor(int offset) {
    _textReadOnlyController.text =
        '${_textInputController.text}${_text.substring(_textInputController.text.length)}';
  }

  @override
  Widget build(BuildContext context) {
    final draggableWindow =
        ref.watch(windowManagerProvider.notifier).get(widget.key!) as DraggableWindow;

    return ApplicationHolder(
      child: Center(
        child: SizedBox(
          width: 600,
          child: Column(
            children: [
              Stack(
                children: [
                  Positioned(
                    child: TextFormField(
                      controller: _textReadOnlyController,
                      readOnly: true,
                      autofocus: false,
                      maxLines: null,
                      decoration: const InputDecoration(
                          isDense: true, border: InputBorder.none),
                    ),
                  ),
                  Positioned(
                    child: TextFormField(
                      controller: _textInputController,
                      autofocus: true,
                      maxLines: null,
                      decoration: const InputDecoration(
                          border: InputBorder.none, isDense: true),
                      focusNode: _focusNode,
                      onChanged: (str) {
                        if(_stopWatch?.isActive ?? true) {
                          _stopWatch = Timer.periodic(
                              const Duration(milliseconds: 1), (timer) => _elapsedMilliseconds++);
                        }
                        if (str.length <= _textReadOnlyController.text.length) {
                          moveCursor(str.length);
                        }
                        if (str.length == _textReadOnlyController.text.length &&
                            str == _text) {
                          _stopWatch!.cancel();
                          setState(() {
                            _finished = true;
                          });
                          print(_elapsedMilliseconds);
                        }
                      },
                    ),
                  ),
                ],
              ),
              !_finished
                  ? Container()
                  : Text('Elapsed milliseconds: $_elapsedMilliseconds'),
            ],
          ),
        ),
      ),
      callerKey: widget.key!,
      header: Stack(
        children: [
          const Align(alignment: Alignment.center, child: Text('Type Trainer')),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: WindowHeader.getButtons(
                ref.watch(windowManagerProvider.notifier),
                draggableWindow,
                context),
          ),
        ],
      ),
    );
  }
}

class TextFieldValidatorController extends TextEditingController {
  final String comparisonText;
  String inputText;
  int comparisonOffset;

  TextFieldValidatorController(
      {required this.comparisonText,
      required this.inputText,
      required this.comparisonOffset});

  @override
  set text(String newText) {
    value = value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
      composing: TextRange.empty,
    );
  }

  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    final List<InlineSpan> children = [];
    int index = 0;
    while (index >= comparisonOffset) {
      TextStyle? myStyle;
      if (text.codeUnitAt(index) != comparisonText.codeUnitAt(index)) {
        myStyle = const TextStyle(color: Colors.red);
      }
      children.add(TextSpan(
          text: text.codeUnitAt(index).toString(),
          style: style?.merge(myStyle)));
      index++;
    }
    return TextSpan(style: style, children: children);
  }
}

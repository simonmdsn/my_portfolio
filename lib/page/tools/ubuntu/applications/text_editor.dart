import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_portfolio/page/tools/ubuntu/applications/terminal/args/command_runner.dart';
import 'package:my_portfolio/page/tools/ubuntu/applications/terminal/terminal.dart';
import 'package:my_portfolio/page/tools/ubuntu/ubuntu_page.dart';
import 'package:my_portfolio/widget/window_manager/window_manager.dart';
import 'package:http/http.dart' as http;

class TextEditorCommand extends Command {
  TextEditorCommand() {
    argParser.addOption('network',
        abbr: 'n', help: 'Display text from the internet');
    argParser.addOption('file', abbr: 'f', help: 'file to open');
    argParser.addFlag('line-numbers', abbr: 'l', help: 'display line numbers');
  }

  @override
  String get description => 'text editor';

  @override
  String get name => 'text-editor';

  @override
  String run(Terminal terminal) {
    if (argResults!.wasParsed('file')) {
      terminal.openWindowCallback(TextEditor(
        file: terminal.currentDirectory.files[argResults!['file']],
        lineNumbers: argResults!['line-numbers'],
        callerKey: terminal.key!,
      ));
    }
    if (argResults!.wasParsed('network')) {
      http.get(Uri.parse(argResults!['network'])).then((value) =>
          terminal.openWindowCallback(TextEditor(
            callerKey: terminal.key!,
            file: File(name: argResults!['network'], content: value.bodyBytes),
            lineNumbers: argResults!['line-numbers'],
          )));
      return '';
    }
    return '';
  }
}

class TextEditor extends ConsumerStatefulWidget {
  final File? file;
  final bool lineNumbers;
  final Key callerKey;

  TextEditor({
    required this.callerKey,
    this.file,
    this.lineNumbers = false,
    Key? key,
  }) : super(key: UniqueKey());

  @override
  ConsumerState createState() => _TextEditorState();
}

class _TextEditorState extends ConsumerState<TextEditor> {
  final textController = TextEditingController();

  @override
  void initState() {
    var text = widget.file?.content ?? ''.codeUnits;
    textController.text = Utf8Decoder().convert(text);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var draggableWindow =
        ref.watch(windowManagerProvider.notifier).get(widget.key!);
    return DraggableWindow(
      update: ubuntuUpdateProvider.update,
      key: widget.callerKey,
      child: widget.lineNumbers ? _buildMultiLine() : _buildTextField(),
    );
  }

  Widget _buildTextField({ScrollController? scrollController}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints.expand(width: 2560, height: 1000),
        child: TextField(
          controller: textController,
          scrollController: null,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          style: TextStyle(fontSize: 16.0),
          cursorWidth: 8.0,
          cursorColor: Colors.white70,
          decoration: InputDecoration(
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildMultiLine() {
    final lines = textController.text.split('\n').length;
    var scrollController = ScrollController();
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      controller: scrollController,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(lines, (index) {
                return Text(index.toString(), style: TextStyle(fontSize: 16.0));
              }),
            ),
          ),
          _buildTextField(scrollController: scrollController)
        ],
      ),
    );
  }
}

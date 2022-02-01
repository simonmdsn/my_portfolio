import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_portfolio/page/tools/ubuntu/applications/terminal/args/trie.dart';
import 'package:my_portfolio/page/tools/ubuntu/ubuntu_page.dart';
import 'package:my_portfolio/widget/window_manager/window_manager.dart';
import 'package:http/http.dart' as http;

import '../image_viewer.dart';
import '../text_editor.dart';
import 'args/command_runner.dart';

class TerminalManager extends StateNotifier<Map<Key, Terminal>> {
  TerminalManager(Map<Key, Terminal> state) : super(state);

  Terminal? getByStringKey(String key) {
    var containsKey =
        state.keys.map((e) => e.toString()).toList().contains(key);
    if (!containsKey) return null;
    return state[state.keys.firstWhere((element) => element.toString() == key)];
  }
}

final terminalManagerProvider =
    StateNotifierProvider<TerminalManager, Map<Key, Terminal>>((ref) {
  return TerminalManager({});
});

final commandRunnerProvider = CommandRunner(
  'terminal',
  '',
)
  ..addCommand(EchoCommand())
  ..addCommand(CatCommand())
  ..addCommand(LsCommand())
  ..addCommand(ImageViewerCommand())
  ..addCommand(TextEditorCommand())
  ..addCommand(PwdCommand())
  ..addCommand(CdCommand())
  ..addCommand(MkdirCommand());

class CdCommand extends Command {
  @override
  String get description => 'change directory';

  @override
  // TODO: implement name
  String get name => 'cd';

  @override
  String run(Terminal terminal) {
    var first = argResults?.arguments.first ?? '';
    if (first.isEmpty) return '';
    if (first == '..') {
      if (terminal.currentDirectory.parent != null) {
        terminal.currentDirectory = terminal.currentDirectory.parent!;
      }
      return '';
    }
    terminal.currentDirectory =
        terminal.currentDirectory.directories[argResults!.arguments.first]!;
    return '';
  }
}

class MkdirCommand extends Command {
  MkdirCommand() {}

  @override
  String get description => 'create directory';

  @override
  String get name => 'mkdir';

  @override
  String run(Terminal terminal) {
    if (argResults!.arguments.isNotEmpty &&
        !terminal.currentDirectory.directories
            .containsKey(argResults!.arguments.first)) {
      terminal.currentDirectory.directories[argResults!.arguments.first] =
          Directory(
              name: argResults!.arguments.first,
              parent: terminal.currentDirectory);
    }
    return '';
  }
}

class PwdCommand extends Command {
  @override
  String get description => 'print working directory';

  @override
  // TODO: implement name
  String get name => 'pwd';

  @override
  String run(Terminal terminal) {
    return terminal.currentDirectory.printWorkingDirectory();
  }
}

class ImageViewerCommand extends Command {
  ImageViewerCommand() {
    argParser.addOption('network',
        abbr: 'n', help: 'Display image from the internet');
    argParser.addOption('file',
        abbr: 'f', help: 'Display image from filesystem');
  }

  @override
  String get description => 'ImageViewer';

  @override
  String get name => 'image-viewer';

  @override
  String run(Terminal terminal) {
    if (argResults!.wasParsed('file')) {
      terminal.openWindowCallback(
        ImageViewer(
          imageFile: terminal.currentDirectory.files[argResults!['file']],
        ),
      );
      return '';
    }

    /// network -n
    if (argResults!.wasParsed('network')) {
      http
          .get(Uri.parse(argResults!['network']))
          .then((value) => terminal.openWindowCallback(ImageViewer(
                imageFile: File(
                    name: argResults!['network'], content: value.bodyBytes),
              )));
      return '';
    }
    var currentDirectory = terminal.currentDirectory;
    terminal.openWindowCallback(
      ImageViewer(
        imageFile: currentDirectory.files[argResults!.arguments.first],
      ),
    );
    return '';
  }
}

class LsCommand extends Command {
  @override
  String get description => 'list directories';

  @override
  String get name => 'ls';

  @override
  String run(Terminal terminal) {
    var currentDirectory = terminal.currentDirectory;
    var list = currentDirectory.directories.keys.map((e) => '/$e').toList()
      ..addAll(currentDirectory.files.keys.toList());
    return list.map((e) => '$e     ').toList().join();
  }
}

class CatCommand extends Command {
  @override
  String get description => 'displays text from file';

  @override
  String get name => 'cat';

  @override
  String run(Terminal terminal) {
    var fileName = argResults?.arguments.first ?? '';
    var directory = terminal.currentDirectory;
    var file = directory.files[fileName];
    if (file == null) {
      return 'No such file: $fileName';
    }
    if (file.content.length > 100000) {
      return 'File is too big to display, file length: ${file.content.length}';
    }
    return const Utf8Decoder().convert(file.content.toList());
  }
}

class EchoCommand extends Command {
  @override
  String get description => 'display a line of text';

  @override
  String get name => 'echo';

  @override
  String run(Terminal terminal) {
    return argResults!.arguments
        .sublist(0, argResults!.arguments.length - 1)
        .join(' ')
        .toString();
  }
}

class Terminal extends ConsumerStatefulWidget {
  Directory currentDirectory = fileSystem.root;
  final outputText = <String>[];
  final Function(Widget) openWindowCallback;
  final Key windowKey;

  void addOutput(String string) {
    if (string.isNotEmpty) outputText.add(string);
  }

  Terminal(
    this.openWindowCallback, {
    required this.windowKey,
    Key? key,
  }) : super(key: UniqueKey());

  @override
  ConsumerState createState() => _TerminalState();
}

class _TerminalState extends ConsumerState<Terminal> {
  final inputController = TextEditingController();
  final inputFocus = FocusNode();

  final inputHistory = ListQueue<String>();
  int inputHistoryIndex = 0;

  String get cwd =>
      'root@ubuntu: ${widget.currentDirectory.printWorkingDirectory()}\$ ';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var watch = ref.watch(terminalManagerProvider);
    var draggableWindow =
        ref.watch(windowManagerProvider.notifier).get(widget.key!);
    if (!watch.containsKey(widget.key!)) {
      watch[widget.key!] = widget;
    }
    return DraggableWindow(
      update: () => setState(() {}),
      key: widget.key,
      child: Shortcuts(
        shortcuts: {
          LogicalKeySet.fromSet(
                  {LogicalKeyboardKey.control, LogicalKeyboardKey.keyL}):
              ClearIntent(),
          LogicalKeySet.fromSet({LogicalKeyboardKey.arrowUp}):
              CommandHistoryUpIntent(),
          LogicalKeySet.fromSet({LogicalKeyboardKey.arrowDown}):
              CommandHistoryDownIntent(),
          LogicalKeySet.fromSet({LogicalKeyboardKey.tab}): ReadLineIntent(),
        },
        child: Actions(
          actions: {
            ClearIntent: CallbackAction<ClearIntent>(
              onInvoke: (intent) {
                setState(() {
                  widget.outputText.clear();
                  inputController.text = '';
                });
              },
            ),
            CommandHistoryUpIntent:
                CallbackAction<CommandHistoryUpIntent>(onInvoke: (intent) {
              if (inputHistory.isEmpty && inputHistoryIndex == 0 ||
                  inputHistory.length == inputHistoryIndex) return;
              final text = inputHistory.elementAt(inputHistoryIndex);
              setState(() {
              inputController.text = text;
                inputController.selection = TextSelection.fromPosition(
                    TextPosition(offset: text.length));
              });
              inputHistoryIndex++;
            }),
            CommandHistoryDownIntent: CallbackAction<CommandHistoryDownIntent>(
              onInvoke: (intent) {
                if (inputHistory.isEmpty && inputHistoryIndex == 0 ||
                    inputHistoryIndex == 0 ||
                    inputHistoryIndex - 1 == inputHistory.length) {
                  return;
                }
                inputHistoryIndex--;
                if (inputHistoryIndex == 0) {
                  inputController.clear();
                  return;
                }
                final text = inputHistory.elementAt(inputHistoryIndex - 1);
                inputController.text = text;
                setState(() {
                  inputController.selection = TextSelection.fromPosition(
                    TextPosition(offset: text.length),
                  );
                });
              },
            ),
            ReadLineIntent: CallbackAction<ReadLineIntent>(onInvoke: (intent) {
              if (inputController.text.isEmpty) {
                setState(() {
                  widget.outputText
                      .add(commandRunnerProvider.commands.keys.join(', '));
                });
                return;
              }

              /// input has a valid command and a space
              if (commandRunnerProvider.commands.keys
                  .contains(inputController.text.trim().split(' ').first)) {
                if (inputController.text.trim().split(' ').length > 1) {
                  if (widget.currentDirectory.files.isEmpty &&
                      widget.currentDirectory.directories.isEmpty) {
                    setState(() {
                      widget.outputText.add(cwd + inputController.text);
                      widget.outputText.add(
                          'No files or directores in ${widget.currentDirectory.printWorkingDirectory()}');
                    });
                  }

                  var split = inputController.text.trim().split(' ');

                  var filesWhere = widget.currentDirectory.files.keys
                      .where((element) => element.startsWith(split.last))
                      .toList();
                  var directoriesWhere = widget
                      .currentDirectory.directories.keys
                      .where((element) => element.startsWith(split.last))
                      .toList();
                  if (filesWhere.isEmpty && directoriesWhere.isEmpty) {
                    setState(() {
                      widget.outputText.add(cwd + inputController.text);
                      widget.outputText.add('No such files or directories...');
                    });
                    return;
                  }
                  if (filesWhere.length == 1 && directoriesWhere.isEmpty) {
                    var substring =
                        filesWhere.first.substring(split.last.length);
                    setState(() {
                      inputController.text += substring;
                      inputController.selection = TextSelection.fromPosition(
                          TextPosition(offset: inputController.text.length));
                    });
                    return;
                  } else if (filesWhere.isEmpty &&
                      directoriesWhere.length == 1) {
                    var substring =
                        directoriesWhere.first.substring(split.last.length);
                    setState(() {
                      inputController.text += substring;
                      inputController.selection = TextSelection.fromPosition(
                          TextPosition(offset: inputController.text.length));
                    });
                    return;
                  } else if (filesWhere.isNotEmpty && filesWhere.isNotEmpty) {
                    setState(() {
                      widget.outputText.add(cwd + inputController.text);
                      directoriesWhere.addAll(filesWhere);
                      widget.outputText.add(directoriesWhere.join('     '));
                    });
                    return;
                  }
                  return;
                }
                if (widget.currentDirectory.files.isNotEmpty) {
                  if (widget.currentDirectory.files.length == 1) {
                    var first = widget.currentDirectory.files.keys.first;
                    setState(() {
                    inputController.text += first;
                      inputController.selection = TextSelection.fromPosition(
                          TextPosition(offset: inputController.text.length));
                    });
                  } else {
                    setState(() {
                      widget.outputText.add(cwd + inputController.text);
                      var list = widget.currentDirectory.directories.keys
                          .map((e) => '/$e')
                          .toList()
                        ..addAll(widget.currentDirectory.files.keys.toList());
                      widget.outputText
                          .add(list.map((e) => '$e     ').toList().join());
                    });
                  }
                }
                return;
              } else {}

              /// suggest command
              if (inputController.text.trim().split(' ').length < 2) {
                var allWordsWithPrefix = trie.getAllWordsWithPrefix(
                    inputController.text.trim().split(' ').last);
                print('suggesting commands: $allWordsWithPrefix');
                if (allWordsWithPrefix.isEmpty) return;
                if (allWordsWithPrefix.length == 1) {
                  setState(() {
                    inputController.text = allWordsWithPrefix.first + ' ';
                    inputController.selection = TextSelection.fromPosition(
                        TextPosition(offset: inputController.text.length));
                  });
                  return;
                } else {
                  setState(() {
                    widget.outputText.add(cwd + inputController.text);
                    widget.outputText.add(allWordsWithPrefix.join('     '));
                  });
                }
                return;
              }
              return;
            }),
          },
          child: SingleChildScrollView(
            child: GestureDetector(
              onTap: () => inputFocus.requestFocus(),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  ...watch[widget.key!]!
                      .outputText
                      .map((e) => Align(
                          alignment: Alignment.centerLeft,
                          child: SelectableText(e)))
                      .toList(),
                  TextField(
                    controller: inputController,
                    autofocus: true,
                    decoration: InputDecoration(
                      prefix: Text(cwd),
                    ),
                    onSubmitted: (string) {
                      var parse = commandRunnerProvider.run(
                          [...string.split(' '), widget.key!.toString()],
                          widget);
                      setState(() {
                        widget.outputText.add(cwd + string);
                        parse.then((value) =>
                            watch[widget.key!]!.addOutput(value.toString()));
                        inputHistory.addFirst(string);
                        inputHistoryIndex = 0;
                        inputController.clear();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CommandHistoryDownIntent extends Intent {}

class CommandHistoryUpIntent extends Intent {}

class ClearIntent extends Intent {}

class ReadLineIntent extends Intent {}

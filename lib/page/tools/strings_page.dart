import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_portfolio/config/string_utils.dart';
import 'package:my_portfolio/page/base_page.dart';

class StringsPage extends ConsumerStatefulWidget {
  const StringsPage({Key? key}) : super(key: key);

  @override
  _StringsPageState createState() => _StringsPageState();
}

class CallbackOutput {
  final VoidCallback callback;
  final String output;

  CallbackOutput(this.callback, this.output);
}

class ToggleCallbackOptions {
  final VoidCallback callback;
  final Widget? options;

  ToggleCallbackOptions(this.callback, {this.options});
}

class _StringsPageState extends ConsumerState<StringsPage>
    with SingleTickerProviderStateMixin {
  final inputFieldController = TextEditingController();
  final outputFieldController = TextEditingController();
  late final splitFieldController = TextEditingController();
  late final joinFieldController = TextEditingController();

  final inputFieldFocusNode = FocusNode();

  late AnimationController _controller;
  late Map<String, Widget> currentOptions = {};
  late Map<String, CallbackOutput> currentListeners = {};

  late Map<String, ToggleCallbackOptions> toggleButtons = {
    'Capitalize': ToggleCallbackOptions(() {
      outputFieldController.text = outputFieldController.text.capitalize();
    }),
    'Capitalize words': ToggleCallbackOptions(() {
      outputFieldController.text = outputFieldController.text.capitalizeWords();
    }),
    'Reverse': ToggleCallbackOptions(() {
      outputFieldController.text = outputFieldController.text.reverse();
    }),
    'Uppercase': ToggleCallbackOptions(() {
      outputFieldController.text = outputFieldController.text.toUpperCase();
    }),
    'Lowercase': ToggleCallbackOptions(() {
      outputFieldController.text = outputFieldController.text.toLowerCase();
    }),
    'Reverse Case': ToggleCallbackOptions(() {
      outputFieldController.text = outputFieldController.text.swapCase();
    }),
    'Palindrome': ToggleCallbackOptions(() {
      outputFieldController.text.isPalindrome()
          ? outputFieldController.text =
              '"' + outputFieldController.text + '" is a palindrome'
          : outputFieldController.text =
              outputFieldController.text + outputFieldController.text.reverse();
    }),
    'Split': ToggleCallbackOptions(
      () {
        splitFieldController.text = ';';
        joinFieldController.text = ' ';
        outputFieldController.text = outputFieldController.text
            .split(splitFieldController.text)
            .join(joinFieldController.text);
      },
      options: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
                labelText: 'Character(s) to split on (default is a semicolon)'),
            controller: splitFieldController,
            onChanged: (str) {
              setState(() {
                inputFieldController
                    .removeListener(currentListeners['Split']!.callback);
                callback() {
                  outputFieldController.text = outputFieldController.text
                      .split(str)
                      .join(joinFieldController.text);
                }
                callback();
                addListener('Split', callback);
                inputFieldController.notifyListeners();
                currentListeners['Split'] = CallbackOutput(
                    callback,
                    outputFieldController.text
                        .split(str)
                        .join(joinFieldController.text));
              });
            },
          ),
          TextField(
            decoration: const InputDecoration(
                labelText: 'Character(s) to join on (default is a space)'),
            controller: joinFieldController,
            onChanged: (str) {
              setState(() {
                inputFieldController
                    .removeListener(currentListeners['Split']!.callback);
                callback() {
                  outputFieldController.text = outputFieldController.text
                      .split(splitFieldController.text)
                      .join(str);
                }
                callback();
                addListener('Split', callback);
                inputFieldController.notifyListeners();
                currentListeners['Split'] = CallbackOutput(
                    callback,
                    outputFieldController.text
                        .split(splitFieldController.text)
                        .join(str));
              });
            },
          ),
        ],
      ),
    ),
    'Unicode code points': ToggleCallbackOptions(() {
      outputFieldController.text = outputFieldController.text.runes.join(' ');
    }),
    'Base64 Encode': ToggleCallbackOptions(() {
      outputFieldController.text =
          base64Encode(outputFieldController.text.codeUnits);
    }),
    'Base64 Decode': ToggleCallbackOptions(() {
      try {
        outputFieldController.text =
            utf8.decode(base64Decode(outputFieldController.text));
      } catch (e) {
        outputFieldController.text = 'Error, could not base64 decode text';
      }
    }),
    'Random': ToggleCallbackOptions(() {
      outputFieldController.text =
          StringUtils.randomString(outputFieldController.text.length);
    }),
    'Character Array': ToggleCallbackOptions(() {
      outputFieldController.text =
          outputFieldController.text.split('').toString();
    }),
  };
  late List<bool> isSelected =
      List.generate(toggleButtons.length, (index) => false);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    newListener() {
      setState(() {
        outputFieldController.text = inputFieldController.text;
      });
    }
    currentListeners['default'] =
        CallbackOutput(newListener, outputFieldController.text);
    inputFieldController.addListener(newListener);
  }

  @override
  void dispose() {
    inputFieldController.dispose();
    outputFieldController.dispose();
    _controller.dispose();
    super.dispose();
  }

  String get inputText => inputFieldController.text;

  addListener(String name, VoidCallback callback) {
    currentListeners[name] =
        CallbackOutput(callback, outputFieldController.text);
    inputFieldController.addListener(callback);
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
        child: Center(
      child: SizedBox(
        width: 800,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: currentListeners.length < 2
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Nothing selected...'),
                    )
                  : Row(
                      children: List.from(
                              currentListeners.keys.toList().sublist(1))
                          .map((e) => Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        // cancel button
                                        IconButton(
                                          splashRadius: 20,
                                          iconSize: 20,
                                          onPressed: () {
                                            var indexOfToggle = toggleButtons
                                                .keys
                                                .toList()
                                                .indexOf(e);
                                            setState(() {
                                              isSelected[indexOfToggle] = false;
                                              inputFieldController
                                                  .removeListener(
                                                      currentListeners[e]!
                                                          .callback);
                                              currentListeners.remove(e);
                                              currentOptions.remove(e);
                                              inputFieldController
                                                  .notifyListeners();
                                              inputFieldFocusNode
                                                  .requestFocus();
                                            });
                                          },
                                          icon:
                                              const Icon(Icons.cancel_outlined),
                                        ),
                                        Text(e),
                                      ],
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          var output = currentListeners[e];
                                          Clipboard.setData(ClipboardData(
                                            text: output!.output,
                                          ));
                                        },
                                        splashRadius: 24,
                                        tooltip: 'Copy pipe output from $e',
                                        icon: const Icon(
                                          Icons.copy_outlined,
                                        )),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 350,
                    child: TextField(
                      controller: inputFieldController,
                      focusNode: inputFieldFocusNode,
                    ),
                  ),
                  SizedBox(
                    width: 350,
                    child: TextField(
                      controller: outputFieldController,
                      readOnly: true,
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        if (outputFieldController.text.isNotEmpty) {
                          Clipboard.setData(
                              ClipboardData(text: outputFieldController.text));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Copied to clipboard.'),
                              width: 157,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      tooltip: 'Copy to clipboard',
                      icon: const Icon(Icons.copy_outlined))
                ],
              ),
            ),
            Center(
              child: SizedBox(
                width: 700,
                height: 400,
                child: Wrap(
                  children: List.generate(isSelected.length, (index) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          isSelected[index] = !isSelected[index];
                          if (isSelected[index]) {
                            var entry = toggleButtons.entries.toList()[index];
                            setState(() {
                              entry.value.callback();
                            });
                            addListener(entry.key, entry.value.callback);
                            if (entry.value.options != null) {
                              currentOptions[entry.key] = entry.value.options!;
                            }
                          } else {
                            var key = toggleButtons.keys.toList()[index];
                            inputFieldController.removeListener(
                                currentListeners[key]!.callback);
                            currentListeners.remove(key);
                            currentOptions.remove(key);
                            inputFieldController.notifyListeners();
                          }
                          inputFieldFocusNode.requestFocus();
                        });
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          color: isSelected[index] ? Colors.lightBlue : null,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(toggleButtons.keys.toList()[index]),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            ...currentOptions.values,
          ],
        ),
      ),
    ));
  }
}

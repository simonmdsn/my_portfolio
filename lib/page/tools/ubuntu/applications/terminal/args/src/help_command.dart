// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:my_portfolio/page/tools/ubuntu/applications/terminal/terminal.dart';

import '../command_runner.dart';

/// The built-in help command that's added to every [CommandRunner].
///
/// This command displays help information for the various subcommands.
class HelpCommand<T> extends Command<T> {
  @override
  final name = 'help';

  @override
  String get description =>
      'Display help information for ${runner!.executableName}.';

  @override
  String get invocation => '${runner!.executableName} help [command]';

  @override
  bool get hidden => true;

  @override
  // TODO: Remove when https://github.com/dart-lang/linter/issues/2792 is fixed.
  // ignore: prefer_void_to_null
  String run(Terminal terminal) {
    // Show the default help if no command was specified.
    if (argResults!.rest.isEmpty) {
      runner!.printUsage();
      return runner!.usage;
    }

    // Walk the command tree to show help for the selected command or
    // subcommand.
    var commands = runner!.commands;
    Command? command;
    var commandString = runner!.executableName;

    for (var name in argResults!.rest) {
      if (commands.isEmpty) {
        return command!.usage;
      }

      if (commands[name] == null) {
        if (command == null) {
          return runner!.usage;
          runner!.usageException('Could not find a command named "$name".');
        }

      }

      command = commands[name];
      commands = command!.subcommands as Map<String, Command<T>>;
      commandString += ' $name';
    }

    command!.printUsage();
    return command.usage;
  }
}

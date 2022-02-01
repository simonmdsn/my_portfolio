import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_portfolio/page/base_page.dart';
import 'package:my_portfolio/page/tools/ubuntu/applications/image_viewer.dart';
import 'package:my_portfolio/page/tools/ubuntu/dock.dart';
import 'package:my_portfolio/widget/clock.dart';
import 'package:my_portfolio/widget/window_manager/window_manager.dart';
import 'package:http/http.dart' as http;

class File {
  String name;
  Uint8List content;

  File({required this.name, required this.content});
}

class Directory {
  String name;
  Directory? parent;

  final bool isRootDirectory;
  final Map<String, File> files = {};
  final Map<String, Directory> directories = {};

  String printWorkingDirectory() {
    var pwd = '';
    var currentDir = this;
    while (!currentDir.isRootDirectory) {
      pwd = currentDir.name + '/' + pwd;
      currentDir = currentDir.parent!;
    }
    return '/$pwd';
  }

  Directory({required this.name, this.parent, this.isRootDirectory = false});
}

class FileSystem {
  final root = Directory(name: '/', isRootDirectory: true);

  FileSystem() {
    root.directories['opt'] = Directory(name: 'opt', parent: root);
    root.directories['home'] = Directory(name: 'home', parent: root);
    root.directories['bin'] = Directory(name: 'bin', parent: root);
    root.files['hello.txt'] = File(
        name: 'hello.txt',
        content: const Utf8Encoder().convert('Hello, world!'));
    fetch(this);
  }

  /// Returns directory based on [path] given
  ///
  /// I.e. /home/user/documents returns the documents directory
  /// If [path] is empty it returns root directory
  Directory directoryFromPath(String path) {
    var split = path.split('/');
    var currentDir = root;
    if (split.isEmpty) return currentDir;
    var index = 0;
    while (index <= split.length) {
      if (currentDir.directories.containsKey(split[index])) {
        currentDir = currentDir.directories[split[index]]!;
      } else {
        throw 'No such directory ${split[index]}';
      }
      index++;
    }
    return currentDir;
  }

  /// Returns all directory in [path] given
  ///
  /// I.e. /home/user/documents returns a list of given directories
  ///   [root,home,user,documents]
  /// If [path] is empty return a list with root.
  List<Directory> allDirectoriesFromPath(String path) {
    var split = path.split('/');
    var currentDir = root;
    final dirs = [root];
    if (split.isEmpty) return dirs;
    var index = 0;
    while (index <= split.length) {
      if (currentDir.directories.containsKey(split[index])) {
        currentDir = currentDir.directories[split[index]]!;
        dirs.add(currentDir);
      } else {
        throw 'No such directory ${split[index]}';
      }
      index++;
    }
    return dirs;
  }
}

final fileSystem = FileSystem();

class FileSystemManager extends StateNotifier<FileSystem> {
  FileSystemManager(state) : super(state);
}

final fileSystemProvider =
    StateNotifierProvider<FileSystemManager, FileSystem>((ref) {
  var fileSystem = FileSystem();
  fetch(fileSystem);
  return FileSystemManager(fileSystem);
});

Future<void> fetch(FileSystem fileSystem) async {
  var response = await http.get(Uri.parse('/assets//images/ubuntu.png'));
  fileSystem.root.files.putIfAbsent(
      'test.gif', () => File(name: 'test.gif', content: response.bodyBytes));
}

class UbuntuUpdateManager {
  VoidCallback update = () => print('not imp');
}

final ubuntuUpdateProvider = UbuntuUpdateManager();

class UbuntuPage extends ConsumerStatefulWidget {
  static const websiteHeaderHeight = 120.0;
  static const dockWidth = 80.0;
  static const windowHeaderHeight = 40.0;

  const UbuntuPage({Key? key}) : super(key: key);

  @override
  _UbuntuPageState createState() => _UbuntuPageState();
}

class _UbuntuPageState extends ConsumerState<UbuntuPage> {
  @override
  Widget build(BuildContext context) {
    ubuntuUpdateProvider.update = () => setState(() {});
    var watch = ref.watch(windowManagerProvider);
    ref.watch(windowManagerProvider.notifier).setUpdate(() => setState(() {}));
    return BasePage(
      withMediaBar: false,
      child: Column(
        children: [
          Container(
            color: const Color(0xFF1D1D1D),
            height: 20,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(),
                DigitalClock(),
                Container(),
              ],
            ),
          ),
          Stack(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 140,
                //TODO background image
                child: Image.asset(
                  '/images/ubuntu.png',
                  fit: BoxFit.cover,
                ),
              ),
              ...watch
                  .map((e) => Positioned(
                        child: e,
                        left: 100,
                        top: 100,
                      ))
                  .toList(),
              Dock(
                width: UbuntuPage.dockWidth,
                update: () => setState(() {}),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}

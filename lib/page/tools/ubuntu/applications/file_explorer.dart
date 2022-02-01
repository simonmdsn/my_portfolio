import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_portfolio/page/tools/ubuntu/applications/open_file_util.dart';
import 'package:my_portfolio/widget/window_manager/window_manager.dart';

import '../ubuntu_page.dart';

class FileExplorer extends ConsumerStatefulWidget {
  Directory currentDirectory = fileSystem.root;
  final Key windowKey;

  FileExplorer({required this.windowKey,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _FileExplorerState();
}

class _FileExplorerState extends ConsumerState<FileExplorer> {


  @override
  Widget build(BuildContext context) {
    return DraggableWindow(
      update: ubuntuUpdateProvider.update,
      key: widget.windowKey,
      width: 600,
      height: 400,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            ...widget.currentDirectory.directories.entries
                .map((e) => TextButton(
                    onPressed: () {
                      setState(() {

                        widget.currentDirectory = e.value;
                      });
                    },
                    child: Text(e.key)))
                .toList(),
            ...widget.currentDirectory.files.entries.map((e) =>  TextButton(onPressed: () => OpenFileUtil.openFile(e.value, ref, ref.watch(windowManagerProvider.notifier).update?? () => print('asd')), child: Text(e.key))).toList(),
          ],
        ),
      ),
    );
  }
}

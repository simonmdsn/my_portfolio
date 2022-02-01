import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_portfolio/page/tools/ubuntu/applications/file_explorer.dart';
import 'package:my_portfolio/page/tools/ubuntu/applications/terminal/terminal.dart';
import 'package:my_portfolio/page/tools/ubuntu/applications/type_trainer.dart';
import 'package:my_portfolio/page/tools/ubuntu/ubuntu_page.dart';
import 'package:my_portfolio/widget/window_manager/window_manager.dart';

import 'applications/image_viewer.dart';

class Application {
  final String name;
  final String asset;
  final Widget widget;

  Application(
    this.name,
    this.asset,
    this.widget,
  );
}

class Dock extends ConsumerStatefulWidget {
  final VoidCallback update;
  final double width;
  final List<Application> favouriteApplications = [];

  Dock({
    required this.update,
    required this.width,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _DockState();
}

class _DockState extends ConsumerState<Dock> {
  @override
  Widget build(BuildContext context) {
    var fileSystem = ref.watch(fileSystemProvider);
    return Positioned(
      right: 0,
      top: 0,
      child: Container(
        width: widget.width,
        color: const Color(0xCC262626),
        height: MediaQuery.of(context).size.height - 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
                onPressed: () => ref
                    .watch(windowManagerProvider.notifier)
                    .add(ImageViewer(
                      imageFile: fileSystem.root.files['test.gif'],
                    )),
                icon: Icon(Icons.add)),
            IconButton(
                onPressed: () {
                  var key = UniqueKey();
                  ref.watch(windowManagerProvider.notifier).add(Terminal(
                    (child) => ref
                        .watch(windowManagerProvider.notifier)
                        .add(DraggableWindow(
                          update: widget.update,
                          key: key,
                          child: child,
                        )),
                    windowKey: key,
                  ));
                },
                icon: Icon(Icons.code)),
            IconButton(
                onPressed: () {
                  var key = UniqueKey();
                  ref.watch(windowManagerProvider.notifier).add(TypeTrainer(
                    key: key,
                  ));
                },
                icon: Icon(Icons.sort_by_alpha)),
            IconButton(
                onPressed: () {
                  var key = UniqueKey();
                  ref.watch(windowManagerProvider.notifier).add(FileExplorer(
                    key: key,
                    windowKey: key,
                  ));
                },
                icon: Icon(Icons.explore_rounded)),
            // IconButton(
            //     onPressed: () => ref
            //         .watch(windowManagerProvider.notifier)
            //         .add(DraggableWindow(
            //         ImageViewer(
            //           imageFile: '/images/test.gif',
            //         ),
            //             widget.update)),
            //     icon: Icon(Icons.add)),
          ],
        ),
      ),
    );
  }
}

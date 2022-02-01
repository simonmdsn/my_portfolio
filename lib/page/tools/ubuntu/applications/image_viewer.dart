import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_portfolio/page/tools/ubuntu/ubuntu_page.dart';
import 'package:my_portfolio/widget/window_manager/window_manager.dart';

class ImageViewer extends ConsumerStatefulWidget {
  final File? imageFile;

  ImageViewer({
    Key? key,
    required this.imageFile,
  }) : super(key: UniqueKey());

  @override
  ConsumerState createState() => _ImageViewerState();
}

class _ImageViewerState extends ConsumerState<ImageViewer> {
  final TransformationController _transformationController =
      TransformationController();

  @override
  Widget build(BuildContext context) {
    var draggableWindow =
        ref.watch(windowManagerProvider.notifier).get(widget.key!);
    return DraggableWindow(
      update: () => setState(() {}),
      child: ApplicationHolder(
        callerKey: widget.key!,
        header: Stack(
          children: [
            Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    '${(_transformationController.value.getMaxScaleOnAxis() * 100).toInt()} %')),
            Align(
                alignment: Alignment.center,
                child: Text(widget.imageFile?.name.split('/').last ?? '')),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: WindowHeader.getButtons(ref.watch(windowManagerProvider.notifier), draggableWindow as DraggableWindow, context),
            ),
          ],
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: InteractiveViewer(
            transformationController: _transformationController,
            onInteractionEnd: (details) => setState(() {}),
            maxScale: 10,
            minScale: 0.5,
            child: Image.memory(
              widget.imageFile?.content ?? Uint8List.fromList([123,123,123]),
              fit: BoxFit.cover,
            ),
            // child: Image.asset(
            //   widget.imageFile,
            //   fit: BoxFit.scaleDown,
            // ),
          ),
        ),
      ),
    );
  }
}

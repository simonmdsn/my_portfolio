import 'dart:typed_data';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cross_file/cross_file.dart';

class ImagesPage extends ConsumerStatefulWidget {
  const ImagesPage({Key? key}) : super(key: key);

  @override
  _ImagesPageState createState() => _ImagesPageState();
}

class _ImagesPageState extends ConsumerState<ImagesPage> {
  bool _dragging = false;
  XFile? file;
  Uint8List? bytes;
  bool _finished = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget.key,
      body: Column(
        children: [
          DropTarget(
            child: Container(
              width: 200,
              height: 200,
              color: _dragging ? Colors.blue.withOpacity(0.4) : Colors.black26,
            ),
            onDragDone: (detail) {
              setState(() async {
                file = detail.files.first;
              });
            },
            onDragEntered: (detail) {
              setState(() {
                _dragging = true;
              });
            },
            onDragExited: (detail) {
              setState(() {
                _dragging = false;
              });
            },
          ),
          if (file != null) FutureBuilder(
              future: file!.readAsBytes(), builder: (context, snapshot) {
            if (snapshot.hasData && !snapshot.hasError) {
              return Image.memory(snapshot.data as Uint8List);
            }
            return const CircularProgressIndicator();
          })
        ],
      ),
    );
  }
}

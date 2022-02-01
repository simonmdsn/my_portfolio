import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_portfolio/page/tools/ubuntu/applications/image_viewer.dart';
import 'package:my_portfolio/page/tools/ubuntu/applications/text_editor.dart';
import 'package:my_portfolio/widget/window_manager/window_manager.dart';

import '../ubuntu_page.dart';

class OpenFileUtil {
  static const imageFilesSuffix = ['png', 'gif', 'jpeg', 'jpg', 'bmp', 'svg'];

  static openFile(File file, WidgetRef ref, VoidCallback update) {
    var key = UniqueKey();
    if (imageFilesSuffix.contains(file.name.split('.').last)) {
      ref.read(windowManagerProvider.notifier).add(ImageViewer(
            imageFile: file,
            key: key,
          ));
    }
    ref.read(windowManagerProvider.notifier).add(TextEditor(
          callerKey: key,
          file: file,
        ));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_portfolio/page/tools/ubuntu/ubuntu_page.dart';

class ApplicationHolder extends ConsumerStatefulWidget {
  final Widget child;
  final Widget? header;
  final Key callerKey;

  ApplicationHolder(
      {required this.child, required final this.callerKey, this.header})
      : super(key: UniqueKey());

  @override
  ConsumerState createState() => _ApplicationState();
}

class _ApplicationState extends ConsumerState<ApplicationHolder> {
  @override
  Widget build(BuildContext context) {
    var provider = ref.watch(windowManagerProvider.notifier);
    var window = provider.get(widget.callerKey) as DraggableWindow;
    return Column(
      children: [
        GestureDetector(
          /** header **/
          child: Column(
            children: [
              Container(
                color: Colors.transparent,
                height: 40,
                child: widget.header != null
                    ? widget.header!
                    : WindowHeader(
                        window: window,
                      ),
              ),
              const Divider(
                height: 1,
                thickness: 1,
              ),
            ],
          ),
          onTapDown: (details) {
            provider.moveToTop(window);
          },
          //FIXME window can be moved, but will not go to front
          onPanUpdate: (tapInfo) {
            window.x += tapInfo.delta.dx;
            window.y += tapInfo.delta.dy;
            window.update();
          },
        ),

        /// application body
        Expanded(
          child: widget.child,
        ),
      ],
    );
  }
}

//TODO add focus somehow...
class WindowManager extends StateNotifier<List<Widget>> {
  WindowManager(List<Widget>? initialWidgets) : super(initialWidgets ?? []);

  VoidCallback? update;

  void setUpdate(VoidCallback update) {
    update = update;
  }

  void add(Widget window) {
    state = [...state, window];
  }

  void remove(Widget window) {
    state = state.where((target) => window.key! != target.key).toList();
  }

  void removeByKey(Key key) {
    state = state.where((target) => key != target.key).toList();
  }

  void removeByChildKey(Key key) {
    state = state.where((target) => key != target.key).toList();
  }

  Widget get(Key key) {
    return state.firstWhere((element) => element.key == key);
  }

  //TODO top is actually the back in the stack...
  void moveToTop(Widget window) {
    if (state.last == window) return;
    remove(window);
    add(window);
  }

  //TODO top is actually the back in the stack...
  bool isTop(Key key) {
    return state.last.key == key;
  }
}

final windowManagerProvider =
    StateNotifierProvider<WindowManager, List<Widget>>((ref) {
  return WindowManager([]);
});

class WindowHeader extends ConsumerWidget {
  final DraggableWindow window;
  final bool spacer;

  const WindowHeader({
    required this.window,
    this.spacer = true,
    Key? key,
  }) : super(key: key);

  static List<IconButton> getButtons(WindowManager windowManager,
      DraggableWindow window, BuildContext context) {
    return [
      IconButton(
          onPressed: () => print('min'),
          icon: const Icon(Icons.minimize_outlined)),
      IconButton(
          onPressed: () {
            windowManager.moveToTop(window);
            if (window.isMaximized) {
              window.x = window.previousX;
              window.y = window.previousY;
              window.width = window.previousWidth;
              window.height = window.previousHeight;
              window.isMaximized = false;
              window.updateWindow();
              window.update();
            } else {
              var size = MediaQuery.of(context).size;
              window.previousWidth = window.width;
              window.previousHeight = window.height;
              window.width = size.width;
              window.height = size.height - UbuntuPage.websiteHeaderHeight;
              window.previousX = window.x;
              window.previousY = window.y;
              window.x = UbuntuPage.dockWidth;
              window.y = 0;
              window.isMaximized = true;
              window.updateWindow();
              window.update();
            }
          },
          iconSize: 16,
          icon: const Icon(Icons.crop_square_sharp)),
      IconButton(
          onPressed: () => windowManager.removeByChildKey(window.child.key!),
          icon: const Icon(Icons.cancel)),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        if (spacer) const Spacer(),
        ...getButtons(
            ref.watch(windowManagerProvider.notifier), window, context)
      ],
    );
  }
}

class DraggableWindow extends ConsumerStatefulWidget {
  bool isMaximized;
  double x;
  double y;
  late double previousX;
  late double previousY;
  double height;
  double width;
  late double previousHeight;
  late double previousWidth;

  final Widget child;
  final Widget? header;

  final VoidCallback update;
  late VoidCallback updateWindow;

  DraggableWindow({
    required this.child,
    this.header,
    required this.update,
    Key? key,
    this.isMaximized = false,
    this.x = UbuntuPage.dockWidth,
    this.y = 0,
    this.height = 400,
    this.width = 600,
  }) : super(key: key ?? UniqueKey()) {
    previousX = x;
    previousY = y;
    previousHeight = height;
    previousWidth = width;
  }

  @override
  ConsumerState createState() => _DraggableWindowState();
}

class _DraggableWindowState extends ConsumerState<DraggableWindow> {
  @override
  Widget build(BuildContext context) {
    widget.updateWindow = () {
      setState(() {});
    };
    var watch = ref.watch(windowManagerProvider.notifier);
    return GestureDetector(
      onTapDown: (details) => watch.moveToTop(widget),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          boxShadow: [
            watch.isTop(widget.key!)
                ? const BoxShadow(color: Colors.black87, blurRadius: 8.0)
                : const BoxShadow(),
          ],
          color: const Color(0xFF2C2C2C),
          border: Border.all(color: Colors.black87, width: 1),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(8),
            topLeft: Radius.circular(8),
          ),
        ),
        // decoration: BoxDecoration(
        //   borderRadius: BorderRadius.only(topLeft: Radius.circular(8.0)),
        //   border: Border.all(
        //     color: Colors.black87,
        //     width: 1.0,
        //   ),
        // ),
        child: Stack(
          children: [
            Column(
              children: [
                GestureDetector(
                  /** header **/
                  child: Column(
                    children: [
                      Container(
                          color: Colors.transparent,
                          height: 40,
                          child: widget.header ?? Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    const Spacer(),
                                    IconButton(
                                        onPressed: () => print('min'),
                                        icon: const Icon(
                                            Icons.minimize_outlined)),
                                    IconButton(
                                        onPressed: () {
                                          watch.moveToTop(widget);
                                          if (widget.isMaximized) {
                                            widget.x = widget.previousX;
                                            widget.y = widget.previousY;
                                            widget.width = widget.previousWidth;
                                            widget.height =
                                                widget.previousHeight;
                                            widget.isMaximized = false;
                                            widget.updateWindow();
                                            widget.update();
                                          } else {
                                            var size =
                                                MediaQuery.of(context).size;
                                            widget.previousWidth = widget.width;
                                            widget.previousHeight =
                                                widget.height;
                                            widget.width = size.width;
                                            widget.height = size.height -
                                                UbuntuPage.websiteHeaderHeight;
                                            widget.previousX = widget.x;
                                            widget.previousY = widget.y;
                                            widget.x = UbuntuPage.dockWidth;
                                            widget.y = 0;
                                            widget.isMaximized = true;
                                            widget.updateWindow();
                                            widget.update();
                                          }
                                        },
                                        iconSize: 16,
                                        icon: const Icon(
                                            Icons.crop_square_sharp)),
                                    IconButton(
                                        onPressed: () => watch.removeByKey(
                                            widget.child.key!),
                                        icon: const Icon(Icons.cancel)),
                                  ],
                                )),
                      const Divider(
                        height: 1,
                        thickness: 1,
                      ),
                    ],
                  ),
                  // onTapDown: (details) {
                  //   watch.moveToTop(widget);
                  // },
                  //FIXME window can be moved, but will not go to front
                  onPanUpdate: (tapInfo) {
                    widget.x += tapInfo.delta.dx;
                    widget.y += tapInfo.delta.dy;
                    widget.update();
                  },
                ),

                /// application body
                Expanded(
                  child: widget.child,
                ),
              ],
            ),
            Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onPanUpdate: (details) => onHorizontalDragLeft(details),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeLeft,
                    opaque: true,
                    child: Container(
                      width: 4,
                    ),
                  ),
                )),
            Positioned(
                bottom: 0,
                top: 0,
                right: 0,
                child: GestureDetector(
                  onPanUpdate: (details) => onHorizontalDragRight(details),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeRight,
                    opaque: true,
                    child: Container(
                      width: 4,
                    ),
                  ),
                )),
            Positioned(
                left: 0,
                top: 0,
                right: 0,
                child: GestureDetector(
                  onPanUpdate: (details) => onHorizontalDragTop(details),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeUp,
                    opaque: true,
                    child: Container(
                      height: 4,
                    ),
                  ),
                )),
            Positioned(
                left: 0,
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onPanUpdate: (details) => onHorizontalDragBottom(details),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeDown,
                    opaque: true,
                    child: Container(
                      height: 4,
                    ),
                  ),
                )),
            Positioned(
                left: 0,
                bottom: 0,
                child: GestureDetector(
                  onPanUpdate: (details) => onHorizontalDragBottomLeft(details),
                  child: const MouseRegion(
                    cursor: SystemMouseCursors.resizeDownLeft,
                    opaque: true,
                    child: SizedBox(
                      height: 6,
                      width: 6,
                    ),
                  ),
                )),
            Positioned(
                left: 0,
                top: 0,
                child: GestureDetector(
                  onPanUpdate: (details) => onHorizontalDragTopLeft(details),
                  child: const MouseRegion(
                    cursor: SystemMouseCursors.resizeUpLeft,
                    opaque: true,
                    child: SizedBox(
                      height: 6,
                      width: 6,
                    ),
                  ),
                )),
            Positioned(
                right: 0,
                top: 0,
                child: GestureDetector(
                  onPanUpdate: (details) => onHorizontalDragTopRight(details),
                  child: const MouseRegion(
                    cursor: SystemMouseCursors.resizeUpRight,
                    opaque: true,
                    child: SizedBox(
                      height: 6,
                      width: 6,
                    ),
                  ),
                )),
            Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onPanUpdate: (details) =>
                      onHorizontalDragBottomRight(details),
                  child: const MouseRegion(
                    cursor: SystemMouseCursors.resizeDownRight,
                    opaque: true,
                    child: SizedBox(
                      height: 6,
                      width: 6,
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  /// Resize window functions
  void onHorizontalDragLeft(DragUpdateDetails details) {
    setState(() {
      widget.width -= details.delta.dx;
    });
    widget.x += details.delta.dx;
    widget.update();
  }

  void onHorizontalDragRight(DragUpdateDetails details) {
    setState(() {
      widget.width += details.delta.dx;
    });
  }

  void onHorizontalDragTop(DragUpdateDetails details) {
    setState(() {
      widget.height -= details.delta.dy;
    });
    widget.y += details.delta.dy;
    widget.update();
  }

  void onHorizontalDragBottom(DragUpdateDetails details) {
    setState(() {
      widget.height += details.delta.dy;
    });
  }

  void onHorizontalDragTopLeft(DragUpdateDetails details) {
    onHorizontalDragLeft(details);
    onHorizontalDragTop(details);
  }

  void onHorizontalDragTopRight(DragUpdateDetails details) {
    onHorizontalDragRight(details);
    onHorizontalDragTop(details);
  }

  void onHorizontalDragBottomLeft(DragUpdateDetails details) {
    onHorizontalDragLeft(details);
    onHorizontalDragBottom(details);
  }

  void onHorizontalDragBottomRight(DragUpdateDetails details) {
    onHorizontalDragRight(details);
    onHorizontalDragBottom(details);
  }
}

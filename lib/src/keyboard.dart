import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef KeyCallback = bool Function();

/// An abstraction over the [RawKeyboardListener]
///
/// Wrap the whole area which should respond the actions in this widget
class InteractionKeyboard extends StatefulWidget {
  const InteractionKeyboard({
    Key? key,
    required this.onBackspace,
    required this.child,
    required this.onDown,
    required this.onUp,
    required this.onSpace,
    required this.onEnter,
    required this.onCtrlSpace,
    required this.onEscape,
    required this.focusNode,
    required this.onDelete,
    this.debugLabel = "No label",
    this.isScope = false,
    this.autofocus = false,
    this.useRawKeyboardListener = false,
  }) : super(key: key);

  final KeyCallback onBackspace;
  final KeyCallback onDelete;
  final KeyCallback onDown;
  final KeyCallback onUp;
  final KeyCallback onSpace;
  final KeyCallback onEscape;
  final KeyCallback onEnter;
  final KeyCallback onCtrlSpace;
  final String debugLabel;
  final Widget child;
  final FocusNode focusNode;
  final bool isScope;
  final bool autofocus;
  final bool useRawKeyboardListener;

  @override
  _InteractionKeyboardState createState() => _InteractionKeyboardState();
}

class _InteractionKeyboardState extends State<InteractionKeyboard> {
  late FocusNode focusNode;
  late FocusScopeNode focusScopeNode;

  bool focusedOnce = false;

  Map<int, String> _holdingKeys = Map();

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) {
      focusNode = FocusNode();
    } else {
      focusNode = widget.focusNode;
    }

    focusScopeNode = FocusScopeNode();
    /*attachment = focusNode.attach(context);
    focusNode.addListener(() {
      print("Hey");
      print(focusNode.hasFocus);
    });*/
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.focusNode == null && !focusedOnce) {
      //FocusScope.of(context).requestFocus(focusNode);
      focusedOnce = true;
    }
  }

  @override
  void dispose() {
    //focusNode.dispose();
    super.dispose();
  }

  bool onKey(node, RawKeyEvent event) {
    // if(event.isKeyPressed(LogicalKeyboardKey.backspace)) {
    // widget.onBackspace();
    // }

    if (!(event is RawKeyDownEvent || !(event is RawKeyUpEvent))) return false;

    var i = event.logicalKey.keyId;

    assert(event is RawKeyDownEvent);
    event = event as RawKeyDownEvent;

    var hold = _fireKey(event, i);
    if (hold) {
      _postDelayed(event, i, 500);
    }

    return true;
  }

  void _postDelayed(RawKeyEvent event, int i, int millis) {
    Future.delayed(Duration(milliseconds: millis)).then((_) {
      if (RawKeyboard.instance.keysPressed.map((it) => it.keyId).contains(i)) {
        _fireKey(event, i);
        _postDelayed(event, i, 50);
      }
    });
  }

  bool isKeyPressed(int code) {
    return RawKeyboard.instance.keysPressed
        .map((it) => it.keyId)
        .contains(code);
  }

  /// Returns whether it forwarded the event
  bool _fireKey(RawKeyEvent event, int id) {
    print(event.logicalKey.keyId);
    switch (id) {
      case 4295426165:
        // This is the backspace key, I disabled it because it was causing a bug
        // with the backspace inside a text field. For now only the "del" key work
        // to delete widgets
        return widget.onBackspace.call();
      case 114:
        return widget.onDelete.call();
      case 106:
        return widget.onUp.call();
      case 108:
        return widget.onDown.call();
      case 100:
        if (isKeyPressed(1108101562709)) {
          return widget.onCtrlSpace.call();
        } else {
          return widget.onSpace.call();
        }
      case 1108101562395:
        return widget.onEscape.call();
      case 54:
        return widget.onEnter.call();
      default:
        print("Class keyboard.dart $id");
        return false;
    }
  }

  //

  @override
  Widget build(BuildContext context) {
    Widget child = Container();
    if (widget.useRawKeyboardListener) {
      return RawKeyboardListener(
        focusNode: focusNode,
        onKey: (it) => onKey(null, it),
        child: widget.child,
      );
    }
    return widget.isScope
        ? FocusScope(
            // onKey: onKey,
            node: focusScopeNode,
            child: child,
            autofocus: widget.autofocus,
          )
        : Focus(
            // onKey: onKey,
            focusNode: focusNode,
            child: child,
            autofocus: widget.autofocus,
          );
  }
}

import 'dart:async';

import 'package:chat_app/core/utils/abc.dart';
import 'package:chat_app/core/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class AvoidBottomInset extends StatefulWidget {
  const AvoidBottomInset({
    super.key,
    required this.child,
    required this.conditions,
    this.offstage,
    this.padding,
  });

  final Widget child;
  final List<bool> conditions;
  final Widget? offstage;
  final EdgeInsetsGeometry? padding;

  @override
  State<AvoidBottomInset> createState() => _AvoidBottomInsetState();
}

class _AvoidBottomInsetState extends State<AvoidBottomInset>
    with WidgetsBindingObserver {
  double keyboardHeight =
      SharedPref.instance.getDouble('keyboardHeight') ?? 300;
  bool showEmojiPicker = false;
  bool isKeyboardVisible = false;
  bool isKeyboardFullyVisible = false;
  late final StreamSubscription<bool> _keyboardSubscription;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _keyboardSubscription =
        KeyboardVisibilityController().onChange.listen((isVisible) async {
      isKeyboardVisible = isVisible;

      if (isVisible) {
        showEmojiPicker = false;
      } else {
        isKeyboardFullyVisible = false;
      }

      setState(() {});
    });

    super.initState();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (!isKeyboardVisible) return;

    Future.delayed(
      Duration(milliseconds: isKeyboardFullyVisible ? 30 : 500),
      () {
        if (!mounted || !isKeyboardVisible) return;

        final height = MediaQuery.of(context).viewInsets.bottom;
        if (keyboardHeight == height) return;

        setState(
          () {
            isKeyboardFullyVisible = true;
            keyboardHeight = height;
          },
        );
      },
    );
  }

  @override
  void dispose() async {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _keyboardSubscription.cancel();

    final savedHeight = getKeyboardHeight();
    if (keyboardHeight != savedHeight) {
      await SharedPref.instance.setDouble('keyboardHeight', keyboardHeight);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shouldAvoid =
        isKeyboardVisible || widget.conditions.every((element) => element);

    return Padding(
      padding:
          !shouldAvoid ? widget.padding ?? EdgeInsets.zero : EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.child,
          if (shouldAvoid) ...[
            Column(
              children: [
                const SizedBox(
                  height: 4,
                ),
                Stack(
                  children: [
                    SizedBox(
                      height: keyboardHeight,
                    ),
                    if (widget.offstage != null) ...[
                      Container(
                        color: Colors.red,
                        height: keyboardHeight,
                        child: widget.offstage!,
                      )
                    ]
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

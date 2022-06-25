import 'dart:async';
import 'package:flutter/material.dart';

///Auto scrolling text
class ScrollingText extends StatefulWidget {
  final String text;
  final TextStyle? textStyle;
  final Axis scrollAxis;
  final double ratioOfBlankToScreen;

  ScrollingText({
    required this.text,
    this.textStyle,
    this.scrollAxis: Axis.horizontal,
    this.ratioOfBlankToScreen: 0.25,
  });

  @override
  State<StatefulWidget> createState() {
    return ScrollingTextState();
  }
}

class ScrollingTextState extends State<ScrollingText>
    with SingleTickerProviderStateMixin {
  late ScrollController scrollController;
  late double screenWidth;
  late double screenHeight;
  double position = 0.0;
  Timer? timer;
  final double _moveDistance = 3.0;
  final int _timerRest = 100;
  GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      startTimer();
    });
  }

  void startTimer() async {
    await Future.delayed(Duration(seconds: 2));
    if (_key.currentContext != null) {
      double widgetWidth =
          _key.currentContext!.findRenderObject()!.paintBounds.size.width;
      double widgetHeight =
          _key.currentContext!.findRenderObject()!.paintBounds.size.height;

      timer = Timer.periodic(Duration(milliseconds: _timerRest), (timer) {
        double maxScrollExtent = scrollController.position.maxScrollExtent;
        double pixels = scrollController.position.pixels;
        if (pixels + _moveDistance >= maxScrollExtent) {
          if (widget.scrollAxis == Axis.horizontal) {
            position = (maxScrollExtent -
                        screenWidth * widget.ratioOfBlankToScreen +
                        widgetWidth) /
                    2 -
                widgetWidth +
                pixels -
                maxScrollExtent;
          } else {
            position = (maxScrollExtent -
                        screenHeight * widget.ratioOfBlankToScreen +
                        widgetHeight) /
                    2 -
                widgetHeight +
                pixels -
                maxScrollExtent;
          }
          scrollController.jumpTo(position);
        }
        position += _moveDistance;
        scrollController.animateTo(position,
            duration: Duration(milliseconds: _timerRest), curve: Curves.linear);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
  }

  Widget getBothEndsChild() {
    if (widget.scrollAxis == Axis.vertical) {
      String newString = widget.text.split("").join("\n");
      return Center(
        child: Text(
          newString,
          style: widget.textStyle,
          textAlign: TextAlign.center,
        ),
      );
    }
    return Center(
        child: Text(
      widget.text,
      style: widget.textStyle,
    ));
  }

  Widget getCenterChild() {
    if (widget.scrollAxis == Axis.horizontal) {
      return Container(width: screenWidth * widget.ratioOfBlankToScreen);
    } else {
      return Container(height: screenHeight * widget.ratioOfBlankToScreen);
    }
  }

  /// To see if text will overflow?
  bool _isOverflow(BoxConstraints constraint) {
    print(constraint.maxWidth);
    print(widget.text);
    // Build the Text span
    TextSpan _span = TextSpan(text: widget.text, style: widget.textStyle);
    // Use a Text painter to determine if it will exceed max lines
    TextPainter _tp = TextPainter(
      maxLines: 1,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
      text: _span,
    );
    // trigger it to layout
    _tp.layout(maxWidth: constraint.maxWidth);
    print(_tp.didExceedMaxLines);
    // whether the text overflowed or not
    return _tp.didExceedMaxLines;
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) => _isOverflow(constraint)
          ? SizedBox(
              height: 28,
              child: ListView(
                key: _key,
                scrollDirection: widget.scrollAxis,
                controller: scrollController,
                physics: NeverScrollableScrollPhysics(),
                children: <Widget>[
                  getBothEndsChild(),
                  getCenterChild(),
                  getBothEndsChild(),
                ],
              ),
            )
          : Text(widget.text, style: widget.textStyle),
    );
  }
}

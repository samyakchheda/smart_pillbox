import 'dart:math';
import 'package:flutter/material.dart';

class RotatingPillAnimation extends StatefulWidget {
  @override
  _RotatingPillAnimationState createState() => _RotatingPillAnimationState();
}

class _RotatingPillAnimationState extends State<RotatingPillAnimation>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  // Controller for open/close (split) animation.
  late AnimationController _splitController;
  late Animation<double> _splitAnimation;

  // Constants for the pill dimensions.
  static const double pillWidth = 100;
  static const double pillHeight = 40;
  // Maximum offset for each half when fully open.
  static const double maxOffset = 20;

  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Rotation: continuously rotates the pill.
    _rotationController =
        AnimationController(vsync: this, duration: Duration(seconds: 4));
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );
    _rotationController.repeat();

    // Split controller: opens and closes the pill.
    _splitController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _splitAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _splitController, curve: Curves.easeInOut),
    );

    // Start periodic cycle for opening/closing.
    _startSplitCycle();
  }

  Future<void> _startSplitCycle() async {
    // Initial delay before first split.
    await Future.delayed(Duration(seconds: 2));
    while (mounted) {
      // Open the pill (split).
      await _splitController.forward();
      // Keep open for a short moment.
      await Future.delayed(Duration(milliseconds: 300));
      // Close the pill.
      await _splitController.reverse();
      // Wait before next cycle.
      await Future.delayed(Duration(seconds: 2));
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _splitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_rotationController, _splitController]),
      builder: (context, child) {
        // Current offset based on split value.
        double offset = _splitAnimation.value * maxOffset;
        // The gap width between halves is 2 * offset.
        double gapWidth = 2 * offset;
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pill halves.
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Left half (black) moves left when open.
                  Transform.translate(
                    offset: Offset(-offset, 0),
                    child: Container(
                      width: pillWidth / 2,
                      height: pillHeight,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(pillHeight / 2),
                          bottomLeft: Radius.circular(pillHeight / 2),
                        ),
                      ),
                    ),
                  ),
                  // Right half (white) moves right when open.
                  Transform.translate(
                    offset: Offset(offset, 0),
                    child: Container(
                      width: pillWidth / 2,
                      height: pillHeight,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(pillHeight / 2),
                          bottomRight: Radius.circular(pillHeight / 2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Bubbles appear only when there's a gap.
              if (gapWidth > 2)
                // Center the bubble container in the pill.
                Positioned(
                  // It covers only the gap area.
                  left: (pillWidth - gapWidth) / 2,
                  top: 0,
                  child: Container(
                    width: gapWidth,
                    height: pillHeight,
                    // Clip so bubbles appear only inside the gap.
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(pillHeight / 2),
                      child: Stack(
                        children: _buildBubbles(gapWidth, pillHeight),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Generate bubble widgets inside the gap.
  /// Each bubble now moves upward very slowly and fades in/out smoothly.
  List<Widget> _buildBubbles(double gapWidth, double pillHeight) {
    List<Widget> bubbles = [];
    // We'll generate between 3 and 5 bubbles.
    int bubbleCount = 3 + _random.nextInt(3);
    // Reduced bubble rise for very slow movement.
    double bubbleRise = 2; // reduced from 5
    // Apply an easing function for smooth transition.
    double easedValue = Curves.easeOut.transform(_splitAnimation.value);
    for (int i = 0; i < bubbleCount; i++) {
      double bubbleSize = _random.nextDouble() * 6 + 4; // 4 to 10 pixels
      double left = _random.nextDouble() * (gapWidth - bubbleSize);
      double baseTop = _random.nextDouble() * (pillHeight - bubbleSize);
      bubbles.add(Positioned(
        left: left,
        // The bubble's top position is animated slowly upward.
        top: baseTop - bubbleRise * easedValue,
        child: Opacity(
          // Bubble opacity is controlled by the eased value.
          opacity: easedValue,
          child: Container(
            width: bubbleSize,
            height: bubbleSize,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ));
    }
    return bubbles;
  }
}

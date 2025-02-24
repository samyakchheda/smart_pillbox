import 'package:flutter/material.dart';
import 'dart:math' as math;

class VoiceRecordButton extends StatefulWidget {
  final Function() onRecordingStarted;
  final Function() onRecordingStopped;
  final Function() onRecordingCancelled;

  const VoiceRecordButton({
    Key? key,
    required this.onRecordingStarted,
    required this.onRecordingStopped,
    required this.onRecordingCancelled,
  }) : super(key: key);

  @override
  _VoiceRecordButtonState createState() => _VoiceRecordButtonState();
}

class _VoiceRecordButtonState extends State<VoiceRecordButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rippleAnimation;

  bool _isRecording = false;
  bool _isCancelling = false;
  Offset _startPosition = Offset.zero;
  Offset _currentPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isRecording = true;
      _startPosition = details.localPosition;
      _currentPosition = _startPosition;
    });
    _animationController.forward();
    widget.onRecordingStarted();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _currentPosition = details.localPosition;
      _isCancelling = (_startPosition.dx - _currentPosition.dx).abs() > 50;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isCancelling) {
      widget.onRecordingCancelled();
    } else {
      widget.onRecordingStopped();
    }
    _resetState();
  }

  void _resetState() {
    setState(() {
      _isRecording = false;
      _isCancelling = false;
      _currentPosition = _startPosition;
    });
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: CustomPaint(
              painter: _VoiceRecordButtonPainter(
                isRecording: _isRecording,
                isCancelling: _isCancelling,
                rippleProgress: _rippleAnimation.value,
                recordingProgress: _animationController.value,
              ),
              child: Container(
                width: 60,
                height: 60,
                child: Icon(
                  _isRecording ? Icons.mic : Icons.mic_none,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _VoiceRecordButtonPainter extends CustomPainter {
  final bool isRecording;
  final bool isCancelling;
  final double rippleProgress;
  final double recordingProgress;

  _VoiceRecordButtonPainter({
    required this.isRecording,
    required this.isCancelling,
    required this.rippleProgress,
    required this.recordingProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Draw base circle
    final paint = Paint()
      ..color = isCancelling ? Colors.red : Colors.blue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, paint);

    if (isRecording) {
      // Draw ripple effect
      final ripplePaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(
          center, radius * (1 + rippleProgress * 0.3), ripplePaint);

      // Draw recording progress
      final progressPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * recordingProgress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _VoiceRecordButtonPainter oldDelegate) {
    return isRecording != oldDelegate.isRecording ||
        isCancelling != oldDelegate.isCancelling ||
        rippleProgress != oldDelegate.rippleProgress ||
        recordingProgress != oldDelegate.recordingProgress;
  }
}

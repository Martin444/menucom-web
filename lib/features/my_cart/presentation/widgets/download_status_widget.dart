import 'package:flutter/material.dart';

/// Download Status Widget - Shows download progress with animation
class DownloadStatusWidget extends StatefulWidget {
  final bool isDownloading;
  final String message;
  final Color? color;

  const DownloadStatusWidget({
    Key? key,
    required this.isDownloading,
    required this.message,
    this.color,
  }) : super(key: key);

  @override
  State<DownloadStatusWidget> createState() => _DownloadStatusWidgetState();
}

class _DownloadStatusWidgetState extends State<DownloadStatusWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    if (widget.isDownloading) {
      _controller.repeat(reverse: true);
    } else {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(DownloadStatusWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDownloading != oldWidget.isDownloading) {
      if (widget.isDownloading) {
        _controller.repeat(reverse: true);
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: (widget.color ?? const Color(0xFF4CAF50)).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.color ?? const Color(0xFF4CAF50),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isDownloading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.color ?? const Color(0xFF4CAF50),
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: widget.color ?? const Color(0xFF4CAF50),
                  ),
                const SizedBox(width: 8),
                Text(
                  widget.message,
                  style: TextStyle(
                    color: widget.color ?? const Color(0xFF4CAF50),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

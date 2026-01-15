import 'package:flutter/material.dart';

class MaskedEmailText extends StatefulWidget {
  final String email;
  const MaskedEmailText({super.key, required this.email});

  @override
  State<MaskedEmailText> createState() => _MaskedEmailTextState();
}

class _MaskedEmailTextState extends State<MaskedEmailText> {
  OverlayEntry? _overlay;

  String get maskedEmail {
    final parts = widget.email.split('@');
    if (parts[0].length <= 2) return widget.email;
    return '${parts[0].substring(0, 2)}**@${parts[1]}';
  }

  void _showTooltip(BuildContext context) {
    _overlay?.remove();

    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    _overlay = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: position.dy - 40,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              widget.email,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlay!);

    Future.delayed(const Duration(seconds: 2), () {
      _overlay?.remove();
      _overlay = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showTooltip(context),
      child: Text(maskedEmail, style: const TextStyle(color: Colors.white)),
    );
  }
}

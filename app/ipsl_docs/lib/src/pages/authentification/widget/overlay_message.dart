import 'package:flutter/material.dart';

void showTopOverlayMessage(context, String message) {
  final overlay = Overlay.of(context);
  final entry = OverlayEntry(
    builder:
        (_) => Positioned(
          top: MediaQuery.of(context).padding.top + 20,
          left: 20,
          right: 20,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                message,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
  );

  overlay.insert(entry);

  Future.delayed(Duration(seconds: 5)).then((_) => entry.remove());
}

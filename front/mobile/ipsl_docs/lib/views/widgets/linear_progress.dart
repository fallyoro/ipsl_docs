
import 'package:flutter/material.dart';

Row customLinearProgressSending(double progress) {
  return Row(
    children: [
      // Barre de progression
      Expanded(
        child: LinearProgressIndicator(
          value: progress,
          borderRadius: BorderRadius.circular(50),
          minHeight: 6,
          color: Colors.green,
          backgroundColor: Colors.grey.shade300,
        ),
      ),
      const SizedBox(width: 10),

      // Pourcentage
      Text(
        '${(progress * 100).toStringAsFixed(0)}%',
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    ],
  );
}
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MatchDialog extends StatelessWidget {
  final String mediaTitle;

  const MatchDialog({super.key, required this.mediaTitle});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.darkBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.neonRed, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppTheme.neonRed.withOpacity(0.5),
              blurRadius: 30,
              spreadRadius: 5,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'NOVO MATCH! 🎉',
              style: TextStyle(
                color: AppTheme.neonOrange,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(color: AppTheme.neonRed, blurRadius: 10),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Vocês dois querem assistir:',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              mediaTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CONTINUAR ARRASTANDO'),
            ),
          ],
        ),
      ),
    );
  }
}

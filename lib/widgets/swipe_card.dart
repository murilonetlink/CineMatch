import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/media.dart';
import '../constants.dart';
import '../theme/app_theme.dart';

class SwipeCard extends StatelessWidget {
  final Media media;
  final double swipeProgress; // negative = left (NOPE), positive = right (LIKE)

  const SwipeCard({super.key, required this.media, this.swipeProgress = 0});

  @override
  Widget build(BuildContext context) {
    final opacity = (swipeProgress.abs() / 100).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neonRed.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: '${Constants.tmdbImageBaseUrl}${media.posterPath}',
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: AppTheme.neonOrange)),
              errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.6, 1.0],
                ),
              ),
            ),
            // LIKE indicator (right swipe)
            if (swipeProgress > 0)
              Positioned(
                top: 40,
                left: 20,
                child: Opacity(
                  opacity: opacity,
                  child: Transform.rotate(
                    angle: -0.3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.greenAccent, width: 3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'LIKE',
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            // NOPE indicator (left swipe)
            if (swipeProgress < 0)
              Positioned(
                top: 40,
                right: 20,
                child: Opacity(
                  opacity: opacity,
                  child: Transform.rotate(
                    angle: 0.3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.neonRed, width: 3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'NOPE',
                        style: TextStyle(
                          color: AppTheme.neonRed,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    media.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(color: AppTheme.neonRed, blurRadius: 10),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    media.overview,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/match_model.dart';
import '../models/review.dart';
import '../providers/auth_provider.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';

class MatchDetailsScreen extends StatefulWidget {
  final MatchModel match;

  const MatchDetailsScreen({super.key, required this.match});

  @override
  State<MatchDetailsScreen> createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends State<MatchDetailsScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  
  List<Review> _reviews = [];
  bool _isLoadingReviews = true;
  bool _isWatched = false;
  
  final _commentController = TextEditingController();
  int _rating = 5;

  @override
  void initState() {
    super.initState();
    _isWatched = widget.match.watched;
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoadingReviews = true);
    final reviews = await _supabaseService.getReviews(widget.match.id);
    if (mounted) {
      setState(() {
        _reviews = reviews;
        _isLoadingReviews = false;
      });
    }
  }

  Future<void> _toggleWatched(bool? value) async {
    if (value == null) return;
    setState(() => _isWatched = value);
    await _supabaseService.markAsWatched(widget.match.id, value);
    widget.match.watched = value;
  }

  Future<void> _submitReview() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;
    if (user == null) return;

    if (_commentController.text.trim().isEmpty) return;

    await _supabaseService.addReview(
      widget.match.id,
      user.id,
      _rating,
      _commentController.text.trim(),
    );

    _commentController.clear();
    _loadReviews();
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.match.mediaDetails;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(media?.title ?? 'Detalhes', style: const TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (media?.posterPath != null)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    'https://image.tmdb.org/t/p/w300${media!.posterPath}',
                    height: 300,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              media?.title ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Já assistimos!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              value: _isWatched,
              onChanged: _toggleWatched,
              activeColor: AppTheme.neonOrange,
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(color: Colors.white24, height: 40),
            const Text(
              'Avaliações',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.neonRed),
            ),
            const SizedBox(height: 16),
            if (_isLoadingReviews)
              const Center(child: CircularProgressIndicator())
            else if (_reviews.isEmpty)
              const Text('Nenhuma avaliação ainda.', style: TextStyle(color: Colors.white70))
            else
              ..._reviews.map((r) => _buildReviewCard(r)),
            
            const SizedBox(height: 24),
            _buildReviewForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  review.userName,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.neonOrange),
                ),
                Row(
                  children: List.generate(5, (index) => Icon(
                    index < (review.rating ?? 0) ? Icons.star : Icons.star_border,
                    size: 16,
                    color: Colors.amber,
                  )),
                ),
              ],
            ),
            if (review.comment != null && review.comment!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(review.comment!, style: const TextStyle(color: Colors.white)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReviewForm() {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Deixe sua avaliação', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                  onPressed: () => setState(() => _rating = index + 1),
                );
              }),
            ),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: 'O que achou?',
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitReview,
                child: const Text('ENVIAR', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

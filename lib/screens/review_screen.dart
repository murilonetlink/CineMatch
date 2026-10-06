import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/match_model.dart';
import '../models/review.dart';
import '../providers/auth_provider.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants.dart';

class ReviewScreen extends StatefulWidget {
  final MatchModel matchModel;

  const ReviewScreen({super.key, required this.matchModel});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final _commentController = TextEditingController();
  int _rating = 0;
  bool _isWatched = false;
  List<Review> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _isWatched = widget.matchModel.watched;
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);
    final reviews = await _supabaseService.getReviews(widget.matchModel.id);
    
    // Se o usuário atual já fez review, popular os campos
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user != null) {
      try {
        final myReview = reviews.firstWhere((r) => r.userId == user.id);
        _rating = myReview.rating ?? 0;
        _commentController.text = myReview.comment ?? '';
      } catch (e) {
        // Não achou
      }
    }

    setState(() {
      _reviews = reviews;
      _isLoading = false;
    });
  }

  Future<void> _toggleWatched(bool? value) async {
    if (value == null) return;
    setState(() => _isWatched = value);
    await _supabaseService.markAsWatched(widget.matchModel.id, value);
  }

  Future<void> _saveReview() async {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user == null || _rating == 0) return;

    await _supabaseService.addReview(
      widget.matchModel.id,
      user.id,
      _rating,
      _commentController.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Avaliação salva!'), backgroundColor: AppTheme.neonRed),
    );
    
    _loadReviews();
  }

  Widget _buildStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            color: AppTheme.neonOrange,
            size: 32,
          ),
          onPressed: () {
            setState(() => _rating = index + 1);
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.matchModel.mediaDetails;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes', style: TextStyle(color: AppTheme.neonOrange)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.neonRed))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (media != null && media.posterPath.isNotEmpty)
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: CachedNetworkImage(
                          imageUrl: '${Constants.tmdbImageBaseUrl}${media.posterPath}',
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    media?.title ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Já assistimos!', style: TextStyle(fontSize: 18, color: AppTheme.neonOrange)),
                    value: _isWatched,
                    onChanged: _toggleWatched,
                    activeColor: AppTheme.neonRed,
                    checkColor: Colors.white,
                  ),
                  if (_isWatched) ...[
                    const Divider(color: Colors.grey, height: 32),
                    const Text('Sua Avaliação:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    _buildStars(),
                    TextField(
                      controller: _commentController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Deixe um comentário...',
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.neonOrange)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _saveReview,
                      child: const Text('SALVAR AVALIAÇÃO'),
                    ),
                    const SizedBox(height: 32),
                    const Text('Avaliações:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ..._reviews.map((r) => Card(
                          color: AppTheme.darkBackground,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: AppTheme.neonOrange.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(r.userName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.neonOrange)),
                                    Row(
                                      children: List.generate(
                                        5,
                                        (index) => Icon(
                                          index < (r.rating ?? 0) ? Icons.star : Icons.star_border,
                                          size: 16,
                                          color: AppTheme.neonOrange,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(r.comment ?? 'Sem comentário.'),
                              ],
                            ),
                          ),
                        )),
                  ],
                ],
              ),
            ),
    );
  }
}

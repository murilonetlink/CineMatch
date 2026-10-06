import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../services/supabase_service.dart';
import '../services/tmdb_service.dart';
import '../theme/app_theme.dart';
import 'match_details_screen.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final TmdbService _tmdbService = TmdbService();
  
  List<MatchModel> _matches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    setState(() => _isLoading = true);
    final matches = await _supabaseService.getMatches();
    
    // Fetch media details for each match
    for (var match in matches) {
      match.mediaDetails = await _tmdbService.getMediaDetails(match.mediaId, match.mediaType);
    }
    
    if (mounted) {
      setState(() {
        _matches = matches;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Matches',
          style: TextStyle(
            color: AppTheme.neonOrange,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.neonRed))
          : _matches.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum match ainda.\nContinue arrastando!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _matches.length,
                  itemBuilder: (context, index) {
                    final match = _matches[index];
                    final media = match.mediaDetails;
                    
                    return Card(
                      color: Theme.of(context).colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: media?.posterPath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  'https://image.tmdb.org/t/p/w200${media!.posterPath}',
                                  width: 60,
                                  height: 90,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                width: 60,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: Colors.grey[800],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.movie, color: Colors.white54),
                              ),
                        title: Text(
                          media?.title ?? 'Carregando...',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              Icon(
                                match.watched ? Icons.check_circle : Icons.radio_button_unchecked,
                                color: match.watched ? Colors.green : Colors.grey,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                match.watched ? 'Assistido' : 'Não assistido',
                                style: TextStyle(
                                  color: match.watched ? Colors.green : Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MatchDetailsScreen(match: match),
                            ),
                          ).then((_) => _loadMatches());
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:provider/provider.dart';
import '../models/media.dart';
import '../providers/auth_provider.dart';
import '../services/tmdb_service.dart';
import '../services/supabase_service.dart';
import '../widgets/swipe_card.dart';
import '../widgets/match_dialog.dart';
import '../theme/app_theme.dart';
import 'matches_screen.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  final TmdbService _tmdbService = TmdbService();
  final SupabaseService _supabaseService = SupabaseService();
  CardSwiperController _controller = CardSwiperController();

  final List<Media> _mediaList = [];
  bool _isLoading = true;
  String _currentType = 'movie'; // 'movie' or 'tv'
  int _currentPage = 1;
  Set<int> _swipedMediaIds = {};
  Key _swiperKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;
    if (user != null) {
      _swipedMediaIds = await _supabaseService.getSwipedMediaIds(user.id, _currentType);
    }
    await _loadMedia();
  }

  Future<void> _loadMedia() async {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user == null) return;

    if (mounted) setState(() => _isLoading = true);

    int addedCount = 0;
    while (addedCount < 5 && _currentPage <= 500) {
      List<Media> fetched;
      if (_currentType == 'movie') {
        fetched = await _tmdbService.getPopularMovies(page: _currentPage);
      } else {
        fetched = await _tmdbService.getPopularTvShows(page: _currentPage);
      }

      if (fetched.isEmpty) break;

      final unswiped = fetched.where((m) => !_swipedMediaIds.contains(m.id)).toList();
      _mediaList.addAll(unswiped);
      addedCount += unswiped.length;
      _currentPage++;
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _switchType() {
    _controller.dispose();
    setState(() {
      _currentType = _currentType == 'movie' ? 'tv' : 'movie';
      _mediaList.clear();
      _currentPage = 1;
      _isLoading = true;
      _controller = CardSwiperController();
      _swiperKey = UniqueKey();
    });
    _initData();
  }

  bool _onSwipe(int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    if (previousIndex < 0 || previousIndex >= _mediaList.length) return false;

    if (direction == CardSwiperDirection.right || direction == CardSwiperDirection.left) {
      final media = _mediaList[previousIndex];
      final liked = direction == CardSwiperDirection.right;
      _handleSwipeResult(media, liked);
      _swipedMediaIds.add(media.id);
    }

    if (currentIndex != null && currentIndex >= _mediaList.length - 3) {
      _loadMedia();
    }

    return true;
  }

  Future<void> _handleSwipeResult(Media media, bool liked) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;
    if (user == null) return;

    final isMatch = await _supabaseService.swipeMedia(user.id, media.id, media.type, liked);

    if (isMatch && mounted) {
      showDialog(
        context: context,
        builder: (_) => MatchDialog(mediaTitle: media.title),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cinematch',
          style: TextStyle(
            color: AppTheme.neonOrange,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: AppTheme.neonRed, blurRadius: 10)],
          ),
        ),
        leading: IconButton(
          icon: Icon(_currentType == 'movie' ? Icons.tv : Icons.movie),
          onPressed: _switchType,
          tooltip: _currentType == 'movie' ? 'Mudar para Séries' : 'Mudar para Filmes',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MatchesScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => auth.logout(),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _mediaList.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.neonRed));
    }

    if (_mediaList.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum conteúdo novo encontrado.\nTente trocar de categoria!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    final displayCount = _mediaList.length < 3 ? _mediaList.length : 3;

    return Column(
      children: [
        Expanded(
          child: CardSwiper(
            key: _swiperKey,
            controller: _controller,
            cardsCount: _mediaList.length,
            onSwipe: _onSwipe,
            numberOfCardsDisplayed: displayCount,
            backCardOffset: const Offset(0, 40),
            cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
              if (index < 0 || index >= _mediaList.length) {
                return const SizedBox.shrink();
              }
              return SwipeCard(
                media: _mediaList[index],
                swipeProgress: percentThresholdX.toDouble(),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                heroTag: 'dislike',
                backgroundColor: Colors.white,
                onPressed: () => _controller.swipe(CardSwiperDirection.left),
                child: const Icon(Icons.close, color: Colors.red, size: 30),
              ),
              FloatingActionButton(
                heroTag: 'like',
                backgroundColor: Colors.white,
                onPressed: () => _controller.swipe(CardSwiperDirection.right),
                child: const Icon(Icons.favorite, color: Colors.green, size: 30),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

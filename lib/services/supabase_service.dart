import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart';
import '../models/match_model.dart';
import '../models/review.dart';

class SupabaseService {
  final _supabase = Supabase.instance.client;

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<AppUser?> login(String name, String password) async {
    try {
      final hash = _hashPassword(password);
      final response = await _supabase
          .from('users')
          .select()
          .eq('name', name)
          .eq('password_hash', hash)
          .maybeSingle();
      
      if (response != null) {
        return AppUser.fromMap(response);
      }
      return null;
    } catch (e) {
      debugPrint('Erro no login: $e');
      return null;
    }
  }

  Future<({bool success, String? error})> register(String name, String password) async {
    try {
      // Check if user already exists first
      final existing = await _supabase
          .from('users')
          .select('id')
          .eq('name', name)
          .maybeSingle();
      
      if (existing != null) {
        return (success: false, error: 'Nome de usuário já está em uso.');
      }

      final hash = _hashPassword(password);
      await _supabase.from('users').insert({
        'name': name,
        'password_hash': hash,
      });
      return (success: true, error: null);
    } catch (e) {
      debugPrint('Erro no cadastro: $e');
      return (success: false, error: 'Erro de conexão. Verifique sua internet.');
    }
  }

  Future<Set<int>> getSwipedMediaIds(String userId, String mediaType) async {
    try {
      final response = await _supabase
          .from('swipes')
          .select('media_id')
          .eq('user_id', userId)
          .eq('media_type', mediaType);
      
      return response.map<int>((row) => row['media_id'] as int).toSet();
    } catch (e) {
      return {};
    }
  }

  Future<bool> swipeMedia(String userId, int mediaId, String mediaType, bool liked) async {
    try {
      await _supabase.from('swipes').insert({
        'user_id': userId,
        'media_id': mediaId,
        'media_type': mediaType,
        'liked': liked,
      });

      if (liked) {
        return await _checkForMatch(userId, mediaId, mediaType);
      }
      return false;
    } catch (e) {
      // Swipe already exists
      return false;
    }
  }

  Future<bool> _checkForMatch(String currentUserId, int mediaId, String mediaType) async {
    // Check if another user liked the same media
    final response = await _supabase
        .from('swipes')
        .select()
        .eq('media_id', mediaId)
        .eq('media_type', mediaType)
        .eq('liked', true)
        .neq('user_id', currentUserId)
        .maybeSingle();

    if (response != null) {
      // It's a match! Insert into matches table
      try {
        await _supabase.from('matches').insert({
          'media_id': mediaId,
          'media_type': mediaType,
        });
        return true;
      } catch (e) {
        // Match already exists
        return true;
      }
    }
    return false;
  }

  Future<List<MatchModel>> getMatches() async {
    try {
      final response = await _supabase
          .from('matches')
          .select()
          .order('created_at', ascending: false);
          
      return response.map<MatchModel>((map) => MatchModel.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> markAsWatched(String matchId, bool watched) async {
    await _supabase
        .from('matches')
        .update({'watched': watched})
        .eq('id', matchId);
  }

  Future<List<Review>> getReviews(String matchId) async {
    try {
      final response = await _supabase
          .from('reviews')
          .select('*, users!inner(name)')
          .eq('match_id', matchId)
          .order('created_at', ascending: false);
          
      return response.map<Review>((map) => Review.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addReview(String matchId, String userId, int rating, String comment) async {
    await _supabase.from('reviews').upsert({
      'match_id': matchId,
      'user_id': userId,
      'rating': rating,
      'comment': comment,
    }, onConflict: 'match_id, user_id');
  }
}

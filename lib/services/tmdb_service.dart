import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/media.dart';

class TmdbService {
  Future<List<Media>> getPopularMovies({int page = 1}) async {
    final url = Uri.parse(
        '${Constants.tmdbBaseUrl}/movie/popular?api_key=${Constants.tmdbApiKey}&language=pt-BR&page=$page');
    return _fetchMedia(url, 'movie');
  }

  Future<List<Media>> getPopularTvShows({int page = 1}) async {
    final url = Uri.parse(
        '${Constants.tmdbBaseUrl}/tv/popular?api_key=${Constants.tmdbApiKey}&language=pt-BR&page=$page');
    return _fetchMedia(url, 'tv');
  }

  Future<List<Media>> _fetchMedia(Uri url, String type) async {
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        return results
            .where((json) => json['poster_path'] != null) // only items with poster
            .map((json) => Media.fromTmdb(json, type))
            .toList();
      } else {
        throw Exception('Failed to load $type');
      }
    } catch (e) {
      return [];
    }
  }

  Future<Media?> getMediaDetails(int id, String type) async {
    final url = Uri.parse(
        '${Constants.tmdbBaseUrl}/$type/$id?api_key=${Constants.tmdbApiKey}&language=pt-BR');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Media.fromTmdb(data, type);
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}

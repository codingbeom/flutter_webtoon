import 'dart:convert';

import 'package:flutter_webtoon/models/detail.dart';
import 'package:flutter_webtoon/models/episode.dart';
import 'package:flutter_webtoon/models/webtoon.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'https://webtoon-crawler.nomadcoders.workers.dev';

  static Future<List<WebtoonModel>> getTodayToons() async {
    List<WebtoonModel> webtoonInstance = [];
    final Uri url = Uri.parse('$baseUrl/today');
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final List<dynamic> webtoons = jsonDecode(res.body);
      for (var webtoon in webtoons) {
        webtoonInstance.add(WebtoonModel.fromJson(webtoon));
      }
      return webtoonInstance;
    } else {
      throw Error();
    }
  }

  static Future<WebtoonDetailModel> getToonById(String id) async {
    final url = Uri.parse('$baseUrl/$id');
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final webtoon = jsonDecode(res.body);
      return WebtoonDetailModel.fromJson(webtoon);
    } else {
      throw Error();
    }
  }

  static Future<List<EpisodeModel>> getEpisode(String id) async {
    List<EpisodeModel> episodeInstance = [];

    final url = Uri.parse('$baseUrl/$id/episodes');
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final episodes = jsonDecode(res.body);
      for (var epi in episodes) {
        episodeInstance.add(EpisodeModel.fromJson(epi));
      }
      return episodeInstance;
    } else {
      throw Error();
    }
  }
}

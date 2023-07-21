import 'package:flutter/material.dart';
import 'package:flutter_webtoon/models/detail.dart';
import 'package:flutter_webtoon/models/episode.dart';
import 'package:flutter_webtoon/services/api_service.dart';
import 'package:flutter_webtoon/widgets/webtoon_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DetailScreen extends StatefulWidget {
  final String title, thumb, id;

  const DetailScreen({
    super.key,
    required this.title,
    required this.thumb,
    required this.id,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<WebtoonDetailModel> webtoon;
  late Future<List<EpisodeModel>> episodes;
  late SharedPreferences pref;
  bool isLike = false;

  Future initPrefs() async {
    pref = await SharedPreferences.getInstance();
    final likedToons = pref.getStringList('likedToons');
    if (likedToons != null) {
      if (likedToons.contains(widget.id) == true) {
        setState(() {
          isLike = true;
        });
      }
    } else {
      await pref.setStringList('likedToons', []);
    }
  }

  onFavorite() async {
    final likedToons = pref.getStringList('likedToons');
    if (likedToons != null) {
      if (isLike) {
        likedToons.remove(widget.id);
      } else {
        likedToons.add(widget.id);
      }
      await pref.setStringList('likedToons', likedToons);
      setState(() {
        isLike = !isLike;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    webtoon = ApiService.getToonById(widget.id);
    episodes = ApiService.getEpisode(widget.id);
    initPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.green.shade400,
        elevation: 2,
        actions: [
          IconButton(
            onPressed: () => onFavorite(),
            icon: Icon(
              isLike ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
            ),
          )
        ],
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: widget.id,
                    child: Container(
                      width: 200,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 7,
                                offset: const Offset(4, 4),
                                color: Colors.black.withOpacity(0.6))
                          ]),
                      child: makeImage(widget.thumb),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              FutureBuilder(
                future: webtoon,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          snapshot.data!.about,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          '${snapshot.data!.age} / ${snapshot.data!.genre}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    );
                  } else {
                    return const Text('...');
                  }
                },
              ),
              const SizedBox(
                height: 20,
              ),
              FutureBuilder(
                future: episodes,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.hasData) {
                      return Column(
                        children: [
                          for (var epi in snapshot.data!)
                            EpisodeWidget(epi: epi, webtoonId: widget.id)
                        ],
                      );
                    }
                  }
                  return Container(
                    height: 20,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EpisodeWidget extends StatelessWidget {
  final EpisodeModel epi;
  final String webtoonId;

  const EpisodeWidget({super.key, required this.epi, required this.webtoonId});

  onButtonTap() async {
    await launchUrlString(
        "https://comic.naver.com/webtoon/detail?titleId=$webtoonId&no=${epi.id}");
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onButtonTap(),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                blurStyle: BlurStyle.outer,
                blurRadius: 5,
                offset: const Offset(1, 1),
                color: Colors.green.withOpacity(0.4))
          ],
          border: Border.all(
            color: Colors.green.shade400,
          ),
          borderRadius: BorderRadius.circular(25),
          // color: Colors.green.shade400,
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                epi.title,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green.shade600,
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.green.shade600,
              )
            ],
          ),
        ),
      ),
    );
  }
}

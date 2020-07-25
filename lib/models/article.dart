import 'dart:convert';

class Article {
  final int id;
  final String type;
  final String by;
  final int time;
  final String url;
  final int score;
  final String title;
  final int descendants;

  const Article({
    this.id,
    this.type,
    this.by,
    this.time,
    this.url,
    this.score,
    this.title,
    this.descendants,
  });

  factory Article.fromJson(Map<String, dynamic> data) => Article(
        id: data['id'],
        type: data['type'] ?? 'null',
        by: data['by'] ?? 'null',
        time: data['time'] ?? DateTime.now().millisecondsSinceEpoch / 1000,
        url: data['url'] ?? 'null',
        score: data['score'] ?? 0,
        title: data['title'] ?? 'null',
        descendants: data['descendants'] ?? 0,
      );
}

List<int> parseStories(String json) {
  final parsed = jsonDecode(json);
  final ids = List<int>.from(parsed);
  return ids;
}

Article parseArticle(String json) {
  final parsed = jsonDecode(json);
  final article = Article.fromJson(parsed);
  return article;
}

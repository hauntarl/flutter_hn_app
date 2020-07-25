import 'package:flutter/material.dart';

import '../models/article.dart';
import './custom_tile.dart';

class ListBuilder extends StatelessWidget {
  final List<Article> articles;
  final int index;

  ListBuilder(this.articles, this.index);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: PageStorageKey<int>(index),
      physics: BouncingScrollPhysics(),
      itemCount: articles.length,
      itemBuilder: (_, index) => _buildItem(articles[index]),
    );
  }

  Widget _buildItem(Article article) {
    if (article == null) return CustomTile();
    final time = DateTime.fromMillisecondsSinceEpoch(article.time * 1000);
    final diff = DateTime.now().difference(time);
    return CustomTile(
      articleId: article.id,
      articleTitle: article.title,
      articleBy: article.by,
      articleTime: diff,
      articleComments: article.descendants,
      articleScore: article.score,
      articleUrl: article.url,
    );
  }
}

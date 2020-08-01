import 'package:flutter/material.dart';

import '../models/article.dart';
import '../utils/colors.dart';
import '../bloc/hn_bloc.dart';
import './list_builder.dart';

class ArticleSearch extends SearchDelegate<Article> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        padding: EdgeInsets.symmetric(horizontal: 23.0),
        icon: Icon(
          Icons.clear_all,
          color: HNColors.primaryColor1,
          size: 30.0,
        ),
        onPressed: () => query = '',
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios,
        color: HNColors.primaryColor1,
      ),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _itemList();

  @override
  Widget buildSuggestions(BuildContext context) => _itemList();

  Widget _itemList() {
    return Builder(
      builder: (_) {
        if (query.isEmpty) return _default('type something...');

        final suggestions = hnBloc.getArticlesFromCache
            .where((e) => e.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
        return suggestions.isEmpty
            ? _default('Couldn\'t find anything :(')
            : ListBuilder(suggestions, 3);
      },
    );
  }

  Widget _default(String text) => Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 25.0,
            color: HNColors.primaryColor2,
          ),
        ),
      );
}

import 'dart:collection';

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
          color: CustomColors.primaryColor1,
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
        color: CustomColors.primaryColor1,
      ),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _itemList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _itemList();
  }

  Widget _itemList() => Builder(builder: (_) {
        if (query.isEmpty)
          return Center(
            child: Text(
              'Search something...',
              style: TextStyle(
                fontSize: 25.0,
                color: CustomColors.primaryColor2,
              ),
            ),
          );

        final suggestions = hnBloc.getArticlesFromCache
            .where((e) => e.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
        if (suggestions.isEmpty)
          return Center(
            child: Text(
              'Couldn\'t find anything :(',
              style: TextStyle(
                fontSize: 25.0,
                color: CustomColors.primaryColor2,
              ),
            ),
          );
        return ListBuilder(UnmodifiableListView(suggestions));
      });
}

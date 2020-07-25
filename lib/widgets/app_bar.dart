import 'package:flutter/material.dart';

import './article_search.dart';

PreferredSizeWidget buildAppBar({
  BuildContext context,
  String title,
}) =>
    AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.normal,
          letterSpacing: 1.5,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          padding: EdgeInsets.symmetric(horizontal: 23.0),
          icon: Icon(Icons.search),
          onPressed: () => showSearch(
            context: context,
            delegate: ArticleSearch(),
          ),
        ),
      ],
    );

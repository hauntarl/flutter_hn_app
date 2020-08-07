import 'package:flutter/material.dart';

import './article_search.dart';
import './low_data_icon.dart';

PreferredSizeWidget buildAppBar({BuildContext context, String title}) {
  return AppBar(
    title: Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.normal,
        letterSpacing: 1.5,
      ),
    ),
    centerTitle: true,
    leading: LowDataIcon(),
    actions: [
      IconButton(
        padding: EdgeInsets.symmetric(horizontal: 25.0),
        icon: Icon(Icons.search),
        onPressed: () => showSearch(
          context: context,
          delegate: ArticleSearch(),
        ),
      ),
    ],
  );
}

import 'package:flutter/material.dart';
import 'package:hn_app/bloc/pref_bloc.dart';
import 'package:hn_app/models/article.dart';

import './utils/colors.dart';
import './bloc/hn_bloc.dart';
import './widgets/app_bar.dart';
import './widgets/hn_loading.dart';
import './widgets/list_builder.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.dark().copyWith(
        primaryColor: HNColors.primaryColor1,
        accentColor: HNColors.primaryColor1,
        scaffoldBackgroundColor: HNColors.primaryColor1,
        canvasColor: HNColors.primaryColor2,
        cursorColor: HNColors.primaryColor1,
      ),
      home: FutureBuilder(
        future: initSharedPreferences(),
        builder: (_, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? HNLoading()
                : MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _curr = 0;

  static final _story = {
    0: [StoryTypes.TOP, hnBloc.topArticles],
    1: [StoryTypes.BEST, hnBloc.bestArticles],
    2: [StoryTypes.NEW, hnBloc.newArticles],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context: context, title: 'Hacker News'),
      body: RefreshIndicator(
        onRefresh: () async => await hnBloc.refreshArticles(_story[_curr][0]),
        child: _streamBuilder,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        selectedItemColor: HNColors.primaryColor1,
        unselectedItemColor: HNColors.primaryColor1.withAlpha(128),
        items: [
          _bottomNavigationBaritem(Icons.trending_up, 'Top'),
          _bottomNavigationBaritem(Icons.whatshot, 'Best'),
          _bottomNavigationBaritem(Icons.new_releases, 'New'),
        ],
        currentIndex: _curr,
        onTap: (index) {
          if (index == _curr) return;
          hnBloc.storyType.add(_story[_curr][0]);
          setState(() => _curr = index);
        },
      ),
    );
  }

  Widget get _streamBuilder {
    return StreamBuilder<List<Article>>(
      stream: _story[_curr][1],
      initialData: [],
      builder: (_, snapshot) => snapshot.data.isEmpty
          ? HNLoading()
          : ListBuilder(snapshot.data, _curr),
    );
  }

  BottomNavigationBarItem _bottomNavigationBaritem(
    IconData icon,
    String title,
  ) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      title: Text(title),
      backgroundColor: HNColors.primaryColor2,
    );
  }

  @override
  void dispose() {
    hnBloc.dispose();
    prefBloc.dispose();
    super.dispose();
  }
}

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
  var _currentIndex = 0;

  static StoryTypes getStoryType(int index) {
    switch (index) {
      case 0:
        return StoryTypes.TOP;
      case 1:
        return StoryTypes.BEST;
      case 2:
        return StoryTypes.NEW;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final storyType = getStoryType(_currentIndex);
    return Scaffold(
      appBar: buildAppBar(context: context, title: 'Hacker News'),
      body: RefreshIndicator(
        onRefresh: () async => await hnBloc.refreshArticles(storyType),
        child: Builder(
          builder: (_) {
            switch (_currentIndex) {
              case 0:
                return _streamBuilder(hnBloc.topArticles);
              case 1:
                return _streamBuilder(hnBloc.bestArticles);
              case 2:
                return _streamBuilder(hnBloc.newArticles);
              default:
                return Container();
            }
          },
        ),
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
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return;
          hnBloc.storyType.add(getStoryType(index));
          setState(() => _currentIndex = index);
        },
      ),
    );
  }

  StreamBuilder<List<Article>> _streamBuilder(Stream<List<Article>> stream) {
    return StreamBuilder<List<Article>>(
      stream: stream,
      initialData: [],
      builder: (_, snapshot) => snapshot.data.isEmpty
          ? HNLoading()
          : ListBuilder(snapshot.data, _currentIndex),
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

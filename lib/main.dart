import 'package:flutter/material.dart';

import './utils/colors.dart';
import './models/article.dart';
import './bloc/hn_bloc.dart';
import './widgets/hn_loading.dart';
import './widgets/custom_tile.dart';

void main() {
  final hnBloc = HackerNewsBloc();
  runApp(MyApp(hnBloc));
}

class MyApp extends StatelessWidget {
  final HackerNewsBloc hnbloc;

  MyApp(this.hnbloc);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: CustomColors.primaryColor,
        accentColor: CustomColors.primaryColor,
        scaffoldBackgroundColor: CustomColors.primaryColor,
        canvasColor: CustomColors.primaryBlack,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(
        title: 'Hacker News',
        hnBloc: hnbloc,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.hnBloc}) : super(key: key);

  final String title;
  final HackerNewsBloc hnBloc;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _currentIndex = 0;

  @override
  void dispose() {
    widget.hnBloc.close();
    super.dispose();
  }

  StoriesType getStoryType(int index) {
    switch (index) {
      case 0:
        return StoriesType.TOP;
      case 1:
        return StoriesType.BEST;
      case 2:
        return StoriesType.NEW;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(
            fontWeight: FontWeight.normal,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await widget.hnBloc.refreshArticles(getStoryType(_currentIndex));
        },
        child: StreamBuilder<bool>(
          stream: widget.hnBloc.isLoading,
          initialData: true,
          builder: (_, snapshot) {
            if (snapshot.data) return HNLoading();
            final articles =
                widget.hnBloc.getArticles(getStoryType(_currentIndex));
            if (articles.isEmpty) return HNLoading();
            return ListView.builder(
              key: ValueKey<int>(_currentIndex),
              physics: BouncingScrollPhysics(),
              itemCount: articles.length,
              itemBuilder: (_, index) => _buildItem(articles[index]),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        selectedItemColor: CustomColors.primaryColor,
        unselectedItemColor: CustomColors.primaryColor.withAlpha(128),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            title: Text('Top'),
            backgroundColor: CustomColors.primaryBlack,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.whatshot),
            title: Text('Best'),
            backgroundColor: CustomColors.primaryBlack,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.new_releases),
            title: Text('New'),
            backgroundColor: CustomColors.primaryBlack,
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return;
          widget.hnBloc.storiesType.add(getStoryType(index));
          setState(() {
            _currentIndex = index;
          });
        },
      ),
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

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import './models/article.dart';
import './bloc/hn_bloc.dart';
import './widgets/hn_loading.dart';

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
        primarySwatch: Colors.blue,
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
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.black45,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            title: Text('Top'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.whatshot),
            title: Text('Best'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.new_releases),
            title: Text('New'),
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

  String displayTime(Duration duration) {
    if (duration.inDays > 0)
      return '${duration.inDays} day(s)';
    else if (duration.inHours > 0)
      return '${duration.inHours} hour(s)';
    else if (duration.inMinutes > 0)
      return '${duration.inMinutes} minute(s)';
    else
      return '${duration.inSeconds} second(s)';
  }

  Widget _buildItem(Article article) {
    final time = DateTime.fromMillisecondsSinceEpoch(article.time * 1000);
    final diff = DateTime.now().difference(time);

    return Padding(
      padding: EdgeInsets.all(8.0),
      child: ExpansionTile(
        key: ValueKey<int>(article.id),
        title: Text(
          article.title,
          style: TextStyle(
            fontSize: 16.0,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 10.0),
            Text(article.by),
            SizedBox(height: 5.0),
            Text('${article.descendants} comment(s)'),
          ],
        ),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('${displayTime(diff)} ago      score: ${article.score}'),
                IconButton(
                  icon: Icon(
                    Icons.launch,
                    color: Colors.grey.shade700,
                  ),
                  onPressed: () async {
                    if (await canLaunch(article.url)) await launch(article.url);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import './utils/colors.dart';
import './bloc/hn_bloc.dart';
import 'widgets/app_bar.dart';
import './widgets/hn_loading.dart';
import './widgets/list_builder.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: CustomColors.primaryColor1,
        accentColor: CustomColors.primaryColor1,
        scaffoldBackgroundColor: CustomColors.primaryColor1,
        canvasColor: CustomColors.primaryColor2,
        cursorColor: CustomColors.primaryColor1,
      ),
      home: MyHomePage('Hacker News'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage(this.title);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _currentIndex = 0;

  @override
  void dispose() {
    hnBloc.close();
    super.dispose();
  }

  StoryTypes getStoryType(int index) {
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
    return Scaffold(
      appBar: buildAppBar(
        context: context,
        title: widget.title,
      ),
      body: RefreshIndicator(
        onRefresh: () async =>
            await hnBloc.refreshArticles(getStoryType(_currentIndex)),
        child: StreamBuilder<bool>(
          stream: hnBloc.isLoading,
          initialData: true,
          builder: (_, snapshot) {
            if (snapshot.data) return HNLoading();
            final articles = hnBloc.getArticles(getStoryType(_currentIndex));
            if (articles.isEmpty) return HNLoading();
            return ListBuilder(articles);
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        selectedItemColor: CustomColors.primaryColor1,
        unselectedItemColor: CustomColors.primaryColor1.withAlpha(128),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            title: Text('Top'),
            backgroundColor: CustomColors.primaryColor2,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.whatshot),
            title: Text('Best'),
            backgroundColor: CustomColors.primaryColor2,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.new_releases),
            title: Text('New'),
            backgroundColor: CustomColors.primaryColor2,
          ),
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
}

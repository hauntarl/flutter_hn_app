import 'dart:async';
import 'dart:collection';

import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

import '../models/article.dart';

enum StoryTypes {
  TOP,
  NEW,
  BEST,
}

class HackerNewsBloc {
  static const _baseUrl = 'https://hacker-news.firebaseio.com/v0/';
  static const _storyPath = {
    StoryTypes.TOP: 'topstories',
    StoryTypes.BEST: 'beststories',
    StoryTypes.NEW: 'newstories',
  };
  static final Map<StoryTypes, List<int>> _articleIds = {
    StoryTypes.TOP: [],
    StoryTypes.BEST: [],
    StoryTypes.NEW: [],
  };
  static final _articleCache = HashMap<int, Article>();

  final _storyController = StreamController<StoryTypes>();
  final _isLoadingSubject = BehaviorSubject<bool>();

  Sink<StoryTypes> get storyType => _storyController.sink;
  Stream<bool> get isLoading => _isLoadingSubject;

  HackerNewsBloc() {
    _fetchArticles(StoryTypes.TOP);
    _storyController.stream.listen((type) => _fetchArticles(type));
  }

  UnmodifiableListView<Article> getArticles(StoryTypes type) =>
      UnmodifiableListView<Article>(
          _articleIds[type].map((e) => _articleCache[e]).toList());

  UnmodifiableListView<Article> get getArticlesFromCache =>
      UnmodifiableListView(_articleCache.values.toList());

  void _fetchArticles(StoryTypes type) async {
    _isLoadingSubject.add(true);
    if (_articleIds[type].isEmpty)
      refreshArticles(type);
    else
      _isLoadingSubject.add(false);
  }

  Future<void> refreshArticles(StoryTypes type) async {
    final ids = await _getArticleIds(type);
    if (ids != null) {
      _articleIds[type] = ids.take(10).toList();
      await _getArticles(_articleIds[type]);
    }
    _isLoadingSubject.add(false);
  }

  Future<List<int>> _getArticleIds(StoryTypes type) async {
    final response = await http.get('$_baseUrl/${_storyPath[type]}.json');
    if (response.statusCode / 100 == 2) return parseStories(response.body);
    return null;
  }

  Future<void> _getArticles(List<int> articleIds) async =>
      await Future.wait(articleIds.map((e) => _getArticleFromId(e)));

  Future<void> _getArticleFromId(int articleId) async {
    try {
      if (_articleCache.containsKey(articleId)) return;
      final response = await http.get('$_baseUrl/item/$articleId.json');
      if (response.statusCode / 100 == 2)
        _articleCache[articleId] = parseArticle(response.body);
    } catch (e) {
      print(e.toString());
    }
  }

  void close() {
    _storyController.close();
    _isLoadingSubject.close();
  }
}

final hnBloc = HackerNewsBloc();

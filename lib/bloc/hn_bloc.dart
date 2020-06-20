import 'dart:async';
import 'dart:collection';

import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

import '../models/article.dart';

enum StoriesType {
  TOP,
  NEW,
  BEST,
}

class HackerNewsBloc {
  static const _baseUrl = 'https://hacker-news.firebaseio.com/v0/';
  static const _stories = {
    StoriesType.TOP: 'topstories',
    StoriesType.BEST: 'beststories',
    StoriesType.NEW: 'newstories',
  };
  static final Map<StoriesType, List<int>> _articleIds = {
    StoriesType.TOP: [],
    StoriesType.BEST: [],
    StoriesType.NEW: [],
  };
  static final _articleCache = HashMap<int, Article>();

  final _storiesTypeController = StreamController<StoriesType>();
  final _isLoadingSubject = BehaviorSubject<bool>();

  Sink<StoriesType> get storiesType => _storiesTypeController.sink;
  Stream<bool> get isLoading => _isLoadingSubject;

  HackerNewsBloc() {
    _fetchArticles(StoriesType.TOP);
    _storiesTypeController.stream.listen((type) => _fetchArticles(type));
  }

  UnmodifiableListView<Article> getArticles(StoriesType type) {
    final ids = _articleIds[type];
    return UnmodifiableListView<Article>(
        ids.map((e) => _articleCache[e]).toList());
  }

  void _fetchArticles(StoriesType type) async {
    _isLoadingSubject.add(true);
    if (_articleIds[type].isEmpty)
      refreshArticles(type);
    else
      _isLoadingSubject.add(false);
  }

  Future<void> refreshArticles(StoriesType type) async {
    final ids = await _getArticleIds(type);
    if (ids != null) {
      _articleIds[type] = ids.take(10).toList();
      await _getArticles(_articleIds[type]);
    }
    _isLoadingSubject.add(false);
  }

  Future<List<int>> _getArticleIds(StoriesType type) async {
    final response = await http.get('$_baseUrl/${_stories[type]}.json');
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
    _storiesTypeController.close();
    _isLoadingSubject.close();
  }
}

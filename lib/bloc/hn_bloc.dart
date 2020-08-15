import 'dart:async';
import 'dart:collection';

import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

import '../models/article.dart';

// sort hacker news article by story types
enum StoryTypes {
  TOP,
  NEW,
  BEST,
}

// article state management using bloc pattern
class HackerNewsBloc {
  // base url of hacker new data source
  static const _baseUrl = 'https://hacker-news.firebaseio.com/v0/';
  // extensions to the base url for different stories
  static const _storyPath = {
    StoryTypes.TOP: 'topstories',
    StoryTypes.BEST: 'beststories',
    StoryTypes.NEW: 'newstories',
  };

  // map to hold article ids for each story type
  static final Map<StoryTypes, List<int>> _articleIds = {
    StoryTypes.TOP: [],
    StoryTypes.BEST: [],
    StoryTypes.NEW: [],
  };

  // map holds all the articles fetched from the data source
  static final _articleCache = HashMap<int, Article>();

  // _storyController takes story type as input from the user
  final _storyController = StreamController<StoryTypes>();
  // following returns articles based on given story type
  final _topArticleSubject = BehaviorSubject<List<Article>>();
  final _bestArticleSubject = BehaviorSubject<List<Article>>();
  final _newArticleSubject = BehaviorSubject<List<Article>>();

  // map to store article subjects with its repective story type
  final Map<StoryTypes, BehaviorSubject<List<Article>>> _articleSubjects = {};

  // allows user to input story type
  Sink<StoryTypes> get storyType => _storyController.sink;
  // allows user to listen to the articles returned for each story
  Stream<List<Article>> get topArticles => _topArticleSubject;
  Stream<List<Article>> get bestArticles => _bestArticleSubject;
  Stream<List<Article>> get newArticles => _newArticleSubject;

  HackerNewsBloc() {
    // populating the article subject map
    _articleSubjects[StoryTypes.TOP] = _topArticleSubject;
    _articleSubjects[StoryTypes.BEST] = _bestArticleSubject;
    _articleSubjects[StoryTypes.NEW] = _newArticleSubject;

    // fetching the default story upon bloc initialization
    _fetchArticles(StoryTypes.TOP);

    // listening to the user input
    _storyController.stream.listen(_fetchArticles);
  }

  // returns all the articles fetched and cached from the data source
  UnmodifiableListView<Article> get getArticlesFromCache =>
      UnmodifiableListView(_articleCache.values.toList());

  // fetches article only if article ids for particular story are not cached
  void _fetchArticles(StoryTypes type) {
    if (_articleIds[type].isNotEmpty) return;
    _articleSubjects[type].add([]);
    refreshArticles(type);
  }

  // fetches articles from the data source
  Future<void> refreshArticles(StoryTypes type) async {
    // fetch article ids for given story type
    final ids = await _getArticleIds(type);
    if (ids == null) return;

    // restricting ids to only 10 of each story type
    _articleIds[type] = ids.take(10).toList();
    // fetching articles from ids and caching them
    await _getArticles(_articleIds[type]);
    // mapping each article id to article present in cached articles then
    // adding the list to respective article subject of given story type
    _articleSubjects[type]
        .add(_articleIds[type].map((id) => _articleCache[id]).toList());
  }

  // fetch article ids from data source using the mapped extension to type
  Future<List<int>> _getArticleIds(StoryTypes type) async {
    final response = await http.get('$_baseUrl/${_storyPath[type]}.json');
    if (response.statusCode / 100 == 2) return parseStories(response.body);
    return null;
  }

  // fetch all articles using the given list of article ids
  Future<void> _getArticles(List<int> articleIds) async =>
      await Future.wait(articleIds.map((e) => _getArticleFromId(e)));

  // fetch individual article from data source using the given id
  Future<void> _getArticleFromId(int articleId) async {
    try {
      // if article is already caches, no need to make the network call
      if (_articleCache.containsKey(articleId)) return;

      // else fetch data
      final response = await http.get('$_baseUrl/item/$articleId.json');
      // if response status code alright then cache the article
      if (response.statusCode / 100 == 2)
        _articleCache[articleId] = parseArticle(response.body);
    } catch (e) {
      print(e.toString());
    }
  }

  void dispose() {
    _storyController.close();
    _topArticleSubject.close();
    _bestArticleSubject.close();
    _newArticleSubject.close();
  }
}

// initializing the bloc globally so that it can be accessed from anywhere
final hnBloc = HackerNewsBloc();

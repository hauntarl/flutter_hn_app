import 'dart:async';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rxdart/rxdart.dart';

class PrefBloc {
  final _currentPref = BehaviorSubject<bool>();
  final _showWebViewPref = StreamController<bool>();

  Stream<bool> get currentPref => _currentPref.stream;
  Sink<bool> get showWebViewPref => _showWebViewPref.sink;

  PrefBloc() {
    _showWebViewPref.stream.listen((val) {
      _saveNewPref(val);
    });
  }

  Future<void> loadSharedPreferences() async {
    final box = await Hive.openBox('hn_prefs');
    final showWebView = box.get('show_web_view', defaultValue: true);
    _currentPref.add(showWebView);
  }

  Future<void> _saveNewPref(bool showWebView) async {
    final box = await Hive.openBox('hn_prefs');
    await box.put('show_web_view', showWebView);
    _currentPref.add(showWebView);
  }

  void dispose() {
    _currentPref.close();
    _showWebViewPref.close();
  }
}

Future<void> initSharedPreferences() async {
  await Hive.initFlutter();
  prefBloc = PrefBloc();
  await prefBloc.loadSharedPreferences();
}

PrefBloc prefBloc;

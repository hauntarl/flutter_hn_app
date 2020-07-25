import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../utils/colors.dart';

class CustomTile extends StatelessWidget {
  const CustomTile({
    this.articleId = 0,
    this.articleTitle = 'loading',
    this.articleBy = 'loading',
    this.articleTime,
    this.articleComments = 0,
    this.articleScore = 0,
    this.articleUrl,
  });

  final int articleId;
  final String articleTitle;
  final String articleBy;
  final Duration articleTime;
  final int articleComments;
  final int articleScore;
  final String articleUrl;

  final background = HNColors.primaryColor1;
  final textColor = HNColors.primaryColor2;

  static String displayTime(Duration duration) {
    if (duration == null)
      return 'loading';
    else if (duration.inDays > 0)
      return duration.inDays == 1 ? 'yesterday' : '${duration.inDays} days ago';
    else if (duration.inHours > 0)
      return duration.inHours == 1
          ? 'an hour ago'
          : '${duration.inHours} hours ago';
    else
      return duration.inMinutes <= 1
          ? 'now'
          : '${duration.inMinutes} minutes ago';
  }

  @override
  Widget build(BuildContext context) {
    final key = PageStorageKey<int>(articleId);
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: ExpansionTile(
        key: key,
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: textColor,
        ),
        backgroundColor: background,
        title: Text(
          articleTitle,
          style: TextStyle(
            color: textColor,
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 10.0),
            Text(
              '$articleBy  •  ${displayTime(articleTime)}',
              style: TextStyle(
                fontSize: 16.0,
                color: textColor,
              ),
            ),
          ],
        ),
        children: <Widget>[
          Container(
            height: 350,
            padding: EdgeInsets.only(top: 5),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                WebView(
                  key: key,
                  initialUrl: articleUrl,
                  javascriptMode: JavascriptMode.unrestricted,
                  gestureRecognizers: Set()
                    ..add(Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    )),
                ),
                Container(
                  color: background.withAlpha(192),
                  padding: EdgeInsets.only(left: 16.0, right: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        '$articleComments comment(s)      score: $articleScore',
                        style: TextStyle(
                          color: textColor.withAlpha(220),
                          fontSize: 16.0,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.launch,
                          color: HNColors.primaryColor2,
                        ),
                        onPressed: () async {
                          if (await canLaunch(articleUrl))
                            await launch(
                              articleUrl,
                              forceWebView: true,
                              enableJavaScript: true,
                            );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

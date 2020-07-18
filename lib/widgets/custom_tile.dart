import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../utils/colors.dart';

class CustomTile extends StatefulWidget {
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

  @override
  _CustomTileState createState() => _CustomTileState();
}

class _CustomTileState extends State<CustomTile> {
  bool isExpanded = false;
  Color textColor = CustomColors.primaryColor2;

  String displayTime(Duration duration) {
    if (duration == null) return 'loading';
    if (duration.inDays > 0)
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
    final key = ValueKey<int>(widget.articleId);
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: ExpansionTile(
        trailing: Icon(
          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          color: textColor,
        ),
        onExpansionChanged: (value) {
          isExpanded = value;
          setState(() => isExpanded
              ? textColor = CustomColors.primaryColor1
              : textColor = CustomColors.primaryColor2);
        },
        backgroundColor: CustomColors.primaryColor2,
        key: key,
        title: Text(
          widget.articleTitle,
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
              '${widget.articleBy}  •  ${displayTime(widget.articleTime)}',
              style: TextStyle(
                fontSize: 16.0,
                color: textColor,
              ),
            ),
          ],
        ),
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                height: 300,
                child: WebView(
                  key: key,
                  initialUrl: widget.articleUrl,
                  javascriptMode: JavascriptMode.unrestricted,
                  gestureRecognizers: Set()
                    ..add(Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    )),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 16.0, right: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      '${widget.articleComments} comment(s)      score: ${widget.articleScore}',
                      style: TextStyle(
                        color: textColor.withAlpha(220),
                        fontSize: 16.0,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.launch,
                        color: CustomColors.primaryColor1,
                      ),
                      onPressed: () async {
                        if (await canLaunch(widget.articleUrl))
                          await launch(widget.articleUrl, forceWebView: true);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

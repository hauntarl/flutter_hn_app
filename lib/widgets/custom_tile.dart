import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
  Color textColor = CustomColors.primaryBlack;

  String displayTime(Duration duration) {
    if (duration == null) return 'loading';
    if (duration.inDays > 0)
      return '${duration.inDays} day(s)';
    else if (duration.inHours > 0)
      return '${duration.inHours} hour(s)';
    else if (duration.inMinutes > 0)
      return '${duration.inMinutes} minute(s)';
    else
      return '${duration.inSeconds} second(s)';
  }

  @override
  Widget build(BuildContext context) {
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
              ? textColor = CustomColors.primaryColor
              : textColor = CustomColors.primaryBlack);
        },
        backgroundColor: CustomColors.primaryBlack,
        key: ValueKey<int>(widget.articleId),
        title: Text(
          widget.articleTitle,
          style: TextStyle(
            color: textColor,
            fontSize: 17.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 5.0),
            Text(
              widget.articleBy,
              style: TextStyle(
                color: textColor.withAlpha(220),
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 5.0),
            Text(
              '${displayTime(widget.articleTime)} ago',
              style: TextStyle(color: textColor.withAlpha(220)),
            ),
          ],
        ),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 16.0, right: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  '${widget.articleComments} comment(s)      score: ${widget.articleScore}',
                  style: TextStyle(color: textColor.withAlpha(220)),
                ),
                IconButton(
                  icon: Icon(
                    Icons.launch,
                    color: CustomColors.primaryColor,
                  ),
                  onPressed: () async {
                    if (await canLaunch(widget.articleUrl))
                      await launch(widget.articleUrl);
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

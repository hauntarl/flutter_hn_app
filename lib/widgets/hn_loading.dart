import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hn_app/utils/colors.dart';

class HNLoading extends StatefulWidget {
  @override
  _HNLoadingState createState() => _HNLoadingState();
}

class _HNLoadingState extends State<HNLoading> with SingleTickerProviderStateMixin {
  AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
      lowerBound: .5,
    );

    _fadeController.forward();
    _fadeController.addListener(() {
      if (_fadeController.isDismissed) {
        _fadeController.forward();
      } else if (_fadeController.isCompleted) {
        _fadeController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.stop();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: _fadeController,
        child: Icon(
          FontAwesomeIcons.hackerNewsSquare,
          color: CustomColors.primaryBlack,
          size: 60.0,
        ),
      ),
    );
  }
}

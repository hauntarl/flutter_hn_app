import 'package:flutter/material.dart';

import '../bloc/pref_bloc.dart';

class LowDataIcon extends StatefulWidget {
  @override
  _LowDataIconState createState() => _LowDataIconState();
}

class _LowDataIconState extends State<LowDataIcon> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      initialData: true,
      stream: prefBloc.currentPref,
      builder: (_, snapshot) => IconButton(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        onPressed: () => prefBloc.showWebViewPref.add(!snapshot.data),
        color: snapshot.data ? Colors.white : Colors.green[300],
        icon: Icon(Icons.data_usage),
      ),
    );
  }
}

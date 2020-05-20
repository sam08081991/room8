import 'package:flutter/material.dart';

const kScaffoldBackGroundColor = Colors.white;

void pageScroll(Widget pageName, context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return pageName;
      },
    ),
  );
}

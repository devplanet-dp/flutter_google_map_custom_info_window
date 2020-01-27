import 'package:flutter/material.dart';
import 'package:flutter_google_map/my_map.dart';
import 'package:flutter_google_map/util/theme.dart';


final ThemeData _AppTheme = CustomAppTheme().data;
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _AppTheme,
      home: MyMap(),
    );
  }
}



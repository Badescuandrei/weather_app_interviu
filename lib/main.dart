import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app_interviu/weather_widget.dart';
import './utils/api_call.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => WeatherProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Basic Weather App',
      home: WeatherScreen(),
    );
  }
}

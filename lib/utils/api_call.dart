import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/model.dart';

class WeatherProvider with ChangeNotifier {
  final String apiKey = 'ef419f72e06b85d2450192eec193abf5';
  WeatherData? _weatherData;
  bool _isCelsius = true;

  WeatherData? get weatherData => _weatherData;
  bool get isCelsius => _isCelsius;

  Future<void> getCurrentWeather(String location) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$location&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));
    print(response.body);

    if (response.statusCode == 200) {
      _weatherData = WeatherData.fromJson(jsonDecode(response.body));
      notifyListeners();
    } else {
      throw Exception('Failed to load any data');
    }
  }

  void toggleCelsius() {
    _isCelsius = !_isCelsius;
    notifyListeners();
  }

  final List<String> locations = ['Bucharest', 'Pitesti'];
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void changeLocation(int newIndex) {
    _currentIndex = newIndex;
    getCurrentWeather(locations[newIndex]);
    notifyListeners();
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './utils/api_call.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Timer? _updateTimer;
  Timer? _refreshCountdownTimer;
  int _refreshCountdown = 10;
  int _currentPageIndex = 0;
  final pageIndexNotifier = ValueNotifier<int>(0);
  final PageController _pageController = PageController();
  @override
  void initState() {
    super.initState();
    Provider.of<WeatherProvider>(context, listen: false)
        .getCurrentWeather('Bucharest');
    _startRefreshCountdown();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _refreshCountdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Weather App',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          Consumer<WeatherProvider>(
            builder: (context, weatherProvider, child) {
              return Switch(
                value: weatherProvider.isCelsius,
                onChanged: (value) => weatherProvider.toggleCelsius(),
              );
            },
          ),
        ],
      ),
      body: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          PageView.builder(
            pageSnapping: false,
            controller: _pageController,
            itemCount: Provider.of<WeatherProvider>(context).locations.length,
            onPageChanged: (index) {
              setState(() {
                _currentPageIndex = index;
              });

              Provider.of<WeatherProvider>(context, listen: false)
                  .changeLocation(index);
            },
            itemBuilder: (BuildContext context, int index) {
              return RefreshIndicator(
                onRefresh: () => _refreshData(
                    Provider.of<WeatherProvider>(context, listen: false)
                        .locations[index]),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Consumer<WeatherProvider>(
                    builder: (context, weatherProvider, child) {
                      if (weatherProvider.weatherData != null) {
                        return Column(
                          children: [
                            Text(
                              'Refreshing data in: $_refreshCountdown seconds',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            const SizedBox(height: 100),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.location_pin),
                                  Text(weatherProvider.weatherData!.location,
                                      style: const TextStyle(fontSize: 22)),
                                ]),
                            Lottie.asset(chooseWeatherAnimation(
                                weatherProvider.weatherData!.weatherCondition)),
                            Text(
                              weatherProvider.isCelsius
                                  ? '${weatherProvider.weatherData!.temperature.toStringAsFixed(1)}°C'
                                  : '${celsiusToFahrenheit(weatherProvider.weatherData!.temperature)}°F',
                              style: const TextStyle(
                                  fontSize: 54, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              weatherProvider.weatherData!.weatherCondition
                                  .toUpperCase(),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 30,
            child: SmoothPageIndicator(
              effect: const WormEffect(), // Customizable effect
              controller: _pageController, // Your PageView's controller
              count: Provider.of<WeatherProvider>(context).locations.length,
            ),
          ),
        ],
      ),
    );
  }

  String celsiusToFahrenheit(double celsius) {
    return ((celsius * 9 / 5) + 32).toStringAsFixed(1);
  }

  String chooseWeatherAnimation(String? weatherCondition) {
    if (weatherCondition == null) return 'assets/animations/sunny.json';
    switch (weatherCondition) {
      case "Clear":
        return 'assets/animations/sunny.json';
      case "Rain":
        return 'assets/animations/rainy.json';
      case "Clouds":
        return 'assets/animations/cloudy.json';
      default:
        return 'assets/animations/sunny.json';
    }
  }

  Future<void> _refreshData(String location) async {
    await Provider.of<WeatherProvider>(context, listen: false)
        .getCurrentWeather(location);
  }

  void _startRefreshCountdown() {
    _refreshCountdownTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_refreshCountdown > 0) {
          _refreshCountdown--;
        } else {
          _refreshCountdown = 10;
          _updateWeatherData();
        }
      });
    });
  }

  void _updateWeatherData() {
    final weatherProvider =
        Provider.of<WeatherProvider>(context, listen: false);
    weatherProvider
        .getCurrentWeather(weatherProvider.locations[_currentPageIndex]);
  }
}

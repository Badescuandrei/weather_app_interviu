import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './utils/api_call.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final pageIndexNotifier = ValueNotifier<int>(0);
  final PageController _pageController = PageController();
  @override
  void initState() {
    super.initState();
    Provider.of<WeatherProvider>(context, listen: false)
        .getCurrentWeather('Bucharest');
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
          RefreshIndicator(
            onRefresh: _refreshData,
            child: PageView.builder(
              controller: _pageController,
              itemCount: Provider.of<WeatherProvider>(context).locations.length,
              onPageChanged: (index) {
                {
                  Provider.of<WeatherProvider>(context, listen: false)
                      .changeLocation(index);

                  pageIndexNotifier.value = index;
                }
              },
              itemBuilder: (BuildContext context, int index) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Consumer<WeatherProvider>(
                    builder: (context, weatherProvider, child) {
                      if (weatherProvider.weatherData != null) {
                        return Column(
                          children: [
                            const SizedBox(height: 20),
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
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
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
    return ((celsius * 9 / 5) + 32).toString();
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

  Future<void> _refreshData() async {
    await Provider.of<WeatherProvider>(context, listen: false)
        .getCurrentWeather('Bucharest');
  }
}

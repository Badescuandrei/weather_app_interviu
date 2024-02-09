class WeatherData {
  final String location;
  final String weatherCondition;
  final double temperature;

  WeatherData({
    required this.location,
    required this.weatherCondition,
    required this.temperature,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      location: json['name'],
      weatherCondition: json['weather'][0]['main'],
      temperature: json['main']['temp'],
    );
  }
}

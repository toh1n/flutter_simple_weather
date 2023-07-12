import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WeatherApp(),
    );
  }
}

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  WeatherAppState createState() => WeatherAppState();
}

class WeatherAppState extends State<WeatherApp> {
  bool _isLoading = true;
  String _temperature = '';
  String _city = '';
  String _condition = '';
  String _minTemp = '';
  String _maxTemp = '';
  String _weatherIcon = '';
  double longitude = 0;
  double latitude = 0;
  String _currentTime =
      "Updated : ${DateFormat('hh:mm a').format(DateTime.now())}";

  TextEditingController manualLatitude = TextEditingController();
  TextEditingController manualLongitude = TextEditingController();

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      setState(() {
        _currentTime = 'Location permissions are denied.';
        _isLoading = false;
      });
      showPermissionDeniedDialog();
    } else if (permission == LocationPermission.deniedForever) {
      setState(() {
        _currentTime = 'Location permissions denied.';
        _isLoading = false;
      });
    } else {
      _getLocation();
    }
  }

  Future<void> _getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      longitude = position.longitude;
      latitude = position.latitude;
      _isLoading = true;
    });

    _getWeatherData();
  }

  Future<void> _getWeatherData() async {
    String apiKey = 'YOUR_API_KEY';
    String apiUrl =
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric';

    http.Response response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      dynamic data = jsonDecode(response.body);
      double temp = data['main']['temp'];
      String cityName = data['name'];
      String condition = data['weather'][0]['main'];
      double minTemp = data['main']['temp_min'];
      double maxTemp = data['main']['temp_max'];
      String iconCode = data['weather'][0]['icon'];

      setState(() {
        _temperature = '${temp.toInt()}';
        _city = cityName;
        _condition = condition;
        _minTemp = '${minTemp.toInt()}';
        _maxTemp = '${maxTemp.toInt()}';
        _weatherIcon = 'http://openweathermap.org/img/wn/$iconCode@2x.png';
        _isLoading = false;
        _currentTime =
            "Updated : ${DateFormat('hh:mm a').format(DateTime.now())}";
      });
    } else {
      setState(() {
        _currentTime = 'Error retrieving data';
        _city = '';
        _condition = '';
        _minTemp = '';
        _maxTemp = '';
        _weatherIcon = '';
        _isLoading = false;
      });
    }
  }

  void showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Denied'),
          content:
              const Text('Please grant location permission to use this app.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Try Again'),
              onPressed: () {
                _requestLocationPermission();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void refreshWeather() {
    setState(() {
      _isLoading = true;
    });
    _getWeatherData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: const Text("Flutter Weather"),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: refreshWeather,
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Container(
                        color: Colors.deepPurple.shade300,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  "Manually Set Location ",
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextField(
                                controller: manualLongitude,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: "Longitude",
                                  filled: true,
                                  fillColor: Colors.deepPurple.shade100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextField(
                                keyboardType: TextInputType.number,
                                controller: manualLatitude,
                                decoration: InputDecoration(
                                  hintText: "Latitude",
                                  filled: true,
                                  fillColor: Colors.deepPurple.shade100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple.shade500,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (manualLongitude.text.isNotEmpty &&
                                          manualLatitude.text.isNotEmpty) {
                                        longitude =
                                            double.parse(manualLongitude.text);
                                        latitude =
                                            double.parse(manualLatitude.text);
                                        _getWeatherData();
                                        manualLatitude.clear();
                                        manualLongitude.clear();
                                        Navigator.pop(context);
                                      } else {}
                                    });
                                  },
                                  child: const Text('Save'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                });
              },
              icon: const Icon(Icons.settings),
            ),
          ],
        ),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.deepPurple.shade700,
                Colors.deepPurple.shade700,
                Colors.deepPurple.shade700,
                Colors.deepPurple.shade700,
                Colors.deepPurple.shade500,
                Colors.deepPurple.shade400,
                Colors.deepPurple.shade300,
              ],
            ),
          ),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Padding(padding: EdgeInsets.all(50)),
                    Center(
                      child: Text(
                        _city,
                        style: const TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      _currentTime,
                      style: const TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const Padding(padding: EdgeInsets.all(15)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.network(
                          _weatherIcon,
                          height: 100,
                          width: 100,
                          fit: BoxFit.fill,
                          errorBuilder: (BuildContext context, Object exception,
                              StackTrace? stackTrace) {
                            return const Icon(Icons.error);
                          },
                        ),
                        Text(
                          "$_temperature°",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 45,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              "Min : $_minTemp°",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "Max : $_maxTemp°",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      _condition,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

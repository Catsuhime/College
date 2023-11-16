import 'package:flutter/material.dart';
import 'dart:convert';

void main() {
  runApp(DriftChampionshipApp());
}

class DriftChampionshipApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Championship App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChampionshipLevelScreen(),
    );
  }
}

class ChampionshipLevelScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Championship'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ParticipantsScreen(),
                  ),
                );
              },
              child: Text('Drift Championship'),
            ),
          ],
        ),
      ),
    );
  }
}

class ParticipantsScreen extends StatefulWidget {
  @override
  _ParticipantsScreenState createState() => _ParticipantsScreenState();
}

class _ParticipantsScreenState extends State<ParticipantsScreen> {
  late List<Championship> championships;

  @override
  void initState() {
    super.initState();
    // Fetch and parse JSON data when the widget is initialized.
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final String jsonString =
          await DefaultAssetBundle.of(context).loadString('assets/data.json');
      print('JSON Data: $jsonString'); // Debug print to check JSON data
      final List<dynamic> jsonData = jsonDecode(jsonString);

      championships =
          jsonData.map((data) => Championship.fromJson(data)).toList();
      setState(() {});
    } catch (e) {
      print('Error fetching data: $e'); // Debug print for any errors
    }
  }

  @override
  Widget build(BuildContext context) {
    if (championships == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    // Display the championship and driver information.
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Championship levels'),
      ),
      body: ListView.builder(
        itemCount: championships.length,
        itemBuilder: (context, index) {
          final championship = championships[index];
          return ListTile(
            title: Text(championship.leagueTitle),
            subtitle: Text('Number of Drivers: ${championship.drivers.length}'),
            onTap: () {
              // Navigate to a screen to display driver details.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DriverDetailsScreen(
                    championship: championship,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class DriverDetailsScreen extends StatefulWidget {
  final Championship championship;

  DriverDetailsScreen({required this.championship});

  @override
  _DriverDetailsScreenState createState() => _DriverDetailsScreenState();
}

class _DriverDetailsScreenState extends State<DriverDetailsScreen> {
  List<Driver> filteredDrivers = [];
  bool sortByPoints = false;

  @override
  void initState() {
    filteredDrivers = List.from(widget.championship.drivers);
    super.initState();
  }

  double calculateTotalScore(Driver driver) {
    double totalScore = 0.0;
    for (var race in driver.races) {
      totalScore += race.tandemPoints + race.qualificationPoints;
    }
    return totalScore;
  }

  void filterDriversAlphabetically() {
    setState(() {
      filteredDrivers.sort((a, b) =>
          a.firstName.toLowerCase().compareTo(b.firstName.toLowerCase()));
      sortByPoints = false;
    });
  }

  void filterDriversByPoints() {
    setState(() {
      filteredDrivers.sort((a, b) {
        final totalPointsA = calculateTotalScore(a);
        final totalPointsB = calculateTotalScore(b);
        return totalPointsB.compareTo(totalPointsA); // Sort in descending order
      });
      sortByPoints = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Details'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.sort_by_alpha),
            onPressed: filterDriversAlphabetically,
          ),
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: filterDriversByPoints,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: filteredDrivers.length,
        itemBuilder: (context, index) {
          final driver = filteredDrivers[index];
          final totalScore = calculateTotalScore(driver);

          return Column(
            children: [
              ListTile(
                title: Text('${driver.firstName} ${driver.lastName}'),
                subtitle: Text('Car: ${driver.car}'),
                onTap: () {
                  // Navigate to a screen to display driver's race details.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RaceDetailsScreen(
                        driver: driver,
                      ),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Total Score: $totalScore'),
              ),
              Divider(),
            ],
          );
        },
      ),
    );
  }
}



class RaceDetailsScreen extends StatelessWidget {
  final Driver driver;

  RaceDetailsScreen({required this.driver});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Race Details'),
      ),
      body: ListView.builder(
        itemCount: driver.races.length,
        itemBuilder: (context, index) {
          final race = driver.races[index];
          return ListTile(
            title: Text('Race ID: ${race.raceId}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Race Information: ${race.raceInformation}'),
                Text('Qualification Position: ${race.qualificationPosition}'),
                Text('Qualification Result: ${race.qualificationResult}'),
                Text('Qualification Points: ${race.qualificationPoints}'),
                Text('Tandem Result: ${race.tandemResult}'),
                Text('Tandem Points: ${race.tandemPoints}'),
              ],
            ),
          );
        },
      ),
    );
  }
}

class Championship {
  final int leagueId;
  final String leagueTitle;
  final List<Driver> drivers;

  Championship({
    required this.leagueId,
    required this.leagueTitle,
    required this.drivers,
  });

  factory Championship.fromJson(Map<String, dynamic> json) {
    final List<dynamic> driversData = json['drivers'];
    final List<Driver> drivers =
        driversData.map((data) => Driver.fromJson(data)).toList();

    return Championship(
      leagueId: json['league_id'],
      leagueTitle: json['league_title'],
      drivers: drivers,
    );
  }
}

class Driver {
  final int driverId;
  final String firstName;
  final String lastName;
  final String car;
  final List<Race> races;

  Driver({
    required this.driverId,
    required this.firstName,
    required this.lastName,
    required this.car,
    required this.races,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    final List<dynamic> racesData = json['race'];
    final List<Race> races =
        racesData.map((data) => Race.fromJson(data)).toList();

    return Driver(
      driverId: json['driver_id'],
      firstName: json['firstname'],
      lastName: json['lastname'],
      car: json['car'],
      races: races,
    );
  }
}

class Race {
  final int raceId;
  final String raceInformation;
  final double qualificationPosition;
  final double qualificationResult;
  final double qualificationPoints;
  final String tandemResult;
  final double tandemPoints;

  Race({
    required this.raceId,
    required this.raceInformation,
    required this.qualificationPosition,
    required this.qualificationResult,
    required this.qualificationPoints,
    required this.tandemResult,
    required this.tandemPoints,
  });

  factory Race.fromJson(Map<String, dynamic> json) {
    return Race(
      raceId: json['race_id'],
      raceInformation: json['race_information'],
      qualificationPosition: json['qualification_position'].toDouble(),
      qualificationResult: json['qualification_result'].toDouble(),
      qualificationPoints: json['qualification_points'].toDouble(),
      tandemResult: json['tandem_result'],
      tandemPoints: json['tandem_points'].toDouble(),
    );
  }
}

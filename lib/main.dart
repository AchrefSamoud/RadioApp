import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';
import 'dart:io';





Future<void> main() async {
  HttpOverrides.global = new MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp( MyApp());
}
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    HttpClient client = super.createHttpClient(context);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  }
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radio Station Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RadioStationList(),
    );
  }
}

class RadioStationList extends StatefulWidget {
  @override
  _RadioStationListState createState() => _RadioStationListState();
}

class _RadioStationListState extends State<RadioStationList> {
  final List<Map<String,String>> radioStations = [];  
  int _selectedIndex = -1;
  AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _loadStations();
  }
  void _loadStations() async {
    final dbRef = FirebaseDatabase.instance.ref().child('radioStations');
    final dataSnapshot = await dbRef.once();
    final stationsData = dataSnapshot.snapshot.value;
    print("debugging");
    print(stationsData);

    if (stationsData != null) {
      if (stationsData is List) {
        // convert list to map with indices as keys
        for (var i = 0; i < stationsData.length; i++) {
          final stationData = stationsData[i];
          final station = <String, String>{
            'name': stationData['name'],
            'streamUrl': stationData['streamUrl'],
            'imageUrl': stationData['imageUrl'],
          };
          print("hello");
          print(station);
          radioStations.add(station);
        }
      } else if (stationsData is Map) {
        // process map directly
        for (var stationData in stationsData.values) {
          final station = <String, String>{
            'name': stationData['name'],
            'streamUrl': stationData['streamUrl'],
            'imageUrl': stationData['imageUrl'],
          };
          print("hello");
          print(station);
          radioStations.add(station);
        }
      }
    }

    setState(() {});
  }


  @override
  void dispose() {
    _audioPlayer.stop();
    super.dispose();
  }

  void _togglePlay(String streamUrl) {
    if (_isPlaying) {
      _audioPlayer.stop();
      setState(() {
        _isPlaying = false;
      });
    } else {
      _audioPlayer.play(streamUrl);
      setState(() {
        _isPlaying = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Radio Stations'),
      ),
      body: GridView.builder(
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemCount: radioStations.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                if (_selectedIndex == index) {
                  _selectedIndex = -1;
                } else {
                  _selectedIndex = index;
                }
              });
              _togglePlay(radioStations[index]['streamUrl']!);
            },
            child: Card(
              color: _selectedIndex == index ? Colors.blue[100] : null,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.network(
  radioStations[index]['imageUrl']!,
  width: 100,
  height: 100,
  fit: BoxFit.cover,
),
                  SizedBox(height: 10),
                  Text(
                        radioStations[index]['name'] ?? '',
                        style: TextStyle(fontSize: 18),
                      ),

                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

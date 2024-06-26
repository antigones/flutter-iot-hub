import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:iothub_position/db_utils.dart';
import 'package:iothub_position/location.dart';
import 'package:iothub_position/location_table.dart';
import 'package:iothub_position/queue_utils.dart';
import 'package:latlong2/latlong.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await createDatabase();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.location_pin)),
                Tab(icon: Icon(Icons.history)),
              ],
            ),

          ),
          body: const TabBarView(
            children: [
              MyHomePage(title: 'Locations'),
              LocationTable(),

            ],
          ),
        ),
      ),

    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  Future<List<Location>> _myData = locations();
  double mapZoom = 18;
  late final MapController _mapController;

  Future<void> _peekData() async {
    await peekQMessages();
    setState(() {
      _myData = locations();
    });
  }

  Future<void> _consumeData() async {
    await getQMessages();
    setState(() {
      _myData = locations();
    });
  }

  void _zoomIn() {
    _mapController.moveAndRotate(LatLng(45.470024,
        9.216240), ++mapZoom, 0);
  }

  void _zoomOut() {
    _mapController.moveAndRotate(LatLng(45.470024,
        9.216240),--mapZoom,0);
  }


  @override
  void initState()  {
    super.initState();
    _mapController = MapController();


  }


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return  Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            FutureBuilder(
              builder: (ctx, snapshot) {
                // Checking if future is resolved or not
                if (snapshot.connectionState == ConnectionState.done) {
                  // If we got an error
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        '${snapshot.error} occurred',
                        style: const TextStyle(fontSize: 18),
                      ),
                    );

                    // if we got our data
                  } else if (snapshot.hasData) {
                    // Extracting data from snapshot object
                    final data = snapshot.data as List<Location>;
                    final mapPoints = data.map((location) =>
                      LatLng(location.lat, location.long)
                    );

                    return Center(
                        child: SizedBox(
                          width: 500.0,
                          height: 500.0,
                          child: FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                                center: LatLng(45.470024,
                                    9.216240),
                                zoom: mapZoom),
                            children: [
                              TileLayer(
                                urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.app',
                              ),
                              PolylineLayer(
                                polylines: [
                                  Polyline(
                                      points: List.from(mapPoints),
                                      color: Colors.blue,
                                      strokeWidth: 2.0,

                                  strokeCap: StrokeCap.butt),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                  }
                }

                // Displaying LoadingSpinner to indicate waiting state
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },

              // Future that needs to be resolved
              // inorder to display something on the Canvas
              future: _myData,
            ),
            TextButton(
              onPressed: _consumeData,
              child: const Text('Consume location queue and write to sqlite'),
            ),
            TextButton(
              onPressed: _zoomIn,
              child: const Text('(+) Zoom'),
            ),
            TextButton(
              onPressed: _zoomOut,
              child: const Text('(-) Zoom'),
            ),
          ],
        ),
      );
  }
}

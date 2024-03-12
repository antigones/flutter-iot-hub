

// Define a function that inserts dogs into the database
import 'package:iothub_position/location.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

late final Future<Database> database;

Future<void> createDatabase() async {
  print('createDatabase()');
  database = openDatabase(
  // Set the path to the database. Note: Using the `join` function from the
  // `path` package is best practice to ensure the path is correctly
  // constructed for each platform.
  join(await getDatabasesPath(), 'user_locations.db'),
// When the database is first created, create a table to store dogs.
  onCreate: (db, version) {
// Run the CREATE TABLE statement on the database.
  print('creating database');
  return db.execute(
  'CREATE TABLE user_locations(id INTEGER PRIMARY KEY, timestamp INTEGER, long REAL, lat REAL, battery INT)',
  );
  },
// Set the version. This executes the onCreate function and provides a
// path to perform database upgrades and downgrades.
  version: 1,
  );
}

Future<void> insertLocation(Location location) async {
  print('insert location...');
  final db = await database;

  await db.insert(
    'user_locations',
    location.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
  print('insert location done');
}

Future<List<Location>> locations() async {
  // Get a reference to the database.
  final db = await database;

  // Query the table for all the user locations.
  final List<Map<String, Object?>> locationMaps = await db.query('user_locations');

  // Convert the list of each location's fields into a list of `Location` objects.
  return [
    for (final {
    'id': id as int,
    'timestamp': timestamp as int,
    'lat': lat as double,
    'long': long as double,
    'battery': battery as int,
    } in locationMaps)
      Location(timestamp: timestamp, lat: lat, long: long, battery: battery),
  ];
}
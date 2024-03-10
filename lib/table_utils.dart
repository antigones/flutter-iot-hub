import 'dart:convert';

import 'package:azstore/azstore.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

List mockLocations = [
  {"lat":41.8902102, "long":12.4896506},
  {"lat":41.891256, "long":12.491126},
  {"lat":41.892127, "long":12.489238},
];


const partitionKey = 'pkey';

const _connectionString = "conn_string";
var uuid = Uuid();

Future<List> filterTable() async {
  var storage = AzureStorage.parse(_connectionString);
  print('working on results...');
  List result = await storage.filterTableRows(
      tableName: 'locations',
      filter: '',
      fields: ['lat','long','PartitionKey', 'RowKey']);

  print('showing filter results');
  /*for (Map<String, dynamic> res in result) {
    print(res.toString());
  }*/
  return result;
}

Future<void> addDataToTable() async {
  var storage = AzureStorage.parse(_connectionString);
  try {
    mockLocations.forEach((mockLocation) async {
      print(mockLocation);
      await storage.putTableRow(
          tableName: 'locations',
          partitionKey: partitionKey,
          rowKey: uuid.v4(),
          bodyMap: mockLocation
      );
    });

  }catch(e){
    print('tables upsert exception: $e');
  }
}

List<LatLng> mockLocationsAsLatLon() {
  var points = mockLocations.map((element) {
    return LatLng(element['lat'].toDouble(),element['long'].toDouble());
  }).toList();
  return points;
}

Future<List<LatLng>> addLocationsFromTableAsLatLng() async {
  List results = await filterTable();
  var points = results.map((element) {
    return LatLng(element['lat'].toDouble(),element['long'].toDouble());
  }).toList();
  print(points);
  return points;
}

Future<List> peekQMessages() async {
  var storage = AzureStorage.parse(_connectionString);
  List locations = [];
  try {
    List<AzureQMessage> result = await storage.peekQmessages(qName: 'location-queue', numofmessages: 30);
    for (var res in result) {
      String decoded = String.fromCharCodes(base64Decode(res.messageText!));
      Map<String, dynamic> data = json.decode(decoded);
      locations.add(json.decode(String.fromCharCodes(base64Decode(data["data"]["body"]))));
    }
  } catch (e) {
    print('Q peek messages exception $e');
    print(e.toString()); //Optional prompt
  }

  var points = locations.map((element) {
    return LatLng(element['lat'].toDouble(),element['long'].toDouble());
  }).toList();
  return points;
}

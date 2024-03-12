import 'dart:convert';

import 'package:azstore/azstore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:iothub_position/db_utils.dart';
import 'package:iothub_position/location.dart';


List mockLocations = [
  {"lat":41.8902102, "long":12.4896506},
  {"lat":41.891256, "long":12.491126},
  {"lat":41.892127, "long":12.489238},
];

String _connectionString = dotenv.env['AZ_STORAGE_QUEUE_CONNECTION_STRING']!;

Future<void> getQData() async {
  var storage = AzureStorage.parse(_connectionString);
  try {
    String qName = 'location-queue';
    Map<String, String> result = await storage.getQData(qName);
    print('showing $qName data:\n');
    for (var res in result.entries) {
      print('${res.key}: ${res.value}');
    }
  } catch (e) {
    print('get data error: $e');
  }
}

Future<List<Location>> getQMessages() async {
  print("getQMessages");
  var storage = AzureStorage.parse(_connectionString);
  List<Location> locations = [];
  try {
    List<AzureQMessage> result = await storage.getQmessages(
        qName: 'location-queue', //Required
        numOfmessages:
        32 //Optional. Number of messages to retrieve. This package returns top 20 filter results when not specified.
    );

    for (var res in result) {
      String decoded = String.fromCharCodes(base64Decode(res.messageText!));
      Map<String, dynamic> data = json.decode(decoded);
      final location = Location.fromJson(json.decode(String.fromCharCodes(base64Decode(data["data"]["body"]))));
      locations.add(location);
      insertLocation(location);
    }
  } catch (e) {
    print('Q get messages exception $e');
    print(e.toString()); //Optional prompt
  }
  return locations;
}

Future<List<Location>> peekQMessages() async {
  var storage = AzureStorage.parse(_connectionString);
  List<Location> locations = [];

  try {
    List<AzureQMessage> result = await storage.peekQmessages(qName: 'location-queue', numofmessages: 2);
    for (var res in result) {
      String decoded = String.fromCharCodes(base64Decode(res.messageText!));
      Map<String, dynamic> data = json.decode(decoded);
      final location = Location.fromJson(json.decode(String.fromCharCodes(base64Decode(data["data"]["body"]))));
      locations.add(location);
      insertLocation(location);
    }
  } catch (e) {
    print('Q peek messages exception $e');
    print(e.toString()); //Optional prompt
  }
  return locations;
}

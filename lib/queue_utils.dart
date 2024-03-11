import 'dart:convert';

import 'package:azstore/azstore.dart';
import 'package:iothub_position/location.dart';


List mockLocations = [
  {"lat":41.8902102, "long":12.4896506},
  {"lat":41.891256, "long":12.491126},
  {"lat":41.892127, "long":12.489238},
];

const _connectionString = "connString";

Future<void> getQData() async {
  var storage = AzureStorage.parse(_connectionString);
  try {
    String qName = 'location-queue';
    Map<String, String> result = await storage.getQData(qName);
    print('showing $qName data:\n');
    for (var res in result.entries) {
      print('${res.key}: ${res.value}');
    }
    // showInfoDialog(context, 'Success');//Optional prompt
  } catch (e) {
    print('get data error: $e');
    // showErrorDialog(context, e.toString());
  }
}

Future<void> getQMessages() async {
  var storage = AzureStorage.parse(_connectionString);
  print('working on results...');
  try {
    List<AzureQMessage> result = await storage.getQmessages(
        qName: 'location-queue', //Required
        numOfmessages:
        2 //Optional. Number of messages to retrieve. This package returns top 20 filter results when not specified.
    );
    print('showing results');
    for (var res in result) {
      print('message $res');
    }
    print('Success'); //Optional prompt

  } catch (e) {
    print('Q get messages exception $e');
    print(e.toString()); //Optional prompt
  }
}

Future<List<Location>> peekQMessages() async {
  var storage = AzureStorage.parse(_connectionString);
  List<Location> locations = [];

  try {
    List<AzureQMessage> result = await storage.peekQmessages(qName: 'location-queue', numofmessages: 32);
    for (var res in result) {
      String decoded = String.fromCharCodes(base64Decode(res.messageText!));
      Map<String, dynamic> data = json.decode(decoded);
      final location = Location.fromJson(json.decode(String.fromCharCodes(base64Decode(data["data"]["body"]))));
      locations.add(location);
    }
  } catch (e) {
    print('Q peek messages exception $e');
    print(e.toString()); //Optional prompt
  }
  return locations;
}

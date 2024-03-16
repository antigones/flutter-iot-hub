import 'package:flutter/material.dart';
import 'package:iothub_position/db_utils.dart';
import 'package:iothub_position/location.dart';
import 'package:intl/intl.dart';
import 'package:iothub_position/location_utils.dart';

class LocationTable extends StatefulWidget {
  const LocationTable({Key? key}) : super(key: key);

  @override
  _LocationTableState createState() => _LocationTableState();
}

class _LocationTableState extends State<LocationTable> {

  Future<List<Location>> _locations = locations();


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
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
            final List<Location> data = snapshot.data as List<Location>;

             Iterable<DataRow> rows = data.map((location) {
             DataRow dataRow =
             DataRow(
             cells: <DataCell>[
                DataCell(Text(formatTimestamp(location.timestamp.toString()))),
                DataCell(Text("${location.lat},${location.long}")),
             ],
               onLongPress: () {
                 showModalBottomSheet<void>(
                     context: context,
                     builder: (BuildContext context) {
                       return Container(
                           height: 300,
                           child: Center(
                           child: Column(
                           mainAxisAlignment: MainAxisAlignment.center,
                           mainAxisSize: MainAxisSize.min,
                           children: <Widget>[
                             Text("Timestamp: ${formatTimestamp(location.timestamp.toString())}"),
                             Text("Location: ${location.lat},${location.long}"),
                             Text("Battery: ${location.battery}"),
                       ElevatedButton(
                       child: const Text('Close'),
                       onPressed: () => Navigator.pop(context),
                       )],
                           ),
                           ),
                       );
                     },
                 );
               }
             );

             return dataRow;
           });


            return
              Scrollbar(
                  thumbVisibility: true,
                  trackVisibility: true,
                  child: SingleChildScrollView(

                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Scrollbar(
                          child:DataTable(
                            columns: const <DataColumn>[
                              DataColumn(

                                label: Expanded(
                                  child: Text(
                                    'Timestamp',
                                    style: TextStyle(fontStyle: FontStyle.italic),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Expanded(
                                  child: Text(
                                    'LatLong',
                                    style: TextStyle(fontStyle: FontStyle.italic),
                                  ),
                                ),
                              ),
                            ],
                            rows: rows.toList(),
                          )))))
              ;
          }
        }

        // Displaying LoadingSpinner to indicate waiting state
        return const Center(
          child: CircularProgressIndicator(),
        );
      },

      // Future that needs to be resolved
      // inorder to display something on the Canvas
      future: _locations,
    );

  }
}

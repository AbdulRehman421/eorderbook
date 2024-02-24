  import 'package:eorderbook/screens/login_screen.dart';
  import 'package:flutter/material.dart';
  import 'package:fluttertoast/fluttertoast.dart';
  import 'package:google_maps_flutter/google_maps_flutter.dart';
  import 'package:http/http.dart' as http;
  import 'dart:convert';
  import 'package:location/location.dart';
  import 'package:shared_preferences/shared_preferences.dart';

  import '../services/distcodedb.dart';

  class OrderMap extends StatefulWidget {
String distcode;
String username;
   OrderMap(
      {Key? key,
        required this.username,
        required this.distcode,
      })
      : super(key: key);

    @override
    _OrderMapState createState() => _OrderMapState();
  }

  class _OrderMapState extends State<OrderMap> {
    late GoogleMapController mapController;
    List<Marker> markers = [];
    List<Polyline> polylines = [];
    LocationData? currentLocation;
    TextEditingController userNameController = TextEditingController();
    DateTime? selectedDate;

    @override
    void initState() {
      super.initState();
      getCurrentLocation();
      getStoredDate().then((storedDate) {
        DateTime finalDate = storedDate ?? selectedDate ?? DateTime.now();
        fetchMarkers(widget.distcode, widget.username, finalDate);
      });
    }

    Future<DateTime?> getStoredDate() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? storedMilliseconds = prefs.getInt('selectedDate');
      return storedMilliseconds != null ? DateTime.fromMillisecondsSinceEpoch(storedMilliseconds) : null;
    }

    // String dist_Code = '0';
    // Future<void> _getDistCode() async {
    //   String? distributorCode = await DistcodeDatabaseHelper().getDistributorCode();
    //   setState(() {
    //     dist_Code = distributorCode ?? '';
    //   });
    // }
    void getCurrentLocation() async {
      Location location = Location();

      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          print('Location services are disabled.');
          return;
        }
      }

      try {
        currentLocation = await location.getLocation();
        if (mapController != null) {
          mapController.animateCamera(CameraUpdate.newLatLng(LatLng(
            currentLocation!.latitude!,
            currentLocation!.longitude!,
          )));
        }
      } catch (e) {
        print('Error getting current location: $e');
      }
    }

    Future<void> showInputDialog() async {
      selectedDate = DateTime.now();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');

      // Directly call fetchMarkers before showing the AlertDialog
      fetchMarkers(widget.distcode, widget.username, selectedDate);

      // Show the AlertDialog after calling fetchMarkers
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: Text('Enter User Name'),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Dist Code : ${widget.distcode}", style: TextStyle(fontSize: 18)),
                      Text("Username : ${username.toString()}", style: TextStyle(fontSize: 18)),
                      SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          setState(() {
                            selectedDate = pickedDate;
                          });
                        },
                        child: Text('Select Date'),
                      ),
                      if (selectedDate != null)
                        Text(
                          'Selected Date: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        fetchMarkers(
                          widget.distcode,
                          username.toString(),
                          selectedDate, // Use finalDate instead of selectedDate
                        );

                        userNameController.clear();
                        selectedDate = null; // Clear selected date
                      },


                      child: Text('Submit'),
                    ),
                  ],
                );
              },
            );
          },
        );
      });
    }
    Future<void> fetchMarkers(
        String distCode, String userName, DateTime? selectedDate, {bool ascendingOrder = true}) async {
      // Clear existing markers
      markers.clear();

      if (selectedDate == null) {
        // Show a toast if no date is selected
        Fluttertoast.showToast(
          msg: 'Please select a date.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return;
      }

      String formattedDate =
          "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

      String apiUrl =
          'https://seasoftsales.com/eorderbook/get_orders.php?dist_code=$distCode&user_name=$userName&selected_date=$formattedDate';

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        for (var item in data) {
          final double latitude = double.parse(item['latitude']);
          final double longitude = double.parse(item['longitude']);

          markers.add(
            Marker(
              markerId: MarkerId(item['order_id']),
              position: LatLng(latitude, longitude),
              infoWindow: InfoWindow(
                title: item['date'],
                snippet: '${item['name']}(Rs.${item['order_amount']})',
                onTap: () {
                  showDetailsDialog(item);
                },
              ),
            ),
          );
        }
        // Sort markers based on datetime values
        markers.sort((a, b) {
          if (ascendingOrder) {
            return a.infoWindow.title!.compareTo(b.infoWindow.title!);
          } else {
            return b.infoWindow.title!.compareTo(a.infoWindow.title!);
          }
        });

        drawRoute(); // Draw route after sorting
        setState(() {});
      } else {
        // Show a toast for the error
        Fluttertoast.showToast(
          msg: 'Failed to load markers. Please try again.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }

    void showDetailsDialog(Map<String, dynamic> details) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('${details['name']}'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Customer name: ${details['name']}'),
                Text('Area Name: ${details['areaname']}(${details['areacd']})'),
                Text('Date: ${details['date']}'),
                Text('Order Amount: ${details['order_amount']}'),
                Text('Order ID: ${details['order_id']}'),
                Text('Longitude: ${details['longitude']}'),
                Text('Latitude: ${details['latitude']}'),

              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    }

    void drawRoute() {
      // Ensure that there are at least two markers to create a route
      if (markers.length < 2) {
        print('Not enough markers to create a route.');
        return;
      }

      // Clear previous polylines
      polylines.clear();

      List<LatLng> routeCoordinates = markers.map((marker) => marker.position).toList();

      // Draw a polyline connecting consecutive markers
      Polyline routePolyline = Polyline(
        polylineId: PolylineId('route'),
        points: routeCoordinates,
        color: Colors.blue,
        width: 5,
      );

      // Add the polyline to the list
      polylines.add(routePolyline);

      // Update the polylines property of the GoogleMap widget
      setState(() {});
    }

    void clearMarkersAndRoutes() {
      markers.clear();
      polylines.clear();
      setState(() {});
    }

    @override
    Widget build(BuildContext context) {
      int totalMarkers = markers.length;
      return Scaffold(
        appBar: AppBar(
         automaticallyImplyLeading: true,
          actions: [
            IconButton(
              onPressed: () {
                // _getDistCode();
                showInputDialog();
              },
              icon: Icon(Icons.add),
            ),
          ],
          title: GestureDetector(
              onTap: () {
                clearMarkersAndRoutes();
              },
              child: Text('eOrderBook Orders ($totalMarkers)')),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: GoogleMap(
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(0.0, 0.0),
                  zoom: 2.0,
                ),
                markers: Set<Marker>.from(markers),
                polylines: Set<Polyline>.from(polylines),
              ),
            ),
          ],
        ),
      );
    }
  }

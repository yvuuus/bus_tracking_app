import 'dart:async';
import 'package:bus_tracking_app/Assistants/assistants_methods.dart';
import 'package:bus_tracking_app/global/global.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  GoogleMapController? newGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  bool openNavigationDrawer = false;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 15,
  );

  var geoLocator = Geolocator();
  LocationPermission? _locationPermission;

  String statusText = "Now Offline";
  Color buttonColor = Colors.grey;
  bool isDriverActive = false;

  Position? DriverCurrentPosition;
  StreamSubscription<Position>? streamSubscriptionDriverLivePosition;

  // Request location permissions
  Future<void> checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  // Get current location of the driver
  Future<void> _getDriverLocation() async {
    DriverCurrentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    LatLng latLngPosition = LatLng(
        DriverCurrentPosition!.latitude, DriverCurrentPosition!.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 16);
    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    // Get human-readable address (optional)
    String humanReadableAddress =
        await AssistantsMethods.searchAddressForGeographicCordinates(
            DriverCurrentPosition!, context);
  }

  // Read current driver information from Firebase
  Future<void> readCurrentDriverInformation() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("No current user found.");
      return;
    }

    try {
      DatabaseEvent event = await FirebaseDatabase.instance
          .ref()
          .child("drivers")
          .child(currentUser.uid)
          .once();

      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> driverData =
            event.snapshot.value as Map<dynamic, dynamic>;

        setState(() {
          onlineDriverData.name = driverData["name"];
          onlineDriverData.id = driverData["id"];
          onlineDriverData.email = driverData["email"];
          onlineDriverData.address = driverData["address"];
          onlineDriverData.carName = driverData["carName"];
          onlineDriverData.carPlateNum = driverData["carPlateNum"];
          onlineDriverData.carType = driverData["carType"];
        });
      } else {
        print("Driver data not found.");
      }
    } catch (e) {
      print("Error reading driver data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    checkIfLocationPermissionAllowed();
    readCurrentDriverInformation();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          padding: const EdgeInsets.only(top: 40),
          mapType: MapType.normal,
          myLocationEnabled: true,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            _controllerGoogleMap.complete(controller);
            newGoogleMapController = controller;
            _getDriverLocation();
          },
        ),
        // UI for online/offline driver status
        statusText != "Now Online"
            ? Container(
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                color: Colors.black87,
              )
            : Container(),
        // Button for toggling online/offline driver status
        Positioned(
          top: statusText != "Now Online"
              ? MediaQuery.of(context).size.height * 0.45
              : 40,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () {
                    if (isDriverActive != true) {
                      DriverisOnlineNow();
                      updateDriversLocationRealTime();

                      setState(() {
                        statusText = "Now Online";
                        isDriverActive = true;
                        buttonColor = Colors.transparent;
                      });
                    } else {
                      driverIsOfflineNow();
                      setState(() {
                        statusText = "Now Offline";
                        isDriverActive = false;
                        buttonColor = Colors.grey;
                      });
                      Fluttertoast.showToast(msg: "You are offline now");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      )),
                  child: statusText != "Now Online"
                      ? Text(
                          statusText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.phonelink_ring,
                          color: Colors.white,
                          size: 26,
                        ))
            ],
          ),
        )
      ],
    );
  }

  // Set driver as online and start updating location in real-time
  Future<void> DriverisOnlineNow() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("No current user found.");
      return;
    }

    try {
      print("Getting current position...");
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      DriverCurrentPosition = position;

      // Initialize Geofire and set the driver's location
      print("Initializing Geofire...");
      Geofire.initialize("activeDrivers");
      print("Geofire initialized");

      await Geofire.setLocation(currentUser.uid,
          DriverCurrentPosition!.latitude, DriverCurrentPosition!.longitude);
      print("Driver location set in Geofire");

      // Update the driver's status to "online" in Firebase
      DatabaseReference ref = FirebaseDatabase.instance
          .ref()
          .child("drivers")
          .child(currentUser.uid)
          .child("status");

      await ref.set("online");
      print("Driver status updated to online");

      // Set the new ride status
      DatabaseReference rideStatusRef = FirebaseDatabase.instance
          .ref()
          .child("drivers")
          .child(currentUser.uid)
          .child("newRideStatus");

      await rideStatusRef.set("idle");
      print("Ride status set to idle");

      // Set the initial location in Firebase (latitude, longitude, timestamp)
      DatabaseReference locationRef = FirebaseDatabase.instance
          .ref()
          .child("drivers")
          .child(currentUser.uid)
          .child("location");

      await locationRef.set({
        "latitude": DriverCurrentPosition!.latitude,
        "longitude": DriverCurrentPosition!.longitude,
        "timestamp": DateTime.now().toIso8601String(),
      });
      print("Initial driver location set in Firebase");
    } catch (error) {
      print("Error: $error");
    }
  }

  // Update driver's location in real-time
  void updateDriversLocationRealTime() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("No current user found.");
      return;
    }

    streamSubscriptionDriverLivePosition =
        Geolocator.getPositionStream().listen((Position position) {
      DriverCurrentPosition = position;
      if (isDriverActive) {
        print("Updating location in Geofire...");
        Geofire.setLocation(
            currentUser.uid, position.latitude, position.longitude);

        // Update the driver's location in Firebase
        DatabaseReference ref = FirebaseDatabase.instance
            .ref()
            .child("drivers")
            .child(currentUser.uid)
            .child("location");

        ref.set({
          "latitude": position.latitude,
          "longitude": position.longitude,
          "timestamp": DateTime.now().toIso8601String(),
        }).then((_) {
          print("Driver location updated");
        }).catchError((error) {
          print("Error updating location: $error");
        });

        LatLng latLng = LatLng(position.latitude, position.longitude);
        newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
      }
    });
  }

  // Set driver as offline and stop updating location
  Future<void> driverIsOfflineNow() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("No current user found.");
      return;
    }

    try {
      // Remove the driver from Geofire
      print("Removing driver from Geofire...");
      await Geofire.removeLocation(currentUser.uid);
      print("Driver removed from Geofire");

      // Update the driver's status to "offline" in Firebase
      DatabaseReference ref = FirebaseDatabase.instance
          .ref()
          .child("drivers")
          .child(currentUser.uid)
          .child("status");

      await ref.set("offline");
      print("Driver status updated to offline");
    } catch (error) {
      print("Error: $error");
    }
  }
}

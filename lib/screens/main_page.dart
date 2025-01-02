import 'dart:async';
import 'package:bus_tracking_app/Assistants/assistants_methods.dart';
import 'package:bus_tracking_app/global/global.dart';
import 'package:bus_tracking_app/global/map_key.dart';
import 'package:bus_tracking_app/infoHandler/app_info.dart';
import 'package:bus_tracking_app/models/directions.dart';
import 'package:bus_tracking_app/widgets/progress_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoder2/geocoder2.dart';
import 'package:provider/provider.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
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

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  // Récupérer la position actuelle de l'utilisateur
  Future<void> _getDriverLocation() async {
    DriverCurrentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    LatLng latLngPosition = LatLng(
        DriverCurrentPosition!.latitude, DriverCurrentPosition!.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 16);
    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress =
        await AssistantsMethods.searchAddressForGeographicCordinates(
            DriverCurrentPosition!, context);
  }

  readCurrentDriverInformation() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("No current user found.");
      return; // Handle no user logged in
    }

    // Reading driver data from Firebase Realtime Database
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentUser.uid)
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        // Assuming onlineDriverData is a class where you store the driver info
        Map<dynamic, dynamic> driverData =
            snap.snapshot.value as Map<dynamic, dynamic>;

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
    }).catchError((e) {
      print("Error reading driver data: $e");
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkIfLocationPermissionAllowed();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          padding: EdgeInsets.only(top: 40),
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

        //ui for online n offline driver
        statusText != "Now Online"
            ? Container(
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                color: Colors.black87,
              )
            : Container(),
        //button for online offline driver
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
                      padding: EdgeInsets.symmetric(horizontal: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      )),
                  child: statusText != "Now Online"
                      ? Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
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

  DriverisOnlineNow() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    DriverCurrentPosition = position;

    // Initialize Geofire and set the driver's location
    Geofire.initialize("activeDrivers");
    Geofire.setLocation(currentUser!.uid, DriverCurrentPosition!.latitude,
        DriverCurrentPosition!.longitude);

    // Update the driver's status to "online" in Firebase
    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentUser!.uid)
        .child("status");

    ref.set("online").then((_) {
      print("Driver status updated to online");
    }).catchError((error) {
      print("Error updating status: $error");
    });

    // Set the new ride status (this can be customized based on your needs)
    DatabaseReference rideStatusRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentUser!.uid)
        .child("newRideStatus");

    rideStatusRef.set("idle").then((_) {
      print("Ride status set to idle");
    }).catchError((error) {
      print("Error setting ride status: $error");
    });
  }

  updateDriversLocationRealTime() {
    streamSubscriptionDriverLivePosition =
        Geolocator.getPositionStream().listen((Position position) {
      if (isDriverActive == true) {
        Geofire.setLocation(currentUser!.uid, DriverCurrentPosition!.latitude,
            DriverCurrentPosition!.longitude);
      }
      LatLng latLng = LatLng(
          DriverCurrentPosition!.latitude, DriverCurrentPosition!.longitude);
      newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  driverIsOfflineNow() {
    Geofire.removeLocation(currentUser!.uid);
    DatabaseReference? ref = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentUser!.uid)
        .child("newRideStatus");
    ref.onDisconnect();
    ref.remove();
    ref = null;
    Future.delayed(Duration(milliseconds: 2000), () {
      SystemChannels.platform.invokeMethod("SystemNavigator.pop");
    });
  }
}

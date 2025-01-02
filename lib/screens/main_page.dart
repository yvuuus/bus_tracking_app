import 'dart:async';
import 'package:bus_tracking_app/Assistants/assistants_methods.dart';
import 'package:bus_tracking_app/global/global.dart';
import 'package:bus_tracking_app/global/map_key.dart';
import 'package:bus_tracking_app/infoHandler/app_info.dart';
import 'package:bus_tracking_app/models/directions.dart';
import 'package:bus_tracking_app/screens/search_places_screen.dart';
import 'package:bus_tracking_app/widgets/progress_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoder2/geocoder2.dart';
import 'package:provider/provider.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  LatLng? pickLocation;
  loc.Location location = loc.Location();
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  bool openNavigationDrawer = false;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 15,
  );

  GoogleMapController? newGoogleMapController;

  String statusText = 'Now offline';
  Color buttonColor = Colors.grey;
  bool isDriverActive = false;

  double bottomPaddingOfMap = 0;
  Position? DriverCurrentPosition;
  bool locationServiceEnabled = false;
  LocationPermission? locationPermission;

  Set<Marker> markerset = {};
  Set<Circle> circleset = {};
  Set<Polyline> polyLineSet = {};
  List<LatLng> pLineCoordinatedList = [];

  String? _address = "";

  late StreamSubscription<Position> streamSubscriptionDriverLivePosition;

  @override
  void initState() {
    super.initState();
    _checkLocationPermissions();
    //_startLocationUpdates();
  }

  Future<void> _checkLocationPermissions() async {
    locationServiceEnabled = await location.serviceEnabled();
    if (!locationServiceEnabled) {
      locationServiceEnabled = await location.requestService();
    }

    locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.denied) {
      locationPermission = await Geolocator.requestPermission();
    }

    if (locationPermission == LocationPermission.deniedForever) {
      _showLocationPermissionDialog();
    } else {
      _getDriverLocation();
    }
  }

  Future<void> _getDriverLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      DriverCurrentPosition = position;
      pickLocation = LatLng(position.latitude, position.longitude);

      markerset.add(Marker(
        markerId: MarkerId("DriverLocation"),
        position: pickLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: "You are here"),
      ));
    });

    GoogleMapController controller = await _controllerGoogleMap.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 14.0,
    )));

    String humanReadableAddress =
        await AssistantsMethods.searchAddressForGeographicCordinates(
            position, context);
    setState(() {
      _address = humanReadableAddress;
    });
  }

  Future<void> updateDriverStatus(bool isOnline, Position position) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isNotEmpty) {
      final driverData = {
        'isOnline': isOnline,
        'location': GeoPoint(position.latitude, position.longitude),
      };
      FirebaseFirestore.instance
          .collection('drivers')
          .doc(userId)
          .set(driverData, SetOptions(merge: true));
    }
  }

  void updateDriverLocationAtRealTime() {
    if (isDriverActive) {
      streamSubscriptionDriverLivePosition =
          Geolocator.getPositionStream().listen((Position position) {
        DriverCurrentPosition = position;
        markerset.clear();
        markerset.add(Marker(
          markerId: MarkerId("DriverLocation"),
          position: LatLng(position.latitude, position.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: "You are here"),
        ));

        newGoogleMapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: 14.0),
          ),
        );

        getAddressFromLatlng();
        updateDriverStatus(true, position);
      });
    }
  }

  void stopDriverLocationUpdates() {
    streamSubscriptionDriverLivePosition.cancel();
    updateDriverStatus(false, DriverCurrentPosition!);
  }

  Future<void> getAddressFromLatlng() async {
    if (DriverCurrentPosition != null) {
      try {
        String humanReadableAddress =
            await AssistantsMethods.searchAddressForGeographicCordinates(
                DriverCurrentPosition!, context);
        setState(() {
          _address = humanReadableAddress;
        });
      } catch (e) {
        print("Error fetching address: $e");
      }
    }
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permission de localisation nécessaire'),
          content: Text(
              'Veuillez activer la localisation dans les paramètres de votre appareil pour utiliser cette fonctionnalité.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFE1BEE7),
        title: Text('Map Screen'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            markers: markerset,
            circles: circleset,
            polylines: polyLineSet,
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;

              setState(() {
                bottomPaddingOfMap = 200;
              });
              _getDriverLocation();
            },
            onCameraMove: (CameraPosition? position) {
              if (pickLocation != position!.target) {
                setState(() {
                  pickLocation = position.target;
                });
              }
            },
            onCameraIdle: () {
              getAddressFromLatlng();
            },
            onTap: (_) {
              if (!isDriverActive) {
                setState(() {
                  isDriverActive = true;
                  updateDriverStatus(true, DriverCurrentPosition!);
                  updateDriverLocationAtRealTime(); // Start location updates
                });
              } else {
                setState(() {
                  isDriverActive = false;
                  stopDriverLocationUpdates(); // Stop location updates
                });
              }
            },
          ),
          if (!isDriverActive)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

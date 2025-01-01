// ignore_for_file: use_build_context_synchronously

import "dart:async";
import "package:bus_tracking_app/Assistants/assistants_methods.dart";
import "package:bus_tracking_app/global/global.dart";
import "package:bus_tracking_app/global/map_key.dart";
import "package:bus_tracking_app/infoHandler/app_info.dart";
import "package:bus_tracking_app/models/directions.dart";
import "package:bus_tracking_app/screens/search_places_screen.dart";
import "package:bus_tracking_app/widgets/progress_dialog.dart";
import "package:flutter/material.dart";
import "package:geolocator/geolocator.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import 'package:location/location.dart' as loc;
import 'package:geocoder2/geocoder2.dart';
import "package:provider/provider.dart";
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

  bool openNavigationDrawer = false; // Ajouter ceci au début de votre classe

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 15,
  );

  GoogleMapController? newGoogleMapController;

  double bottomPaddingOfMap = 0;
  Position? userCurrentPosition;
  bool locationServiceEnabled = false;
  LocationPermission? locationPermission;

  Set<Marker> markerset = {};
  Set<Circle> circleset = {};
  Set<Polyline> polyLineSet = {};
  List<LatLng> pLineCoordinatedList = [];

  String? _address = "";

  @override
  void initState() {
    super.initState();
    _checkLocationPermissions();
  }

  // Vérifier si les permissions de localisation sont accordées
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
      // Demander à l'utilisateur d'activer la localisation
      _showLocationPermissionDialog();
    } else {
      _getUserLocation();
    }
  }

  Future<void> drawPolylineFromOriginToDestination() async {
    var originPosition =
        Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationPosition =
        Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    var originLatlng = LatLng(
        originPosition!.locationLatitude!, originPosition.locationLongitude!);

    var destinationLatlng = LatLng(destinationPosition!.locationLatitude!,
        destinationPosition.locationLongitude!);

    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: "please wait ...",
            ));

    var directionDetailsInfo =
        await AssistantsMethods.obtainOriginToDestinationDirectionDetails(
            originLatlng, destinationLatlng);

    setState(() {
      tripDirectionDetailsInfo = directionDetailsInfo;
    });
    Navigator.pop(context);

    PolylinePoints pPoints = PolylinePoints();

    List<PointLatLng> decodePolyLinePointsResultList =
        pPoints.decodePolyline(directionDetailsInfo.e_points!);

    pLineCoordinatedList.clear();

    if (decodePolyLinePointsResultList.isNotEmpty) {
      decodePolyLinePointsResultList.forEach((PointLatLng pointLatLng) {
        pLineCoordinatedList
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polyLineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.blue,
        polylineId: PolylineId("PolylineId"),
        jointType: JointType.round,
        points: pLineCoordinatedList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 5,
      );

      polyLineSet.add(polyline);
    });

    LatLngBounds boundsLatLng;

    if (originLatlng.latitude > destinationLatlng.latitude &&
        originLatlng.longitude > destinationLatlng.longitude) {
      boundsLatLng =
          LatLngBounds(southwest: destinationLatlng, northeast: originLatlng);
    } else if (originLatlng.longitude > destinationLatlng.longitude) {
      boundsLatLng = LatLngBounds(
          southwest: LatLng(originLatlng.latitude, destinationLatlng.longitude),
          northeast:
              LatLng(destinationLatlng.latitude, originLatlng.longitude));
    } else if (originLatlng.latitude > destinationLatlng.latitude) {
      boundsLatLng = LatLngBounds(
          southwest: LatLng(destinationLatlng.latitude, originLatlng.longitude),
          northeast:
              LatLng(originLatlng.latitude, destinationLatlng.longitude));
    } else {
      boundsLatLng =
          LatLngBounds(southwest: originLatlng, northeast: destinationLatlng);
    }

    newGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));
  }

  // Récupérer la position actuelle de l'utilisateur
  Future<void> _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      userCurrentPosition = position;
      pickLocation = LatLng(position.latitude, position.longitude);

      // Ajouter le marqueur rouge statique à la position de l'utilisateur
      markerset.add(Marker(
        markerId: MarkerId("userLocation"),
        position: pickLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: "You are here"),
      ));
    });

    print("User position: ${position.latitude}, ${position.longitude}");

    // Déplacer la caméra
    GoogleMapController controller = await _controllerGoogleMap.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 14.0,
    )));

    // Récupérer l'adresse
    String humanReadableAddress =
        await AssistantsMethods.searchAddressForGeographicCordinates(
            position, context);

    setState(() {
      _address =
          humanReadableAddress; // Mise à jour de l'adresse pour l'affichage
    });

    print("this is our address = $humanReadableAddress");
  }

  // Fonction pour récupérer l'adresse en fonction des coordonnées lat/long
  Future<void> getAddressFromLatlng() async {
    if (userCurrentPosition != null) {
      try {
        // Utilisation de l'API géocode de Google pour obtenir l'adresse la plus complète
        String humanReadableAddress =
            await AssistantsMethods.searchAddressForGeographicCordinates(
                userCurrentPosition!,
                context); // Utiliser userCurrentPosition ici

        setState(() {
          Directions userPickUpAddress = Directions(
            locationLatitude: pickLocation!.latitude,
            locationLongitude: pickLocation!.longitude,
            locationName: humanReadableAddress,
          );
          Provider.of<AppInfo>(context, listen: false)
              .updatePickUpLocationAddress(userPickUpAddress);
          // _address = humanReadableAddress;
        });

        print("Fetched address: $_address"); // Afficher dans les logs
      } catch (e) {
        print("Error fetching address: $e");
      }
    } else {
      print("User position is null.");
    }
  }

  // Afficher une boîte de dialogue pour demander l'activation de la localisation
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
            myLocationEnabled: false, // Désactive le marqueur par défaut
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
              _getUserLocation();
            },

            onCameraMove: (CameraPosition? position) {
              if (pickLocation != position!.target) {
                setState(() {
                  pickLocation = position.target;
                });
              }
            },

            onCameraIdle: () {
              getAddressFromLatlng(); // Récupérer l'adresse après chaque mouvement de la caméra
            },
          ),
          // Afficher un indicateur de position lorsque la position est en cours de récupération
          if (userCurrentPosition == null)
            Center(
              child: CircularProgressIndicator(),
            ),

          //Ui for searching location
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(5),
                                child: Row(
                                  children: [
                                    Icon(Icons.location_on_outlined,
                                        color: Colors.blue),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "from ",
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                            Provider.of<AppInfo>(context)
                                                        .userPickUpLocation !=
                                                    null
                                                ? Provider.of<AppInfo>(context)
                                                    .userPickUpLocation!
                                                    .locationName!
                                                    .substring(0, 31)
                                                : "No Address found",
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14))
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Divider(
                                height: 1,
                                thickness: 2,
                                color: Colors.blue,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Padding(
                                padding: EdgeInsets.all(5),
                                child: GestureDetector(
                                  onTap: () async {
                                    //go to search places screen
                                    var responseFromSearchScreen =
                                        await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (c) =>
                                                    SearchPlacesScreen()));
                                    if (responseFromSearchScreen ==
                                        "obtainedDropoff ") {
                                      setState(() {
                                        openNavigationDrawer = false;
                                      });
                                    }

                                    await drawPolylineFromOriginToDestination();
                                  },
                                  child: Row(
                                    children: [
                                      Icon(Icons.location_on_outlined,
                                          color: Colors.blue),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "To",
                                            style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            Provider.of<AppInfo>(context)
                                                        .userDropOffLocation !=
                                                    null
                                                ? Provider.of<AppInfo>(context)
                                                    .userDropOffLocation!
                                                    .locationName!
                                                : "Where to?",
                                            style: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 14),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
          //Positioned(
          // top: 40,
          //right: 20,
          //left: 20,
          //child: Container(
          // decoration: BoxDecoration(
          //  border: Border.all(color: Colors.black),
          //  color: const Color.fromARGB(255, 252, 249, 249),
          //),
          //padding: EdgeInsets.all(20),
          //child: Text(
          // _address != null
          //   ? (_address!.length > 24
          //       ? _address!.substring(0, 24) + "..."
          //      : _address!)
          // : "Not Getting Address ",
          // overflow: TextOverflow.visible,
          // softWrap: true,
          //style: TextStyle(
          //    fontSize: 16,
          //    fontWeight: FontWeight.bold,
          //    color: Color.fromARGB(255, 19, 15, 15)),
          // ),
          //),
          // ),
        ],
      ),
    );
  }
}

import 'dart:async';


import 'package:bus_tracking_app/models/driver_info_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:geolocator/geolocator.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? currentUser;

String userDropOffAddress = "";

StreamSubscription<Position>? streamSubscriptionPosition;
StreamSubscription<Position>? streamSubscriptionDriverLivePosition;
// ignore: non_constant_identifier_names
Position? DriverCurrentPosition;
DriverInfoModel onlineDriverData = DriverInfoModel(id: '', name: '', email: '', carName: '', carPlateNum: '', carType: '', address: '');

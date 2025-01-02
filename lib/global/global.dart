import 'dart:async';

import 'package:bus_tracking_app/models/direction_detail_info.dart';
import 'package:geolocator/geolocator.dart';

String userDropOffAddress = "";

DirectionDetailsInfo? tripDirectionDetailsInfo;
StreamSubscription<Position>? streamSubscriptionPosition;
StreamSubscription<Position>? streamSubscriptionDriverLivePosition;

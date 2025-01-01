import 'package:bus_tracking_app/Assistants/request_assistant.dart';
import 'package:bus_tracking_app/global/map_key.dart';
import 'package:bus_tracking_app/infoHandler/app_info.dart';
import 'package:bus_tracking_app/models/directions.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:bus_tracking_app/models/direction_detail_info.dart';

class AssistantsMethods {
  static Future<String> searchAddressForGeographicCordinates(
      Position position, context) async {
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapkey";

    String humanReadableAddress = "";
    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);

    if (requestResponse != "error occured , failed no response" &&
        requestResponse["results"] != null &&
        requestResponse["results"].isNotEmpty) {
      // Récupérer l'adresse complète si disponible
      var addressComponents =
          requestResponse["results"][0]["address_components"];

      if (addressComponents != null && addressComponents.isNotEmpty) {
        humanReadableAddress = addressComponents
            .map((component) => component["long_name"])
            .join(", ");
      } else {
        humanReadableAddress =
            requestResponse["results"][0]["formatted_address"];
      }

      print("Address found: $humanReadableAddress");

      // Créer un objet Directions
      Directions userPickUpAddress = Directions(
        locationLatitude: position.latitude,
        locationLongitude: position.longitude,
        locationName: humanReadableAddress,
      );

      // Mettre à jour l'adresse de ramassage
      Provider.of<AppInfo>(context, listen: false)
          .updatePickUpLocationAddress(userPickUpAddress);
    } else {
      print("No results found in the API response.");
      humanReadableAddress = "Address not found";
    }

    return humanReadableAddress;
  }

  static Future<DirectionDetailsInfo> obtainOriginToDestinationDirectionDetails(
      LatLng originPosition, LatLng destinationPosition) async {
    String urlOriginToDestinationDirectionDetails =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapkey";
    var responseDirectionApi = await RequestAssistant.receiveRequest(
        urlOriginToDestinationDirectionDetails);

    //if (responseDirectionApi == "error occurred, failed no response") {
    // return null;
    //}

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();

    directionDetailsInfo.e_points = directionDetailsInfo.e_points =
        responseDirectionApi["routes"][0]["overview_polyline"]["points"];

    directionDetailsInfo.distance_value =
        responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];
    directionDetailsInfo.distance_text =
        responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];

    directionDetailsInfo.duration_value =
        responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];
    directionDetailsInfo.duration_text =
        responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];

    return directionDetailsInfo;
  }
}

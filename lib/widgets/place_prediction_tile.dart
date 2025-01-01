import 'package:bus_tracking_app/Assistants/request_assistant.dart';
import 'package:bus_tracking_app/global/global.dart';
import 'package:bus_tracking_app/global/map_key.dart';
import 'package:bus_tracking_app/infoHandler/app_info.dart';
import 'package:bus_tracking_app/models/directions.dart';
import 'package:bus_tracking_app/models/predicted_places.dart';
import 'package:bus_tracking_app/widgets/progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlacePredictionTileDesign extends StatefulWidget {
  final PredictedPlaces? predictedPlace;

  PlacePredictionTileDesign({Key? key, this.predictedPlace}) : super(key: key);

  @override
  State<PlacePredictionTileDesign> createState() =>
      _PlacePredictionTileDesignState();
}

class _PlacePredictionTileDesignState extends State<PlacePredictionTileDesign> {
  getPlaceDirectionDetails(String? placeId, context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: "Setting Drop-off. Please wait...",
            ));

    String placeDirectionDetailsUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapkey";

    var responseapi =
        await RequestAssistant.receiveRequest(placeDirectionDetailsUrl);

    Navigator.pop(context);

    if (responseapi == "error occurred, failed no response") {
      return;
    }

    if (responseapi["status"] == "OK") {
      Directions directions = Directions();
      directions.locationName = responseapi["result"]["name"];
      directions.locationId = placeId;
      directions.locationLatitude =
          responseapi["result"]["geometry"]["location"]["lat"];
      directions.locationLongitude =
          responseapi["result"]["geometry"]["location"]["lng"];

      // Mise à jour correcte du drop-off dans AppInfo
      Provider.of<AppInfo>(context, listen: false)
          .updateDropOffLocationAddress(directions);

      setState(() {
        // Mise à jour de l'adresse drop-off
        // Assurez-vous que userDropOffAddress est bien défini dans votre classe
        userDropOffAddress = directions.locationName!;
      });

      Navigator.pop(context, 'obtainedDropoff');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Appel de la méthode pour obtenir les détails de l'adresse
        getPlaceDirectionDetails(widget.predictedPlace!.place_id, context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(
              Icons.add_location,
              color: Color(0xFFE1BEE7),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.predictedPlace!.main_text!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFE1BEE7),
                    ),
                  ),
                  Text(
                    widget.predictedPlace!.secondary_text!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFE1BEE7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

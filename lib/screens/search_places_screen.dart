import "package:bus_tracking_app/Assistants/request_assistant.dart";
import "package:bus_tracking_app/global/map_key.dart";
import "package:bus_tracking_app/models/predicted_places.dart";
import "package:bus_tracking_app/widgets/place_prediction_tile.dart";
import "package:flutter/material.dart";

class SearchPlacesScreen extends StatefulWidget {
  const SearchPlacesScreen({super.key});

  @override
  State<SearchPlacesScreen> createState() => _SearchPlacesScreenState();
}

class _SearchPlacesScreenState extends State<SearchPlacesScreen> {
  List<PredictedPlaces> placesPredictedList = [];

  findPlaceAutoCompleteSearch(String inputText) async {
    if (inputText.length > 1) {
      String urlAutoCompleteSearch =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapkey&components=country:DZ";

      var responseAutoCompleteSearch =
          await RequestAssistant.receiveRequest(urlAutoCompleteSearch);

      if (responseAutoCompleteSearch == "error occured , failed no response") {
        return;
      }

      if (responseAutoCompleteSearch["status"] == "OK") {
        var placePredictions = responseAutoCompleteSearch["predictions"];

        var placePredictionList = (placePredictions as List)
            .map((jsonData) => PredictedPlaces.fromJson(jsonData))
            .toList();

        setState(() {
          placesPredictedList = placePredictionList;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Color(0xFFE1BEE7),
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back, color: Colors.white),
          ),
          title: Text(
            "Search & set dropoff location ",
            style: TextStyle(color: Colors.white),
          ),
          elevation: 0.0,
        ),
        body: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFE1BEE7),
                boxShadow: [
                  BoxShadow(
                      color: Colors.white54,
                      blurRadius: 8,
                      spreadRadius: 0.5,
                      offset: Offset(
                        0.7,
                        0.7,
                      ))
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.adjust_sharp,
                          color: Colors.white,
                        ),
                        SizedBox(
                          height: 18.0,
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: TextField(
                              onChanged: (value) {
                                findPlaceAutoCompleteSearch(value);
                              },
                              decoration: InputDecoration(
                                  hintText: "Search location here ...",
                                  fillColor: Colors.white54,
                                  filled: true,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(
                                    left: 11,
                                    top: 11,
                                    bottom: 8,
                                  )),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),

            // Display Place Predicted Results
            (placesPredictedList.length > 0)
                ? Expanded(
                    child: ListView.separated(
                    itemCount: placesPredictedList.length,
                    physics: ClampingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return PlacePredictionTileDesign(
                        predictedPlace: placesPredictedList[index],
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider(
                        height: 0,
                        color: Color(0xFFE1BEE7),
                        thickness: 0,
                      );
                    },
                  ))
                : Container(),
          ],
        ),
      ),
    );
  }
}

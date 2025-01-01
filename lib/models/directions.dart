class Directions {
  String? humanReadableAdress;
  String? locationName;
  String? locationId;
  double? locationLatitude;
  double?
      locationLongitude; // Corrigez ici le nom pour correspondre au paramètre du constructeur.

  Directions({
    this.humanReadableAdress,
    this.locationId,
    this.locationName,
    this.locationLatitude,
    this.locationLongitude, // Changez `locationLongititude` en `locationLongitude` ici.
  });
}

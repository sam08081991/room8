class Room {
  String ownerEmail;
  List<String> photoUrls;
  String address;
  String area;
  int numberOfSlots;
  int neededSlots;
  bool hasAttic;
  bool isFreeEntrance;
  String price;

  Room(
      {this.ownerEmail,
      this.photoUrls,
      this.address,
      this.area,
      this.numberOfSlots,
      this.neededSlots,
      this.hasAttic,
      this.isFreeEntrance,
      this.price});
}

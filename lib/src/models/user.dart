class User {
  String name;
  String email;
  String phone;
  String id;
  String photoUrl;
  String roomId;

  User(
      {this.id, this.email, this.name, this.phone, this.photoUrl, this.roomId});

  User.fromMap(Map<String, dynamic> mapData) {
    this.id = mapData['id'];
    this.name = mapData['name'];
    this.email = mapData['email'];
    this.phone = mapData['phone'];
    this.photoUrl = mapData['photourl'];
    this.roomId = mapData['roomId'];
  }
}

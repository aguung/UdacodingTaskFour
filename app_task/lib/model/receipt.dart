import 'package:cloud_firestore/cloud_firestore.dart';

class Receipt {
  String key;
  String name;
  String description;
  String photoUrl;
  String createdKey;
  String createdName;
  DateTime updatedAt;
  DateTime createdAt;

  Receipt(
      {this.key,
      this.name,
      this.description,
      this.photoUrl,
      this.createdKey,
      this.createdName,
      this.updatedAt,
      this.createdAt});

  Receipt.fromMap(DocumentSnapshot snapshot, String key)
      : key = key ?? '',
        name = snapshot['name'] ?? '',
        description = snapshot['description'] ?? '',
        photoUrl = snapshot['photoUrl'] ?? '',
        createdKey = snapshot['createdKey'] ?? '',
        createdName = snapshot['createdName'] ?? '',
        updatedAt = snapshot['updatedAt'].toDate(),
        createdAt = snapshot['createdAt'].toDate();

  toUpdate() {
    return {
      "name": name,
      "description": description,
      "updatedAt": updatedAt,
    };
  }

  toCreate() {
    return {
      "name": name,
      "description": description,
      "createdKey": createdKey,
      "createdName": createdName,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "photoUrl": photoUrl
    };
  }
}

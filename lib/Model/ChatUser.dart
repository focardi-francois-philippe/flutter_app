import 'package:cloud_firestore/cloud_firestore.dart';

class ChatUser {
  final String id;
  final String displayName;
  final String? bio;

  ChatUser({
    required this.id,
    required this.displayName,
    this.bio,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'bio': bio,
    };
  }

  factory ChatUser.fromDocument(DocumentSnapshot doc) {
    return ChatUser(
      id: doc['id'],
      displayName: doc['displayName'],
      bio: doc['bio'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'displayName': displayName,
      'bio': bio,
      // Ajoutez d'autres propriétés de l'utilisateur ici en fonction de vos besoins
    };
  }
  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'],
      displayName: json['displayName'],
      bio: json['bio'],
    );
  }

  @override
  String toString() {
    return 'Nom: $displayName, Bio: ${bio ?? "Non disponible"}';
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Model/ChatMessage.dart';

class ChatPage extends StatefulWidget {
  final String userId;
  final String displayName;

  ChatPage({required this.userId, required this.displayName});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<List<ChatMessage>> _messagesStream = Stream.empty();
  final TextEditingController _messageController = TextEditingController();
  late String currentUserId = '';
  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
  Future<String> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id') ?? 'ID non trouvé';
  }
  @override
  void initState() {
    super.initState();
    getUserId().then((value) => currentUserId = value);
    _initializeMessagesStream();
  }
  void _sendMessage(String messageText) async {
    // Obtenir l'ID de l'utilisateur actuel


    // Créer un objet pour le message
    Map<String, dynamic> messageData = {
      'from': currentUserId,
      'to': widget.userId,
      'content': messageText,
      'timestamp': FieldValue.serverTimestamp(), // Horodatage défini par le serveur
    };

    // Envoyer le message à Firestore
    try {
      await FirebaseFirestore.instance.collection('messages').add(messageData);
      // Afficher un message de succès ou effectuer une action supplémentaire si nécessaire
    } catch (e) {
      // Gérer les erreurs ici, par exemple afficher un message d'erreur
      print('Erreur lors de l\'envoi du message: $e');
    }
  }

  void _initializeMessagesStream() async {
    currentUserId = await getUserId();
    Stream<List<ChatMessage>> _receivedMessagesStream;
    _messagesStream = FirebaseFirestore.instance
        .collection('messages')
        .where('from', isEqualTo: currentUserId)
        .where('to', isEqualTo: widget.userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ChatMessage.fromDocument(doc))
        .toList());

    _receivedMessagesStream = FirebaseFirestore.instance
        .collection('messages')
        .where('from', isEqualTo: widget.userId)
        .where('to', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ChatMessage.fromDocument(doc))
        .toList());

    // Fusion des deux flux
    _messagesStream = Rx.combineLatest2(
      _messagesStream,
      _receivedMessagesStream,
          (List<ChatMessage> sentMessages, List<ChatMessage> receivedMessages) {
        return [...sentMessages, ...receivedMessages]..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      },
    );

    setState(() {}); // Pour notifier le widget d'une mise à jour
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat avec ${widget.displayName}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Erreur: ${snapshot.error}');
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Aucun message.');
                }

                List<ChatMessage> messages = snapshot.data!;

                return ListView.builder(
                  itemCount: messages.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    ChatMessage message = messages[index];
                    bool isSentByMe = message.from == currentUserId;

                    return Align(
                      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSentByMe ? Colors.blue : Colors.deepOrange  ,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          message.content,
                          style: TextStyle(
                            color: Colors.white
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Écrire un message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    String messageText = _messageController.text;
                    if (messageText.isNotEmpty) {
                      _sendMessage(messageText);
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



}





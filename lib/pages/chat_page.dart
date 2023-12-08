import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superchat/Bloc/ChatMessage/ChatMessageBloc.dart';
import 'package:superchat/Bloc/ChatMessage/ChatMessageEvent.dart';
import 'package:superchat/Bloc/ChatMessage/ChatMessageState.dart';

import '../Model/ChatMessage.dart';

class ChatPage extends StatelessWidget {
  final String userId;
  final String displayName;

  ChatPage({required this.userId, required this.displayName});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatMessageBloc(userId, displayName),
      child: _ChatPageView(userId: userId, displayName: displayName),
    );
  }
}

class _ChatPageView extends StatelessWidget {
  final TextEditingController _messageController = TextEditingController();
  late final String userId;
  late final String displayName;

  _ChatPageView({required this.userId, required this.displayName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat avec $displayName'),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatMessageBloc, ChatMessageState>(
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const CircularProgressIndicator();
                }
                if (state is ChatError) {
                  return Text('Erreur: ${state.error}');
                }
                if (state is ChatLoaded) {
                  List<ChatMessage> messages = state.messages;
                  return ListView.builder(
                    itemCount: messages.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      ChatMessage message = messages[index];
                      bool isSentByMe = message.from !=
                          userId; // Assurez-vous que cette logique est correcte

                      return Align(
                        alignment: isSentByMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          margin:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSentByMe ? Colors.blue : Colors.deepOrange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            message.content,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  );
                }
                return const Text('Aucun message.');
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
                      BlocProvider.of<ChatMessageBloc>(context)
                          .add(SendMessageEvent(messageText));
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

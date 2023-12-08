import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superchat/Bloc/ChatMessage/chat_message_event.dart';
import 'package:superchat/Bloc/ChatMessage/chat_message_state.dart';
import 'package:superchat/Utils.dart';

import '../../Model/ChatMessage.dart';

class ChatMessageBloc extends Bloc<ChatMessageEvent, ChatMessageState> {
  final String UserIdChat;
  final String displayName;

  StreamSubscription? _messagesSubscription;
  ChatMessageBloc(this.UserIdChat,this.displayName) : super(ChatInitial()) {
    on<LoadMessagesEvent>(_onLoadMessages);
    on<SendMessageEvent>(_onSendMessage);

    _messagesSubscription = _loadMessages().listen(
          (messages) {
        emit(ChatLoaded(messages));
      },
      onError: (error) {
        emit(ChatError(error.toString()));
      },
    );
  }
  Future<void> _onLoadMessages(LoadMessagesEvent event, Emitter<ChatMessageState> emit) async {
    emit(ChatLoading());
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatMessageState> emit) async {
    emit(ChatLoading());
    try {
      await _sendMessage(event.messageText);
    } catch (e) {
      emit(ChatError(e.toString()));
    }

  }





  Stream<List<ChatMessage>>  _loadMessages()  async* {
    var currentUserId = await Utils.getCurrentUserId();

    var sentMessagesStream = FirebaseFirestore.instance
        .collection('messages')
        .where('from', isEqualTo: currentUserId)
        .where('to', isEqualTo: UserIdChat)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ChatMessage.fromDocument(doc)).toList());

    var receivedMessagesStream = FirebaseFirestore.instance
        .collection('messages')
        .where('from', isEqualTo: UserIdChat)
        .where('to', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ChatMessage.fromDocument(doc)).toList());

    yield* Rx.combineLatest2(sentMessagesStream, receivedMessagesStream, (List<ChatMessage> sentMessages, List<ChatMessage> receivedMessages) {
      var combinedMessages = [...sentMessages, ...receivedMessages];
      combinedMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return combinedMessages;
    });
  }


  Future<void> _sendMessage(String messageText) async {
    // Créer un objet pour le message
    var currentUserId = Utils.getCurrentUserId();
    if (currentUserId == null) {
      emit(ChatError('Impossible d\'envoyer le message: aucun utilisateur connecté'));
      return;
    }
    Map<String, dynamic> messageData = {
      'from': currentUserId,
      'to': UserIdChat,
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




}
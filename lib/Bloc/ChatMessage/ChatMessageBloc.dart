import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superchat/Bloc/ChatMessage/ChatMessageEvent.dart';
import 'package:superchat/Bloc/ChatMessage/ChatMessageState.dart';

import '../../Model/ChatMessage.dart';

class ChatMessageBloc extends Bloc<ChatMessageEvent, ChatMessageState> {
  final String otherUserId;
  final String displayName;

  StreamSubscription? _messagesSubscription;
  ChatMessageBloc(this.otherUserId,this.displayName) : super(ChatInitial()) {
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


  }





  Stream<List<ChatMessage>>  _loadMessages()  async* {
    var currentUserId = await getUserId();

    var sentMessagesStream = FirebaseFirestore.instance
        .collection('messages')
        .where('from', isEqualTo: currentUserId)
        .where('to', isEqualTo: otherUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ChatMessage.fromDocument(doc)).toList());

    var receivedMessagesStream = FirebaseFirestore.instance
        .collection('messages')
        .where('from', isEqualTo: otherUserId)
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

  }
  Future<String> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id') ?? 'ID non trouvé';
  }
}
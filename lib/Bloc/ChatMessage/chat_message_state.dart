import '../../Model/ChatMessage.dart';

abstract class ChatMessageState {}

class ChatInitial extends ChatMessageState {}

class ChatLoading extends ChatMessageState {}

class ChatLoaded extends ChatMessageState {
  final List<ChatMessage> messages;
  ChatLoaded(this.messages);
}

class ChatError extends ChatMessageState {
  final String error;
  ChatError(this.error);
}
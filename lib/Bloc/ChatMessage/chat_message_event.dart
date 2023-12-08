abstract class ChatMessageEvent {}

class LoadMessagesEvent extends ChatMessageEvent {}

class SendMessageEvent extends ChatMessageEvent {
  final String messageText;
  SendMessageEvent(this.messageText);
}
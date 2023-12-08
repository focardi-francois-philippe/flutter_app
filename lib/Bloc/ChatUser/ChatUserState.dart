import '../../../../Model/ChatUser.dart';

abstract class ChatUserState {}

class ChatUserInitialState extends ChatUserState {}

class ChatUserLoadingState extends ChatUserState {}

class ChatUserLoadedState extends ChatUserState {
  final List<ChatUser> users;

  ChatUserLoadedState(this.users);
}

class ChatUserErrorState extends ChatUserState {
  final String message;

  ChatUserErrorState(this.message);
}
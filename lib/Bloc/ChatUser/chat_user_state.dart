import '../../../../Model/ChatUser.dart';

abstract class ChatUserState {}

class ChatUserInitialState extends ChatUserState {}

class ChatUserLoadingState extends ChatUserState {}

class ChatUsersLoadedState extends ChatUserState {
  final List<ChatUser> users;

  ChatUsersLoadedState(this.users);
}
class ChatUserLoadedState extends ChatUserState {
  final ChatUser user;

  ChatUserLoadedState(this.user);
}

class ChatUserErrorState extends ChatUserState {
  final String message;

  ChatUserErrorState(this.message);
}

class ChatUserUpdateState extends ChatUserState {
  final String bio;
  final String displayName;

  ChatUserUpdateState(this.bio,this.displayName);
}
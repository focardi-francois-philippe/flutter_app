abstract class ChatUserEvent {}

class LoadUsersEvent extends ChatUserEvent {}
class LoadUserEvent extends ChatUserEvent {
  final String userId;
  LoadUserEvent(this.userId);
}
class UpdateUserEvent extends ChatUserEvent {
  final String bio;
  final String displayName;
  UpdateUserEvent(this.bio,this.displayName);
}
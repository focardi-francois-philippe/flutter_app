import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superchat/Utils.dart';

import '../../Model/ChatUser.dart';

import 'chat_user_event.dart';
import 'chat_user_state.dart';



class ChatUserBloc extends Bloc<ChatUserEvent, ChatUserState> {
  ChatUserBloc() : super(ChatUserInitialState()) {
    on<LoadUsersEvent>((event, emit) async {
      emit(ChatUserLoadingState());
      try {
        String currentUserId = Utils.getCurrentUserId()??"";
        final users = await getUsers(currentUserId);
        emit(ChatUsersLoadedState(users));
      } catch (e) {
        emit(ChatUserErrorState(e.toString()));
      }
    });
    on<LoadUserEvent>((event, emit) async {
      emit(ChatUserLoadingState());
      try {
        final user = await getUser(event.userId);
        emit(ChatUserLoadedState(user));
      } catch (e) {
        emit(ChatUserErrorState(e.toString()));
      }
    });
    on<UpdateUserEvent>((event, emit) async {
      emit(ChatUserLoadingState());
      try {
        String currentUserId = Utils.getCurrentUserId()??"";
        var collection = FirebaseFirestore.instance.collection('users');
        var querySnapshot = await collection.where('id', isEqualTo: currentUserId).get();
        var doc = querySnapshot.docs.first;
        doc.reference.update({
          'bio': event.bio,
          'displayName': event.displayName,
        });
        final user = await getUser(currentUserId);
        emit(ChatUserLoadedState(user));
      } catch (e) {
        emit(ChatUserErrorState(e.toString()));
      }
    });
  }

  Future<List<ChatUser>> getUsers(String currentUserId) async {
    var collection = FirebaseFirestore.instance.collection('users');
    var querySnapshot = await collection.where('id', isNotEqualTo: currentUserId).get();

    return querySnapshot.docs.map((doc) => ChatUser.fromDocument(doc)).toList();
  }
  Future<ChatUser> getUser(String userId) async {
    var doc = await FirebaseFirestore.instance.collection('users').where("id",isEqualTo:userId ).get();
    return ChatUser.fromDocument(doc.docs.first);
  }
}

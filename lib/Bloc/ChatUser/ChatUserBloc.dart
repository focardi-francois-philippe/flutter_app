import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superchat/Utils.dart';

import '../../Model/ChatUser.dart';

import 'ChatUserEvent.dart';
import 'ChatUserState.dart';



class ChatUserBloc extends Bloc<ChatUserEvent, ChatUserState> {
  ChatUserBloc() : super(ChatUserInitialState()) {
    on<LoadUsersEvent>((event, emit) async {
      emit(ChatUserLoadingState());
      try {
        String currentUserId = Utils.getCurrentUserId()??"";
        final users = await getUsers(currentUserId);
        emit(ChatUserLoadedState(users));
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
}

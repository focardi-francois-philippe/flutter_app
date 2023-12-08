// user_bloc.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'Model/ChatUser.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Model/ChatUser.dart'; // Assurez-vous que le chemin d'accès est correct
import 'package:firebase_auth/firebase_auth.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UsersInitial()) {
    on<LoadUsers>(_onLoadUsers);
  }

  Future<void> _onLoadUsers(LoadUsers event, Emitter<UserState> emit) async {
    try {
      emit(UsersLoading());
      final users = await _getUsers();
      emit(UsersLoaded(users));
    } catch (e) {
      emit(UsersError(e.toString()));
    }
  }

  Future<List<ChatUser>> _getUsers() async {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    var collection = FirebaseFirestore.instance.collection('users');
    var querySnapshot = await collection.where('userId', isNotEqualTo: currentUserId).get();
    return querySnapshot.docs.map((doc) => ChatUser.fromDocument(doc)).toList();
  }
}

// Ajoutez ici vos classes UserEvent et UserState si nécessaire


abstract class UserEvent {}
class LoadUsers extends UserEvent {
  LoadUsers();
}

abstract class UserState {}
class UsersInitial extends UserState {}
class UsersLoading extends UserState {}
class UsersLoaded extends UserState {
  final List<ChatUser> users;
  UsersLoaded(this.users);
}
class UsersError extends UserState {
  final String message;
  UsersError(this.message);
}

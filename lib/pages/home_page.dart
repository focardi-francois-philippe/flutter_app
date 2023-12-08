

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superchat/constants.dart';
import 'package:superchat/pages/sign_in_page.dart';
import 'package:superchat/widgets/stream_listener.dart';

import '../Bloc/ChatUser/ChatUserBloc.dart';
import '../Bloc/ChatUser/ChatUserEvent.dart';
import '../Bloc/ChatUser/ChatUserState.dart';
import '../Model/ChatUser.dart';
import 'chat_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamListener<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      listener: (user) {
        if (user == null) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const SignInPage()),
                  (route) => false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(kAppTitle),
          backgroundColor: theme.colorScheme.primary,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
    body:
        BlocProvider(
          create: (context) => ChatUserBloc()..add(LoadUsersEvent()),
    child:BlocBuilder<ChatUserBloc, ChatUserState>(
    builder: (context, state) {
    if (state is ChatUserLoadingState) {
    return CircularProgressIndicator();
    }
    if (state is ChatUserLoadedState) {
    return ListView.builder(
    itemCount: state.users.length,
      itemBuilder: (context, index) {
        ChatUser user = state.users[index];
        return ListTile(
          title: Text(user.displayName),
          subtitle: Text(user.bio ?? ''),
          leading: const Icon(Icons.person),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ChatPage(userId: user.id, displayName: user.displayName),
              ),
            );
          },
        );
      },
    );
    }
    if (state is ChatUserErrorState) {
    return Text('Erreur : ${state.message}');
    }
    return const Text('Aucun utilisateur trouvé.');
    },
      ),
    ),
    )
    );
  }


}


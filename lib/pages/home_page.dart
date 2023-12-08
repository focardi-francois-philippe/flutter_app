
/*
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<ChatUser>>? usersFuture;


  @override
  void initState() {
    super.initState();
    _loadUsers();
  }


  Future<String> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId') ?? '';
  }


  Future<List<ChatUser>> getUsers(String currentUserId) async {
    var collection = FirebaseFirestore.instance.collection('users');
    var querySnapshot = await collection.where('userId', isNotEqualTo: currentUserId).get();

    return querySnapshot.docs.map((doc) => ChatUser.fromDocument(doc)).toList();
  }




  void _loadUsers() async {
    String currentUserId = await getUserId();
    setState(() {
      usersFuture = getUsers(currentUserId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ... Votre code existant pour l'appBar, etc.
      body: FutureBuilder<List<ChatUser>>(
        future: usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Erreur : ${snapshot.error}');
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Text('Aucun utilisateur trouvé.');
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              ChatUser user = snapshot.data![index];
              return ListTile(
                title: Text(user.displayName),
                subtitle: Text(user.bio ?? 'Bio non disponible'),
                leading: Icon(Icons.person),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Vous avez sélectionné ${user.displayName}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }


}*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superchat/constants.dart';
import 'package:superchat/pages/sign_in_page.dart';
import 'package:superchat/widgets/stream_listener.dart';

import '../Model/ChatUser.dart';
import 'chat_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Future<String> getUserId() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_id') ?? 'ID non trouvé';
    }

    Future<List<ChatUser>> getUsers(String currentUserId) async {
      var collection = FirebaseFirestore.instance.collection('users');
      var querySnapshot = await collection.where('id', isNotEqualTo: currentUserId).get();

      return querySnapshot.docs.map((doc) => ChatUser.fromDocument(doc)).toList();
    }

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
        body: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<ChatUser>>(
                future: getUserId().then((currentUserId) => getUsers(currentUserId)),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Erreur : ${snapshot.error}');
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('Aucun utilisateur trouvé.');
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      ChatUser user = snapshot.data![index];
                      return ListTile(
                        title: Text(user.toString()),
                        leading: Icon(Icons.person),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ChatPage(userId: user.id,displayName: user.displayName,),
                            ),
                          );
                          // Action à effectuer lorsqu'un utilisateur est sélectionné
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


}


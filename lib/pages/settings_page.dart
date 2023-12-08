import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superchat/Bloc/ChatUser/chat_user_event.dart';
import 'package:superchat/Utils.dart';

import '../Bloc/ChatUser/chat_user_bloc.dart';
import '../Bloc/ChatUser/chat_user_state.dart';

class SettingsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paramètres'),
      ),
      body: BlocProvider(
        create: (context) => ChatUserBloc()..add(LoadUserEvent(Utils.getCurrentUserId()!)),
        child: BlocBuilder<ChatUserBloc, ChatUserState>(
          builder: (context, state) {
            String displayName = '';
            String bio = '';

            if (state is ChatUserLoadingState) {
              return Center(child: CircularProgressIndicator());
            } else if (state is ChatUserLoadedState) {
              displayName = state.user.displayName;
              bio = state.user.bio!;
            } else if (state is ChatUserErrorState) {
              return Center(child: Text('Erreur: ${state.message}'));
            }

            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFormField(
                      initialValue: displayName,
                      decoration: InputDecoration(
                        labelText: 'Nom d\'affichage',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => displayName = value,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      initialValue: bio,
                      decoration: InputDecoration(
                        labelText: 'Bio',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => bio = value,
                      maxLines: 3,
                    ),
                    SizedBox(height: 24),
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            child: Text('Enregistrer'),
                            style:ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.green,
                            ),
                            onPressed: () {
                              BlocProvider.of<ChatUserBloc>(context).add(UpdateUserEvent(bio,displayName));
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            child: Text('Annuler'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.red,
                              ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

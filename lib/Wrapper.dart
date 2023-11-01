import 'package:denario/Authentication/Authenticate.dart';
import 'package:denario/Authentication/Onboarding.dart';
import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Home.dart';
import 'package:denario/Loading.dart';
import 'package:denario/Models/User.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final FirebaseAuth? _auth = FirebaseAuth.instance;

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  User? user;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    if (_auth != null) {
      _auth!.userChanges().listen((User? event) {
        if (event != null) {
          setState(() {
            user = event;
            loading = false;
          });
        } else {
          setState(() {
            loading = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth!.userChanges(), // Listen to the authentication status
      builder: (context, AsyncSnapshot? snapshot) {
        if (loading || snapshot == null) {
          return Loading(); // Show loading widget
        }

        final currentUser = snapshot.data;
        if (currentUser == null) {
          return Authenticate(); // User is not logged in
        }

        if (currentUser.displayName == null || currentUser.displayName == '') {
          return StreamProvider<UserData?>.value(
            initialData: null,
            value: DatabaseService().userProfile(currentUser.uid),
            child: Onboarding(),
          );
        } else {
          return StreamProvider<UserData?>.value(
            initialData: null,
            value: DatabaseService().userProfile(currentUser.uid),
            child: Home(),
          );
        }
      },
    );
  }
}

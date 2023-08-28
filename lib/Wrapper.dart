import 'package:denario/Authentication/Authenticate.dart';
import 'package:denario/Authentication/Onboarding.dart';
import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Home.dart';
import 'package:denario/Loading.dart';
import 'package:denario/Models/User.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  User user;
  bool loading = true;

  @override
  void initState() {
    _auth.userChanges().listen((event) => setState(() {
          user = event;
          loading = false;
        }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      // Show a loading widget while the data is being fetched
      return Loading();
    } else if (user == null && FirebaseAuth.instance.currentUser == null) {
      return Authenticate();
    } else if (user != null) {
      if (user.displayName == null || user.displayName == '') {
        return StreamProvider<UserData>.value(
          initialData: null,
          value: DatabaseService().userProfile(user.uid),
          child: Onboarding(),
        );
      } else {
        return StreamProvider<UserData>.value(
          initialData: null,
          value: DatabaseService().userProfile(user.uid),
          child: Home(),
        );
      }
    } else {
      return Loading();
    }
  }
}

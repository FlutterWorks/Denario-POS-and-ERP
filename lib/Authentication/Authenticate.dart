import 'package:denario/Authentication/LogIn_Web.dart';
import 'package:denario/Authentication/Register.dart';
import 'package:flutter/material.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool showSignIn = true;
  void toggleView() {
    setState(() => showSignIn = !showSignIn);
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width > 650) {
      return Scaffold(
        body: Row(
          children: [
            //Pic
            Expanded(
              flex: (650 < MediaQuery.of(context).size.width &&
                      MediaQuery.of(context).size.width < 850)
                  ? 3
                  : 5,
              child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage('Images/AuthBackground.jpeg'))),
              ),
            ),
            //Auth
            Expanded(
              flex: 3,
              child: Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  height: double.infinity,
                  padding: EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Center(
                      child: (showSignIn)
                          ? LogIn(toggleView: toggleView)
                          : Register(toggleView: toggleView),
                    ),
                  )),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        body: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Center(
                child: (showSignIn)
                    ? LogIn(toggleView: toggleView)
                    : Register(toggleView: toggleView),
              ),
            )),
      );
    }
  }
}

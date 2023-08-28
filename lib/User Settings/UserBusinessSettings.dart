import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Models/Categories.dart';
import 'package:denario/Models/User.dart';
import 'package:denario/User%20Settings/CreateNewBusiness.dart';
import 'package:denario/User%20Settings/UserBusinessSettingsForm.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserBusinessSettings extends StatefulWidget {
  final List<UserBusinessData> userBusinesses;
  final String activeBusiness;
  UserBusinessSettings(this.userBusinesses, this.activeBusiness);

  @override
  State<UserBusinessSettings> createState() => _UserBusinessSettingsState();
}

class _UserBusinessSettingsState extends State<UserBusinessSettings> {
  String selectedBusiness = '';
  int selectedBusinessIndex = 0;
  final controller = PageController();

  @override
  void initState() {
    //Find current business's index
    for (var i = 0; i < widget.userBusinesses.length; i++) {
      if (widget.userBusinesses[i].businessID == widget.activeBusiness) {
        selectedBusinessIndex = i;
      }
    }
    selectedBusiness =
        widget.userBusinesses[selectedBusinessIndex].businessName;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final User user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Container();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //Space
        Expanded(flex: 2, child: Container()),
        SizedBox(width: 30),
        //Settings
        Expanded(
          flex: 6,
          child: PageView.builder(
            controller: controller,
            itemCount: widget.userBusinesses.length,
            physics: NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              return MultiProvider(
                providers: [
                  StreamProvider<BusinessProfile>.value(
                      initialData: null,
                      value: DatabaseService().userBusinessProfile(
                          widget.userBusinesses[index].businessID)),
                  StreamProvider<CategoryList>.value(
                      initialData: null,
                      value: DatabaseService().categoriesList(
                          widget.userBusinesses[index].businessID)),
                ],
                child: UserBusinessSettingsForm(
                    widget.userBusinesses[index].roleInBusiness),
              );
            },
          ),
        ),
        SizedBox(width: 30),
        //List of Businesses
        Expanded(
          flex: 2,
          child: Container(
            width: 150,
            child: ListView.builder(
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemCount: (widget.userBusinesses.length + 1),
                itemBuilder: (context, i) {
                  if (i < widget.userBusinesses.length) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: (selectedBusiness ==
                                  widget.userBusinesses[i].businessName)
                              ? Colors.black
                              : Colors.white,
                          minimumSize: Size(50, 50),
                        ),
                        onPressed: () {
                          setState(() {
                            controller.jumpToPage(i);
                            selectedBusiness =
                                widget.userBusinesses[i].businessName;
                            selectedBusinessIndex = i;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 8),
                          child: Text(
                            widget.userBusinesses[i].businessName,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: (selectedBusiness ==
                                        widget.userBusinesses[i].businessName)
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                    );
                  }
                  return OutlinedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size(50, 50),
                        foregroundColor: Colors.grey),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  StreamProvider<UserData>.value(
                                      initialData: null,
                                      value: DatabaseService()
                                          .userProfile(user.uid.toString()),
                                      child: CreateNewBusiness())));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5.0, horizontal: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.add,
                            size: 16,
                            color: Colors.black,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Crear nuevo',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          ),
        ),
      ],
    );
  }
}

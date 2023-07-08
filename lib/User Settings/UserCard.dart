import 'package:denario/Models/User.dart';
import 'package:denario/User%20Settings/ManageUsersDialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserCard extends StatelessWidget {
  final String businessID;
  const UserCard(this.businessID);

  @override
  Widget build(BuildContext context) {
    final userProfile = Provider.of<UserData>(context);

    if (userProfile == null) {
      return Container();
    }

    final index = userProfile.businesses
        .indexWhere((element) => element.businessID == businessID);

    if (index != null &&
        index != -1 &&
        userProfile.businesses != null &&
        userProfile.businesses != []) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: TextButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.transparent,
          ),
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return ManageUsersDialog(userProfile, index);
                });
          },
          child: Container(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                //Pic
                SizedBox(
                  width: 100,
                  child: Container(
                      height: 35,
                      width: 35,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade300),
                          color: Colors.grey,
                          image: DecorationImage(
                              image: NetworkImage(userProfile.profileImage),
                              fit: BoxFit.scaleDown))),
                ),
                //Name
                Container(
                  width: 100,
                  child: Center(
                      child: Text(
                    userProfile.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )),
                ),
                //Phone
                Container(
                  width: 100,
                  child: Center(
                      child: Text(userProfile.phone.toString(),
                          maxLines: 1, overflow: TextOverflow.ellipsis)),
                ),
                //Rol
                Container(
                  width: 100,
                  child: Center(
                      child: Text(userProfile.businesses[index].roleInBusiness,
                          maxLines: 1, overflow: TextOverflow.ellipsis)),
                )
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      height: 50,
      width: 700,
      color: Colors.grey.shade300,
    );
  }
}

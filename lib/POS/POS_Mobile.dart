import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Loading.dart';
import 'package:denario/Models/Categories.dart';
import 'package:denario/Models/Products.dart';
import 'package:denario/Models/SavedOrders.dart';
import 'package:denario/Models/Tables.dart';
import 'package:denario/Models/User.dart';
import 'package:denario/POS/PlateSelection_Mobile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class POSMobile extends StatefulWidget {
  final String firstCategory;
  final List<Products> productList;
  final GlobalKey<ScaffoldState>? scaffoldKeyMobile;
  POSMobile(this.firstCategory, this.productList, this.scaffoldKeyMobile);

  @override
  _POSMobileState createState() => _POSMobileState();
}

class _POSMobileState extends State<POSMobile> {
  // final GlobalKey<ScaffoldState> _scaffoldKeyMobile =
  //     GlobalKey<ScaffoldState>();

  late String category;
  List categories = [];
  int? businessIndex;
  bool? showTableView;

  //Mostrar mesas o mostrar pendientes de delivery/takeaway
  List tableViewTags = ['Mesas', 'Mostrador'];
  String? selectedTag;

  final tableController = PageController();

  @override
  void initState() {
    category = widget.firstCategory;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesProvider = Provider.of<CategoryList?>(context);
    final userProfile = Provider.of<UserData?>(context);

    if (userProfile == null || categoriesProvider == null) {
      return Container();
    }

    try {
      userProfile.businesses!.forEach((element) {
        if (element.businessID == userProfile.activeBusiness) {
          businessIndex = userProfile.businesses!.indexOf(element);
        }
      });
      categories = categoriesProvider.categoryList!;

      return MultiProvider(
        providers: [
          StreamProvider<List<Tables>>.value(
            initialData: [],
            value: DatabaseService().tableList(userProfile.activeBusiness!),
          ),
          StreamProvider<List<SavedOrders>>.value(
              initialData: [],
              value: DatabaseService()
                  .savedCounterOrders(userProfile.activeBusiness)),
        ],
        child: Stack(
          children: [
            //POS
            CustomScrollView(
              slivers: [
                //Category selection
                SliverAppBar(
                    floating: true,
                    backgroundColor: Colors.white,
                    pinned: false,
                    automaticallyImplyLeading: false,
                    actions: <Widget>[Container()],
                    expandedHeight: 35,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length,
                            itemBuilder: (context, i) {
                              return TextButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: (category == categories[i])
                                      ? Colors.black
                                      : Colors.transparent,
                                  minimumSize: Size(50, 50),
                                ),
                                onPressed: () {
                                  setState(() {
                                    category = categories[i];
                                  });
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5.0),
                                  child: Center(
                                    child: Text(
                                      categories[i],
                                      style: TextStyle(
                                          color: (category == categories[i])
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ),
                    )),
                // Divider(
                //     color: Colors.grey, thickness: 0.5, indent: 15, endIndent: 15),

                //Plates GridView
                PlateSelectionMobile(
                    userProfile.activeBusiness!, category, widget.productList),
              ],
            ),
            //Ticket
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton(
                    onPressed: () =>
                        widget.scaffoldKeyMobile!.currentState!.openEndDrawer(),
                    backgroundColor: Colors.black,
                    child: Center(
                        child: Icon(Icons.format_list_bulleted,
                            color: Colors.white))),
              ),
            )
          ],
        ),
      );
    } catch (e) {
      return Loading();
    }
  }
}

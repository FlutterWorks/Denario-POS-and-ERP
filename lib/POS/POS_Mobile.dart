import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Loading.dart';
import 'package:denario/Models/Categories.dart';
import 'package:denario/Models/Products.dart';
import 'package:denario/Models/SavedOrders.dart';
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

  //Search
  bool search = false;
  String searchName = '';

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
          // StreamProvider<List<Tables>>.value(
          //   initialData: [],
          //   value: DatabaseService().tableList(userProfile.activeBusiness!),
          // ),
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
                //Search By Name
                SliverAppBar(
                    floating: true,
                    backgroundColor: Colors.white,
                    pinned: false,
                    automaticallyImplyLeading: false,
                    actions: <Widget>[Container()],
                    expandedHeight: 10,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5),
                          child: Row(
                            mainAxisAlignment: search
                                ? MainAxisAlignment.start
                                : MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              search
                                  ? Expanded(
                                      child: Container(
                                        // width:
                                        //     (MediaQuery.of(context).size.width >
                                        //             1100)
                                        //         ? 500
                                        //         : 350,
                                        height: 50,
                                        child: TextFormField(
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14),
                                          validator: (val) => val!.isEmpty
                                              ? "Agrega un nombre"
                                              : null,
                                          autofocus: true,
                                          cursorColor: Colors.grey,
                                          cursorHeight: 14,
                                          initialValue: searchName,
                                          textInputAction: TextInputAction.next,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(
                                              Icons.search,
                                              color: Colors.grey,
                                              size: 16,
                                            ),
                                            suffixIcon: IconButton(
                                                tooltip: 'Cerrar',
                                                splashRadius: 25,
                                                onPressed: () {
                                                  setState(() {
                                                    search = false;
                                                  });
                                                },
                                                icon: Icon(
                                                  Icons.close,
                                                  size: 16,
                                                  color: Colors.grey,
                                                )),
                                            errorStyle: TextStyle(
                                                color: Colors.redAccent[700],
                                                fontSize: 12),
                                            border: new OutlineInputBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      12.0),
                                              borderSide: new BorderSide(
                                                color: Colors.grey,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      12.0),
                                              borderSide: new BorderSide(
                                                color: Colors.green,
                                              ),
                                            ),
                                          ),
                                          onChanged: (val) {
                                            setState(() => searchName = val);
                                          },
                                        ),
                                      ),
                                    )
                                  : SizedBox(),
                              //Seach
                              search
                                  ? SizedBox()
                                  : IconButton(
                                      tooltip: 'Buscar',
                                      splashRadius: 25,
                                      onPressed: () {
                                        setState(() {
                                          search = true;
                                        });
                                      },
                                      icon: Icon(Icons.search, size: 16)),
                              SizedBox(width: 15),
                              //Switch view
                              Container(
                                height: 35,
                                child: Tooltip(
                                  message: 'Vista de mesas',
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.black,
                                    ),
                                    onPressed: () {
                                      // DatabaseService().deleteUserBusiness({
                                      //   'Business ID': userProfile
                                      //       .businesses![businessIndex!]
                                      //       .businessID,
                                      //   'Business Name': userProfile
                                      //       .businesses![businessIndex!]
                                      //       .businessName,
                                      //   'Business Rol': userProfile
                                      //       .businesses![businessIndex!]
                                      //       .roleInBusiness,
                                      //   'Table View': userProfile
                                      //       .businesses![businessIndex!]
                                      //       .tableView
                                      // }, userProfile.uid).then((value) {
                                      //   DatabaseService()
                                      //       .updateUserBusinessProfile({
                                      //     'Business ID': userProfile
                                      //         .businesses![businessIndex!]
                                      //         .businessID,
                                      //     'Business Name': userProfile
                                      //         .businesses![businessIndex!]
                                      //         .businessName,
                                      //     'Business Rol': userProfile
                                      //         .businesses![businessIndex!]
                                      //         .roleInBusiness,
                                      //     'Table View': true
                                      //   }, userProfile.uid);
                                      // });
                                    },
                                    child: Icon(Icons.table_restaurant_outlined,
                                        size: 16),
                                  ),
                                ),
                              )
                            ],
                          )),
                    )),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 5),
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
                //Plates GridView
                PlateSelectionMobile(
                    userProfile.activeBusiness!,
                    category,
                    widget.productList,
                    search,
                    searchName,
                    categoriesProvider.categoryList!),
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

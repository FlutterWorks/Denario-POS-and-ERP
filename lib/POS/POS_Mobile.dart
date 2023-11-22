import 'dart:math';

import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Backend/Ticket.dart';
import 'package:denario/Loading.dart';
import 'package:denario/Models/Categories.dart';
import 'package:denario/Models/Products.dart';
import 'package:denario/Models/SavedOrders.dart';
import 'package:denario/Models/Tables.dart';
import 'package:denario/Models/User.dart';
import 'package:denario/POS/CounterViewMobile.dart';
import 'package:denario/POS/PlateSelection_Mobile.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  final formatCurrency = new NumberFormat.simpleCurrency();

  //Search
  bool search = false;
  String searchName = '';

  @override
  void initState() {
    category = widget.firstCategory;
    selectedTag = 'Mesas';
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
      if (businessIndex!.isNegative) {
        return Loading();
      }

      if (userProfile.businesses![businessIndex!].tableView!) {
        final tables = Provider.of<List<Tables>>(context);

        if (tables == []) {
          return Center();
        }
        return MultiProvider(
          providers: [
            StreamProvider<List<SavedOrders>>.value(
                initialData: [],
                value: DatabaseService()
                    .savedCounterOrders(userProfile.activeBusiness)),
          ],
          child: PageView(
            controller: tableController,
            children: [
              //Tables GridView
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
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                //Title
                                Container(
                                  height: 35,
                                  width: 300,
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: BouncingScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      itemCount: tableViewTags.length,
                                      itemBuilder: (context, i) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8.0),
                                          child: Container(
                                            width: 120,
                                            child: TextButton(
                                              style: ElevatedButton.styleFrom(
                                                foregroundColor: Colors.black,
                                                backgroundColor: (selectedTag ==
                                                        tableViewTags[i])
                                                    ? Colors.black
                                                    : Colors.transparent,
                                                minimumSize: Size(50, 35),
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  selectedTag =
                                                      tableViewTags[i];
                                                });
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5.0),
                                                child: Center(
                                                  child: Text(
                                                    tableViewTags[i],
                                                    style: TextStyle(
                                                        color: (selectedTag ==
                                                                tableViewTags[
                                                                    i])
                                                            ? Colors.white
                                                            : Colors.black,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                                Spacer(),
                                //Switch view
                                Container(
                                  height: 35,
                                  child: Tooltip(
                                    message: 'Vista de productos',
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.black,
                                      ),
                                      onPressed: () {
                                        DatabaseService().deleteUserBusiness({
                                          'Business ID': userProfile
                                              .businesses![businessIndex!]
                                              .businessID,
                                          'Business Name': userProfile
                                              .businesses![businessIndex!]
                                              .businessName,
                                          'Business Rol': userProfile
                                              .businesses![businessIndex!]
                                              .roleInBusiness,
                                          'Table View': userProfile
                                              .businesses![businessIndex!]
                                              .tableView
                                        }, userProfile.uid).then((value) {
                                          DatabaseService()
                                              .updateUserBusinessProfile({
                                            'Business ID': userProfile
                                                .businesses![businessIndex!]
                                                .businessID,
                                            'Business Name': userProfile
                                                .businesses![businessIndex!]
                                                .businessName,
                                            'Business Rol': userProfile
                                                .businesses![businessIndex!]
                                                .roleInBusiness,
                                            'Table View': false
                                          }, userProfile.uid);
                                        });
                                      },
                                      child: Icon(Icons.list, size: 16),
                                    ),
                                  ),
                                ),
                                // SizedBox(width: 15),
                                //Add
                                Container(
                                  height: 40,
                                  child: FloatingActionButton(
                                    backgroundColor: Colors.greenAccent,
                                    foregroundColor: Colors.black,
                                    onPressed: () {
                                      bloc.retrieveOrder(
                                          '',
                                          '',
                                          [],
                                          0,
                                          0,
                                          Colors.white,
                                          false,
                                          '',
                                          true,
                                          'Mostrador',
                                          false,
                                          {});
                                      tableController.animateToPage(1,
                                          duration: Duration(milliseconds: 250),
                                          curve: Curves.easeIn);
                                    },
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      )),
                  //Tables//Counter
                  (selectedTag == 'Mesas')
                      ? SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                (MediaQuery.of(context).size.width > 650)
                                    ? 4
                                    : 3,
                            crossAxisSpacing: 2.0,
                            mainAxisSpacing: 2.0,
                            childAspectRatio: 1,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, i) {
                              return Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    padding: MaterialStateProperty.all<
                                        EdgeInsetsGeometry>(EdgeInsets.zero),
                                    backgroundColor: (tables[i].isOpen!)
                                        ? MaterialStateProperty.all<Color>(
                                            Colors.greenAccent)
                                        : MaterialStateProperty.all<Color>(
                                            Colors.white),
                                    overlayColor: MaterialStateProperty
                                        .resolveWith<Color?>(
                                      (Set<MaterialState> states) {
                                        if (states
                                            .contains(MaterialState.hovered))
                                          return Colors.black12;
                                        if (states.contains(
                                                MaterialState.focused) ||
                                            states.contains(
                                                MaterialState.pressed))
                                          return Colors.black26;
                                        return null; // Defer to the widget's default.
                                      },
                                    ),
                                    shape: (tables[i].shape == "Circle")
                                        ? MaterialStateProperty.all<
                                            CircleBorder>(CircleBorder())
                                        : MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                  ),
                                  onPressed: () {
                                    if (tables[i].isOpen!) {
                                      //retrieve order
                                      bloc.retrieveOrder(
                                          tables[i].table,
                                          tables[i].paymentType,
                                          tables[i].orderDetail,
                                          tables[i].discount,
                                          tables[i].tax,
                                          Color(tables[i].orderColor!),
                                          true,
                                          'Mesa ${tables[i].table}',
                                          false,
                                          'Mesa',
                                          (tables[i].client!['Name'] == '' ||
                                                  tables[i].client!['Name'] ==
                                                      null)
                                              ? false
                                              : true,
                                          tables[i].client);
                                    } else {
                                      //create order with table name
                                      bloc.retrieveOrder(
                                          tables[i].table,
                                          tables[i].paymentType,
                                          tables[i].orderDetail,
                                          tables[i].discount,
                                          tables[i].tax,
                                          Color(tables[i].orderColor!),
                                          false,
                                          'Mesa ${tables[i].table}',
                                          false,
                                          'Mesa',
                                          false, {});
                                    }
                                    tableController.animateToPage(1,
                                        duration: Duration(milliseconds: 250),
                                        curve: Curves.easeIn);
                                  },
                                  child: Container(
                                      width: double.infinity,
                                      child: (tables[i].isOpen!)
                                          ? Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  tables[i].table!,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  softWrap: true,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                SizedBox(height: 15),
                                                Text(
                                                  '${formatCurrency.format(tables[i].total!)}',
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  softWrap: true,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ],
                                            )
                                          : Center(
                                              child: Text(
                                                tables[i].table!,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: true,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            )),
                                ),
                              );
                            },
                            childCount: tables.length,
                          ))
                      : CounterViewMobile(tableController)
                ],
              ),
              //Inside Table
              StreamBuilder(
                  stream: bloc.getStream,
                  initialData: bloc.ticketItems,
                  builder: (context, AsyncSnapshot snapshot) {
                    var subTotal = snapshot.data["Subtotal"];
                    var tax = snapshot.data["IVA"];
                    var discount = snapshot.data["Discount"];
                    var total = snapshot.data["Total"];
                    var orderName = snapshot.data["Order Name"];
                    var color = snapshot.data["Color"];

                    for (var i = 0; i < bloc.ticketItems['Items'].length; i++) {
                      subTotal += bloc.ticketItems['Items'][i]["Price"] *
                          bloc.ticketItems['Items'][i]["Quantity"];
                    }
                    return Stack(
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          IconButton(
                                              tooltip: 'Volver',
                                              splashRadius: 15,
                                              hoverColor: Colors.grey[300],
                                              onPressed: () {
                                                //Si es venta de mostrador
                                                if (snapshot
                                                    .data["Counter Order"]) {
                                                  //Si ya estaba guardada
                                                  if (snapshot
                                                      .data["Open Table"]) {
                                                    if (bloc
                                                            .ticketItems[
                                                                'Items']
                                                            .length <
                                                        1) {
                                                      DatabaseService()
                                                          .deleteOrder(
                                                        userProfile
                                                            .activeBusiness,
                                                        bloc.ticketItems[
                                                            'Order ID'],
                                                      );
                                                    } else {
                                                      DatabaseService()
                                                          .saveOrder(
                                                        userProfile
                                                            .activeBusiness,
                                                        bloc.ticketItems[
                                                            'Order ID'],
                                                        subTotal,
                                                        discount,
                                                        tax,
                                                        total,
                                                        snapshot.data["Items"],
                                                        orderName,
                                                        '',
                                                        color.value,
                                                        false,
                                                        snapshot
                                                            .data["Order Type"],
                                                        {
                                                          'Name': snapshot.data[
                                                              'Client']['Name'],
                                                          'Address':
                                                              snapshot.data[
                                                                      'Client']
                                                                  ['Address'],
                                                          'Phone':
                                                              snapshot.data[
                                                                      'Client']
                                                                  ['Phone'],
                                                          'email': snapshot
                                                                  .data[
                                                              'Client']['email']
                                                        },
                                                      );
                                                    }
                                                  } else if (!snapshot
                                                          .data["Open Table"] &&
                                                      bloc.ticketItems['Items']
                                                              .length >
                                                          0) {
                                                    DatabaseService().saveOrder(
                                                      userProfile
                                                          .activeBusiness,
                                                      DateTime.now().toString(),
                                                      subTotal,
                                                      discount,
                                                      tax,
                                                      total,
                                                      snapshot.data["Items"],
                                                      orderName,
                                                      '',
                                                      Colors
                                                          .primaries[Random()
                                                              .nextInt(Colors
                                                                  .primaries
                                                                  .length)]
                                                          .value,
                                                      false,
                                                      snapshot
                                                          .data["Order Type"],
                                                      {
                                                        'Name': snapshot
                                                                .data['Client']
                                                            ['Name'],
                                                        'Address': snapshot
                                                                .data['Client']
                                                            ['Address'],
                                                        'Phone': snapshot
                                                                .data['Client']
                                                            ['Phone'],
                                                        'email': snapshot
                                                                .data['Client']
                                                            ['email']
                                                      },
                                                    );
                                                  }
                                                } else if (!snapshot.data[
                                                        "Counter Order"] &&
                                                    snapshot
                                                        .data["Open Table"]) {
                                                  if (bloc.ticketItems['Items']
                                                          .length <
                                                      1) {
                                                    DatabaseService()
                                                        .updateTable(
                                                      userProfile
                                                          .activeBusiness!,
                                                      orderName,
                                                      0,
                                                      0,
                                                      0,
                                                      0,
                                                      [],
                                                      '',
                                                      Colors.white.value,
                                                      false,
                                                      {
                                                        'Name': '',
                                                        'Address': '',
                                                        'Phone': 0,
                                                        'email': '',
                                                      },
                                                    );
                                                    DatabaseService()
                                                        .deleteOrder(
                                                      userProfile
                                                          .activeBusiness,
                                                      bloc.ticketItems[
                                                          'Order ID'],
                                                    );
                                                  } else {
                                                    DatabaseService()
                                                        .updateTable(
                                                      userProfile
                                                          .activeBusiness!,
                                                      orderName,
                                                      subTotal,
                                                      discount,
                                                      tax,
                                                      bloc.totalTicketAmount,
                                                      snapshot.data["Items"],
                                                      '',
                                                      Colors.greenAccent.value,
                                                      true,
                                                      {
                                                        'Name': snapshot
                                                                .data['Client']
                                                            ['Name'],
                                                        'Address': snapshot
                                                                .data['Client']
                                                            ['Address'],
                                                        'Phone': snapshot
                                                                .data['Client']
                                                            ['Phone'],
                                                        'email': snapshot
                                                                .data['Client']
                                                            ['email']
                                                      },
                                                    );
                                                    DatabaseService().saveOrder(
                                                      userProfile
                                                          .activeBusiness,
                                                      bloc.ticketItems[
                                                          'Order ID'],
                                                      subTotal,
                                                      discount,
                                                      tax,
                                                      bloc.totalTicketAmount,
                                                      snapshot.data["Items"],
                                                      orderName,
                                                      '',
                                                      color.value,
                                                      true,
                                                      'Mesa',
                                                      {
                                                        'Name': snapshot
                                                                .data['Client']
                                                            ['Name'],
                                                        'Address': snapshot
                                                                .data['Client']
                                                            ['Address'],
                                                        'Phone': snapshot
                                                                .data['Client']
                                                            ['Phone'],
                                                        'email': snapshot
                                                                .data['Client']
                                                            ['email']
                                                      },
                                                    );
                                                  }
                                                } else if (!snapshot.data[
                                                        "Counter Order"] &&
                                                    !snapshot
                                                        .data["Open Table"] &&
                                                    bloc.ticketItems['Items']
                                                            .length >
                                                        0) {
                                                  DatabaseService().updateTable(
                                                    userProfile.activeBusiness!,
                                                    orderName,
                                                    subTotal,
                                                    discount,
                                                    tax,
                                                    bloc.totalTicketAmount,
                                                    snapshot.data["Items"],
                                                    '',
                                                    Colors.greenAccent.value,
                                                    true,
                                                    {
                                                      'Name': snapshot
                                                              .data['Client']
                                                          ['Name'],
                                                      'Address': snapshot
                                                              .data['Client']
                                                          ['Address'],
                                                      'Phone': snapshot
                                                              .data['Client']
                                                          ['Phone'],
                                                      'email': snapshot
                                                              .data['Client']
                                                          ['email']
                                                    },
                                                  );
                                                  DatabaseService().saveOrder(
                                                    userProfile.activeBusiness,
                                                    'Mesa ' + orderName,
                                                    subTotal,
                                                    discount,
                                                    tax,
                                                    bloc.totalTicketAmount,
                                                    snapshot.data["Items"],
                                                    orderName,
                                                    '',
                                                    Colors.greenAccent.value,
                                                    true,
                                                    'Mesa',
                                                    {
                                                      'Name': snapshot
                                                              .data['Client']
                                                          ['Name'],
                                                      'Address': snapshot
                                                              .data['Client']
                                                          ['Address'],
                                                      'Phone': snapshot
                                                              .data['Client']
                                                          ['Phone'],
                                                      'email': snapshot
                                                              .data['Client']
                                                          ['email']
                                                    },
                                                  );
                                                }

                                                tableController.animateToPage(0,
                                                    duration: Duration(
                                                        milliseconds: 250),
                                                    curve: Curves.easeIn);
                                              },
                                              icon: Icon(Icons.arrow_back,
                                                  color: Colors.black)),

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
                                                      validator: (val) => val!
                                                              .isEmpty
                                                          ? "Agrega un nombre"
                                                          : null,
                                                      autofocus: true,
                                                      cursorColor: Colors.grey,
                                                      cursorHeight: 14,
                                                      initialValue: searchName,
                                                      textInputAction:
                                                          TextInputAction.next,
                                                      decoration:
                                                          InputDecoration(
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
                                                              color:
                                                                  Colors.grey,
                                                            )),
                                                        errorStyle: TextStyle(
                                                            color: Colors
                                                                .redAccent[700],
                                                            fontSize: 12),
                                                        border:
                                                            new OutlineInputBorder(
                                                          borderRadius:
                                                              new BorderRadius
                                                                  .circular(
                                                                  12.0),
                                                          borderSide:
                                                              new BorderSide(
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              new BorderRadius
                                                                  .circular(
                                                                  12.0),
                                                          borderSide:
                                                              new BorderSide(
                                                            color: Colors.green,
                                                          ),
                                                        ),
                                                      ),
                                                      onChanged: (val) {
                                                        setState(() =>
                                                            searchName = val);
                                                      },
                                                    ),
                                                  ),
                                                )
                                              : Spacer(),
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
                                                  icon: Icon(Icons.search,
                                                      size: 16)),
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
                                              backgroundColor:
                                                  (category == categories[i])
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
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5.0),
                                              child: Center(
                                                child: Text(
                                                  categories[i],
                                                  style: TextStyle(
                                                      color: (category ==
                                                              categories[i])
                                                          ? Colors.white
                                                          : Colors.black,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400),
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
                                onPressed: () => widget
                                    .scaffoldKeyMobile!.currentState!
                                    .openEndDrawer(),
                                backgroundColor: Colors.black,
                                child: Center(
                                    child: Icon(Icons.format_list_bulleted,
                                        color: Colors.white))),
                          ),
                        )
                      ],
                    );
                  }),
            ],
          ),
        );
      } else {
        return MultiProvider(
          providers: [
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
                                            textInputAction:
                                                TextInputAction.next,
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
                                        DatabaseService().deleteUserBusiness({
                                          'Business ID': userProfile
                                              .businesses![businessIndex!]
                                              .businessID,
                                          'Business Name': userProfile
                                              .businesses![businessIndex!]
                                              .businessName,
                                          'Business Rol': userProfile
                                              .businesses![businessIndex!]
                                              .roleInBusiness,
                                          'Table View': userProfile
                                              .businesses![businessIndex!]
                                              .tableView
                                        }, userProfile.uid).then((value) {
                                          DatabaseService()
                                              .updateUserBusinessProfile({
                                            'Business ID': userProfile
                                                .businesses![businessIndex!]
                                                .businessID,
                                            'Business Name': userProfile
                                                .businesses![businessIndex!]
                                                .businessName,
                                            'Business Rol': userProfile
                                                .businesses![businessIndex!]
                                                .roleInBusiness,
                                            'Table View': true
                                          }, userProfile.uid);
                                        });
                                      },
                                      child: Icon(
                                          Icons.table_restaurant_outlined,
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5.0),
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
                      onPressed: () => widget.scaffoldKeyMobile!.currentState!
                          .openEndDrawer(),
                      backgroundColor: Colors.black,
                      child: Center(
                          child: Icon(Icons.format_list_bulleted,
                              color: Colors.white))),
                ),
              )
            ],
          ),
        );
      }
    } catch (e) {
      return Loading();
    }
  }
}

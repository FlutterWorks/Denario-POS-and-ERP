import 'package:denario/Models/Discounts.dart';
import 'package:denario/Products/DiscountCreate.dart';
import 'package:denario/Products/DiscountDetails.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DiscountsList extends StatelessWidget {
  final String activeBusiness;
  const DiscountsList(this.activeBusiness, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final discountList = Provider.of<List<Discounts>>(context);

    if (MediaQuery.of(context).size.width > 650) {
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            //Title
            SliverAppBar(
              backgroundColor: Colors.white,
              floating: true,
              pinned: false,
              automaticallyImplyLeading: false,
              actions: <Widget>[Container()],
              expandedHeight: 75,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      //Back
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.arrow_back),
                        color: Colors.black,
                      ),
                      SizedBox(width: 25),
                      //Title
                      Container(
                        child: Text(
                          'Descuentos',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Spacer(),
                      //Add
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return DiscountCreate(activeBusiness);
                              });
                        },
                        child: Container(
                          height: 45,
                          padding: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          child: Row(
                            children: [
                              Icon(Icons.add, size: 16),
                              SizedBox(width: 10),
                              Text('Agregar descuento'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            //lIST OF Categories (Titles)
            SliverAppBar(
              backgroundColor: Colors.white,
              pinned: true,
              automaticallyImplyLeading: false,
              actions: <Widget>[Container()],
              toolbarHeight: 50,
              flexibleSpace: Center(
                child: Container(
                  width: double.infinity,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      //Creado
                      Container(
                          width: 100,
                          child: Text(
                            'Creado',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54),
                          )),

                      //%
                      Container(
                          width: 100,
                          child: Text(
                            'Descuento',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54),
                          )),

                      //Code
                      (MediaQuery.of(context).size.width > 900)
                          ? Container(
                              width: 120,
                              child: Text(
                                'Código',
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54),
                              ))
                          : SizedBox(),

                      //Descripcion
                      Container(
                          width: (MediaQuery.of(context).size.width > 800)
                              ? 350
                              : 250,
                          child: Text(
                            'Descripción',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54),
                          )),

                      //Qty of uses
                      Container(
                          width: 100,
                          child: Text(
                            'Usos',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54),
                          )),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                child: Divider(
                  indent: 1,
                  endIndent: 1,
                  thickness: 1,
                  color: Colors.grey[300],
                ),
              ),
            ),
            //List of Categories
            (discountList == null)
                ? SliverToBoxAdapter(child: Container())
                : (discountList.length < 1)
                    ? SliverToBoxAdapter(
                        child: Container(
                        height: 100,
                        width: double.infinity,
                        child: Center(
                          child: Text('No tienes descuentos activos'),
                        ),
                      ))
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            return TextButton(
                              style: TextButton.styleFrom(
                                  backgroundColor: Colors.white),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DiscountDetails(
                                            discountList[i], activeBusiness)));
                              },
                              child: Container(
                                height: 50,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    //Date
                                    discountList[i].active
                                        ? Container(
                                            width: 100,
                                            child: Text(
                                              DateFormat.yMMMd()
                                                  .format(discountList[i]
                                                      .createdDate)
                                                  .toString(),
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.black),
                                            ),
                                          )
                                        : Container(
                                            width: 100,
                                            child: Column(
                                              children: [
                                                Text(
                                                  DateFormat.yMMMd()
                                                      .format(discountList[i]
                                                          .createdDate)
                                                      .toString(),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Colors.black),
                                                ),
                                                SizedBox(height: 5),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color:
                                                            Colors.grey[350]),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0),
                                                  ),
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 2,
                                                      horizontal: 8),
                                                  child: Text(
                                                    'Inactivo',
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 10),
                                                  ),
                                                )
                                              ],
                                            )),

                                    //Percentage
                                    (MediaQuery.of(context).size.width > 900)
                                        ? Container(
                                            width: 100,
                                            child: Text(
                                              '${discountList[i].discount}%',
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                            ))
                                        : Container(
                                            width: 100,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '${discountList[i].code}',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black54),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  '${discountList[i].discount}%',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                      fontSize: 11),
                                                ),
                                              ],
                                            ),
                                          ),
                                    //Code
                                    (MediaQuery.of(context).size.width > 900)
                                        ? Container(
                                            width: 120,
                                            child: Text(
                                              '${discountList[i].code}',
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black54),
                                            ),
                                          )
                                        : SizedBox(),
                                    //Descripción
                                    Container(
                                      width:
                                          (MediaQuery.of(context).size.width >
                                                  800)
                                              ? 350
                                              : 250,
                                      child: Text(
                                        '${discountList[i].description}',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black),
                                      ),
                                    ),
                                    //Usos
                                    Container(
                                      width: 100,
                                      child: Text(
                                        '${discountList[i].numberOfUses}',
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: discountList.length,
                        ),
                      ),
          ],
        ),
      );
    } else {
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            //Title
            SliverAppBar(
              backgroundColor: Colors.white,
              floating: true,
              pinned: false,
              automaticallyImplyLeading: false,
              actions: <Widget>[Container()],
              expandedHeight: 75,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      //Back
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.arrow_back),
                        color: Colors.black,
                      ),
                      SizedBox(width: 20),
                      //Title
                      Container(
                        child: Text(
                          'Descuentos',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Spacer(),
                      //Add
                      Container(
                        height: 40,
                        child: FloatingActionButton(
                          backgroundColor: Colors.greenAccent,
                          foregroundColor: Colors.black,
                          onPressed: () {
                            showModalBottomSheet(
                                backgroundColor: Colors.white,
                                isScrollControlled: true,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(15),
                                        topRight: Radius.circular(15))),
                                context: context,
                                builder: (context) {
                                  return DiscountCreate(activeBusiness);
                                });
                          },
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            //List of Categories
            (discountList == null)
                ? SliverToBoxAdapter(child: Container())
                : (discountList.length < 1)
                    ? SliverToBoxAdapter(
                        child: Container(
                        height: 100,
                        width: double.infinity,
                        child: Center(
                          child: Text('No tienes descuentos activos'),
                        ),
                      ))
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            return TextButton(
                              style: TextButton.styleFrom(
                                  backgroundColor: Colors.white),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DiscountDetails(
                                            discountList[i], activeBusiness)));
                              },
                              child: Container(
                                height: 50,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    //Date
                                    discountList[i].active
                                        ? Expanded(
                                            flex: 4,
                                            child: Container(
                                              child: Column(
                                                children: [
                                                  Text(
                                                    'Creado',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.black,
                                                        fontSize: 11),
                                                  ),
                                                  SizedBox(height: 5),
                                                  Text(
                                                    DateFormat.yMd()
                                                        .format(discountList[i]
                                                            .createdDate)
                                                        .toString(),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.black),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : Expanded(
                                            flex: 4,
                                            child: Container(
                                                child: Column(
                                              children: [
                                                Text(
                                                  DateFormat.yMd()
                                                      .format(discountList[i]
                                                          .createdDate)
                                                      .toString(),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Colors.black),
                                                ),
                                                SizedBox(height: 5),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color:
                                                            Colors.grey[350]),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0),
                                                  ),
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 2,
                                                      horizontal: 8),
                                                  child: Text(
                                                    'Inactivo',
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 10),
                                                  ),
                                                )
                                              ],
                                            )),
                                          ),

                                    //Percentage
                                    Expanded(
                                      flex: 4,
                                      child: Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              '${discountList[i].code}',
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black54),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              '${discountList[i].discount}%',
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  fontSize: 11),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    //Usos
                                    Expanded(
                                      flex: 4,
                                      child: Container(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              '${discountList[i].numberOfUses}',
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.black),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              'Usos',
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: discountList.length,
                        ),
                      ),
          ],
        ),
      );
    }
  }
}

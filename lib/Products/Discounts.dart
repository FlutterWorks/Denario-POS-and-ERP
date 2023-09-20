import 'package:flutter/material.dart';

class Discounts extends StatelessWidget {
  const Discounts({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                    //Add category
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () {},
                      child: Container(
                        height: 45,
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
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
                    Container(
                        width: 120,
                        child: Text(
                          'Código',
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54),
                        )),

                    //Descripcion
                    Container(
                        width: 350,
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

                    //Delete
                    SizedBox(width: 35)
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
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return TextButton(
                  style: TextButton.styleFrom(backgroundColor: Colors.white),
                  onPressed: () {},
                  child: Container(
                    height: 50,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        //Percentage
                        Container(
                            width: 100,
                            child: Text(
                              '20%',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54),
                            )),
                        //Code
                        Container(
                          width: 120,
                          child: Text(
                            'OSECAC20',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54),
                          ),
                        ),
                        //Descripción
                        Container(
                          width: 350,
                          child: Text(
                            'Descuento para trabajadores del OSECAC',
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
                            '27',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.black),
                          ),
                        ),

                        //More Button
                        IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.delete,
                              color: Colors.black,
                            ))
                      ],
                    ),
                  ),
                );
              },
              childCount: 25,
            ),
          ),
        ],
      ),
    );
  }
}

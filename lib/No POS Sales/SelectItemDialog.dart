import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Backend/Ticket.dart';
import 'package:denario/Models/Categories.dart';
import 'package:denario/Models/Products.dart';
import 'package:denario/Models/User.dart';
import 'package:denario/No%20POS%20Sales/ProductSelection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectItemDialog extends StatefulWidget {
  final UserData userProfile;
  SelectItemDialog(this.userProfile);

  @override
  State<SelectItemDialog> createState() => _SelectItemDialogState();
}

class _SelectItemDialogState extends State<SelectItemDialog> {
  bool categoryisSelected = false;
  String selectedCategory = '';
  String product = '';
  int price = 0;
  TextEditingController productController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    final categoriesProvider = Provider.of<CategoryList>(context);

    if (categoriesProvider == null) {
      return Dialog();
    }

    List categories = categoriesProvider.categoryList;

    if (MediaQuery.of(context).size.width > 650) {
      if (!categoryisSelected) {
        return SingleChildScrollView(
            child: Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                child: Container(
                  padding: EdgeInsets.all(20),
                  height: (MediaQuery.of(context).size.width > 650)
                      ? 500
                      : MediaQuery.of(context).size.height * 0.8,
                  width: (MediaQuery.of(context).size.width > 650)
                      ? 500
                      : MediaQuery.of(context).size.width * 0.9,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      //Close
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.close),
                              splashRadius: 5,
                              iconSize: 20.0),
                        ],
                      ),
                      //Text
                      Text(
                        "Selecciona una Categoría",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 30),
                      //lIST OF Categories
                      (MediaQuery.of(context).size.width > 650)
                          ? Expanded(
                              child: Container(
                                child: GridView.builder(
                                    shrinkWrap: true,
                                    physics: BouncingScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 15.0,
                                      mainAxisSpacing: 15.0,
                                      childAspectRatio:
                                          (MediaQuery.of(context).size.width >
                                                  900)
                                              ? 3
                                              : 2,
                                    ),
                                    scrollDirection: Axis.vertical,
                                    itemCount: categories.length,
                                    itemBuilder: (context, i) {
                                      return ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              selectedCategory = categories[i];
                                              categoryisSelected = true;
                                            });
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.white),
                                            overlayColor: MaterialStateProperty
                                                .resolveWith<Color>(
                                              (Set<MaterialState> states) {
                                                if (states.contains(
                                                    MaterialState.hovered))
                                                  return Colors.black12;
                                                if (states.contains(
                                                        MaterialState
                                                            .focused) ||
                                                    states.contains(
                                                        MaterialState.pressed))
                                                  return Colors.black26;
                                                return null; // Defer to the widget's default.
                                              },
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              categories[i],
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ));
                                    }),
                              ),
                            )
                          : Expanded(
                              child: Container(
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: BouncingScrollPhysics(),
                                    scrollDirection: Axis.vertical,
                                    itemCount: categories.length,
                                    itemBuilder: (context, i) {
                                      return Container(
                                        width: double.infinity,
                                        height: 75,
                                        padding: const EdgeInsets.all(8.0),
                                        child: ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                selectedCategory =
                                                    categories[i];
                                                categoryisSelected = true;
                                              });
                                            },
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(Colors.white),
                                              overlayColor:
                                                  MaterialStateProperty
                                                      .resolveWith<Color>(
                                                (Set<MaterialState> states) {
                                                  if (states.contains(
                                                      MaterialState.hovered))
                                                    return Colors.black12;
                                                  if (states.contains(
                                                          MaterialState
                                                              .focused) ||
                                                      states.contains(
                                                          MaterialState
                                                              .pressed))
                                                    return Colors.black26;
                                                  return null; // Defer to the widget's default.
                                                },
                                              ),
                                            ),
                                            child: Text(
                                              categories[i],
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              style: TextStyle(
                                                  color: Colors.black),
                                            )),
                                      );
                                    }),
                              ),
                            )
                    ],
                  ),
                )));
      } else {
        return SingleChildScrollView(
            child: Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                child: Container(
                  padding: EdgeInsets.all(20),
                  height: (MediaQuery.of(context).size.width > 650)
                      ? 500
                      : MediaQuery.of(context).size.height * 0.8,
                  width: (MediaQuery.of(context).size.width > 650)
                      ? 600
                      : MediaQuery.of(context).size.width * 0.9,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      //Close
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.arrow_back),
                              splashRadius: 5,
                              iconSize: 20.0),
                          Spacer(),
                          IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.close),
                              splashRadius: 5,
                              iconSize: 20.0),
                        ],
                      ),
                      //Text
                      Text(
                        'Producto/Servicio',
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Colors.black45),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            flex: 8,
                            child: TextFormField(
                              controller: productController,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                              cursorColor: Colors.grey,
                              autofocus: true,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                errorStyle: TextStyle(
                                    color: Colors.redAccent[700], fontSize: 12),
                                border: new OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(12.0),
                                  borderSide: new BorderSide(
                                    color: Colors.grey,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(12.0),
                                  borderSide: new BorderSide(
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            flex: (MediaQuery.of(context).size.width > 900)
                                ? 1
                                : 2,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black,
                              ),
                              onPressed: () {
                                bloc.addToCart({
                                  'Name': productController.text,
                                  'Category': selectedCategory,
                                  'Price': 0,
                                  'Quantity': 1,
                                  'Total Price': 0
                                });
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                height: 50,
                                child: Center(
                                    child: Icon(
                                  Icons.add,
                                  color: Colors.black,
                                  size: 30,
                                )),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      //lIST OF Products
                      Expanded(
                          child: Container(
                              child: StreamProvider<List<Products>>.value(
                                  initialData: [],
                                  value: DatabaseService().productList(
                                      selectedCategory,
                                      widget.userProfile.activeBusiness),
                                  child: ProductSelection()))),
                    ],
                  ),
                )));
      }
    } else {
      if (!categoryisSelected) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              //Text
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Selecciona una Categoría",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(
                color: Colors.grey.shade200,
                indent: 5,
                endIndent: 5,
                thickness: 0.5,
              ),
              //lIST OF Categories
              Expanded(
                child: Container(
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      itemCount: categories.length,
                      itemBuilder: (context, i) {
                        return Container(
                          width: double.infinity,
                          height: 75,
                          child: TextButton(
                              onPressed: () {
                                setState(() {
                                  selectedCategory = categories[i];
                                  categoryisSelected = true;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Text(
                                  categories[i],
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: TextStyle(color: Colors.black),
                                ),
                              )),
                        );
                      }),
                ),
              )
            ],
          ),
        );
      } else {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              //Close
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                        onPressed: () {
                          setState(() {
                            categoryisSelected = false;
                            selectedCategory = '';
                          });
                        },
                        icon: Icon(Icons.arrow_back),
                        splashRadius: 5,
                        iconSize: 20.0),
                    SizedBox(width: 10),
                    Text(
                      'Producto/Servicio',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              //Text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      flex: 8,
                      child: TextFormField(
                        controller: productController,
                        style: TextStyle(color: Colors.black, fontSize: 16),
                        cursorColor: Colors.grey,
                        autofocus: false,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          errorStyle: TextStyle(
                              color: Colors.redAccent[700], fontSize: 12),
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(12.0),
                            borderSide: new BorderSide(
                              color: Colors.grey,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(12.0),
                            borderSide: new BorderSide(
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () {
                          bloc.addToCart({
                            'Name': productController.text,
                            'Category': selectedCategory,
                            'Price': 0,
                            'Quantity': 1,
                            'Total Price': 0
                          });
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          height: 50,
                          child: Center(
                              child: Icon(
                            Icons.add,
                            color: Colors.black,
                            size: 30,
                          )),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              //lIST OF Products
              Expanded(
                  child: Container(
                      child: StreamProvider<List<Products>>.value(
                          initialData: [],
                          value: DatabaseService().productList(selectedCategory,
                              widget.userProfile.activeBusiness),
                          child: ProductSelection()))),
            ],
          ),
        );
      }
    }
  }
}

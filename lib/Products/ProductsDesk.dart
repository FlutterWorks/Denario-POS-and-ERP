import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Models/Categories.dart';
import 'package:denario/Models/Discounts.dart';
import 'package:denario/Models/Products.dart';
import 'package:denario/Products/CategoriesDesk.dart';
import 'package:denario/Products/DiscountsList.dart';
import 'package:denario/Products/NewProduct.dart';
import 'package:denario/Products/ProductList.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductDesk extends StatefulWidget {
  final String currentBusiness;
  final List categories;
  final String businessField;
  final reloadApp;
  const ProductDesk(
      this.currentBusiness, this.categories, this.businessField, this.reloadApp,
      {Key? key})
      : super(key: key);

  @override
  State<ProductDesk> createState() => _ProductDeskState();
}

class _ProductDeskState extends State<ProductDesk> {
  late String name;
  TextEditingController nameController = new TextEditingController(text: '');
  String? selectedProduct;
  List? searchName;
  late bool filtered;
  List listOfCategories = [];
  String selectedCategory = 'Todas las categorías';
  late bool showSearchOptions;
  late int limitSearch;
  void loadMore() {
    setState(() {
      limitSearch = limitSearch + 10;
    });
  }

  void selectProduct(Products product) {
    setState(() {
      selectedProduct = product.product;
      nameController.text = product.product!;
      searchName = product.searchName;
      showSearchOptions = false;
      selectedCategory = 'Todas las categorías';
    });
  }

  @override
  void initState() {
    filtered = false;
    showSearchOptions = false;
    name = '';
    listOfCategories = widget.categories;
    limitSearch = 10;
    if (!listOfCategories.contains('Todas las categorías')) {
      listOfCategories.add('Todas las categorías');
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesProvider = Provider.of<CategoryList?>(context);

    if (categoriesProvider == null) {
      return Container();
    }

    if (MediaQuery.of(context).size.width > 800) {
      return Scaffold(
          body: CustomScrollView(slivers: [
        //Go Back /// Title //Filters
        SliverAppBar(
          floating: true,
          backgroundColor: Colors.white,
          pinned: false,
          automaticallyImplyLeading: false,
          actions: <Widget>[Container()],
          expandedHeight:
              (MediaQuery.of(context).size.width > 1175) ? 150 : 200,
          flexibleSpace: FlexibleSpaceBar(
            background: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Title
                  Container(
                    width: double.infinity,
                    height: 75,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            'Productos',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  //Filters
                  (MediaQuery.of(context).size.width > 1175)
                      ? Container(
                          height: 70,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: <BoxShadow>[
                              new BoxShadow(
                                color: Colors.grey[350]!,
                                offset: Offset(0.0, 0.0),
                                blurRadius: 10.0,
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              //Nombre
                              Container(
                                width: 250,
                                height: 45,
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: TextFormField(
                                  controller: nameController,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 14),
                                  cursorColor: Colors.grey,
                                  decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.all(2),
                                      iconSize: 14,
                                      splashRadius: 15,
                                      onPressed: () {
                                        setState(() {
                                          showSearchOptions = false;
                                          nameController.text = '';
                                          name = '';
                                        });
                                      },
                                      icon: Icon(Icons.close),
                                      color: Colors.black,
                                    ),
                                    hintText: 'Nombre',
                                    hintStyle: TextStyle(
                                        color: Colors.black45, fontSize: 14),
                                    border: new OutlineInputBorder(
                                      borderRadius:
                                          new BorderRadius.circular(12.0),
                                      borderSide: new BorderSide(
                                        color: Colors.grey[350]!,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          new BorderRadius.circular(12.0),
                                      borderSide: new BorderSide(
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                  onChanged: (val) {
                                    setState(() {
                                      name = val;
                                      selectedCategory = 'Todas las categorías';
                                      if (val != '') {
                                        showSearchOptions = true;
                                      } else {
                                        showSearchOptions = false;
                                      }
                                    });
                                  },
                                  onFieldSubmitted: ((value) {
                                    setState(() {
                                      selectedProduct = value;
                                      selectedCategory = 'Todas las categorías';
                                    });
                                  }),
                                ),
                              ),
                              //Categorias
                              Container(
                                width: 200,
                                height: 45,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[350]!),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: DropdownButton(
                                  isExpanded: true,
                                  underline: SizedBox(),
                                  hint: Text(
                                    'Todas las categorías',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        color: Colors.black),
                                  ),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      color: Colors.black),
                                  value: selectedCategory,
                                  items: listOfCategories.map((i) {
                                    return new DropdownMenuItem(
                                      value: i,
                                      child: new Text(i),
                                    );
                                  }).toList(),
                                  onChanged: (x) {
                                    setState(() {
                                      selectedCategory = x.toString();
                                      selectedProduct = null;
                                      nameController.text = '';
                                      name = '';
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 15),
                              Container(
                                height: 40,
                                width: 40,
                                child: Tooltip(
                                  message: 'Quitar filtros',
                                  child: OutlinedButton(
                                    style: ButtonStyle(
                                      padding: MaterialStateProperty.all<
                                              EdgeInsetsGeometry>(
                                          EdgeInsets.all(5)),
                                      alignment: Alignment.center,
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.white70),
                                      overlayColor: MaterialStateProperty
                                          .resolveWith<Color?>(
                                        (Set<MaterialState> states) {
                                          if (states
                                              .contains(MaterialState.hovered))
                                            return Colors.grey.shade300;
                                          if (states.contains(
                                                  MaterialState.focused) ||
                                              states.contains(
                                                  MaterialState.pressed))
                                            return Colors.white;
                                          return null; // Defer to the widget's default.
                                        },
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        filtered = false;
                                        showSearchOptions = false;
                                        selectedCategory =
                                            'Todas las categorías';
                                        selectedProduct = '';
                                        name = '';
                                      });
                                    },
                                    child: Center(
                                        child: Icon(
                                      Icons.filter_alt_off_outlined,
                                      color: Colors.black,
                                      size: 18,
                                    )),
                                  ),
                                ),
                              ),
                              Spacer(),
                              //Promos
                              Container(
                                height: 40,
                                width: 40,
                                child: Tooltip(
                                  message: 'Descuentos',
                                  child: OutlinedButton(
                                    style: ButtonStyle(
                                      padding: MaterialStateProperty.all<
                                              EdgeInsetsGeometry>(
                                          EdgeInsets.all(5)),
                                      alignment: Alignment.center,
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.white70),
                                      overlayColor: MaterialStateProperty
                                          .resolveWith<Color?>(
                                        (Set<MaterialState> states) {
                                          if (states
                                              .contains(MaterialState.hovered))
                                            return Colors.grey.shade300;
                                          if (states.contains(
                                                  MaterialState.focused) ||
                                              states.contains(
                                                  MaterialState.pressed))
                                            return Colors.white;
                                          return null; // Defer to the widget's default.
                                        },
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  StreamProvider<
                                                      List<Discounts>>.value(
                                                    initialData: [],
                                                    value: DatabaseService()
                                                        .allDiscountsList(widget
                                                            .currentBusiness),
                                                    child: DiscountsList(
                                                        widget.currentBusiness),
                                                  )));
                                    },
                                    child: Center(
                                        child: Text(
                                      '%',
                                      style: TextStyle(
                                          fontSize: 21,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.grey.shade900),
                                    )),
                                  ),
                                ),
                              ),
                              SizedBox(width: 15),
                              //Boton de categorias
                              Container(
                                height: 45,
                                child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.black,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => StreamProvider<
                                                      List<Products>>.value(
                                                  initialData: [],
                                                  value: DatabaseService()
                                                      .allProductListNoLimit(
                                                          widget
                                                              .currentBusiness),
                                                  child: CategoriesDesk(
                                                      widget.currentBusiness,
                                                      categoriesProvider
                                                          .categoryList!,
                                                      widget.reloadApp))));
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 5),
                                      child: Text(
                                        'Categorías',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    )),
                              ),
                              SizedBox(width: 15),
                              //Boton de agregar
                              Container(
                                height: 45,
                                child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color?>(
                                              Colors.greenAccent[400]!),
                                      overlayColor: MaterialStateProperty
                                          .resolveWith<Color?>(
                                        (Set<MaterialState> states) {
                                          if (states
                                              .contains(MaterialState.hovered))
                                            return Colors.greenAccent[300];
                                          if (states.contains(
                                                  MaterialState.focused) ||
                                              states.contains(
                                                  MaterialState.pressed))
                                            return Colors.lightGreenAccent;
                                          return null; // Defer to the widget's default.
                                        },
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => NewProduct(
                                                  widget.currentBusiness,
                                                  categoriesProvider
                                                      .categoryList!,
                                                  widget.businessField,
                                                  null)));
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            'Agregar Producto',
                                            style:
                                                TextStyle(color: Colors.white),
                                          )
                                        ],
                                      ),
                                    )),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          height: 120,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: <BoxShadow>[
                              new BoxShadow(
                                color: Colors.grey[350]!,
                                offset: Offset(0.0, 0.0),
                                blurRadius: 10.0,
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  //Nombre
                                  Container(
                                    width: 250,
                                    height: 45,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12),
                                    child: TextFormField(
                                      controller: nameController,
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 14),
                                      cursorColor: Colors.grey,
                                      decoration: InputDecoration(
                                        suffixIcon: IconButton(
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.all(2),
                                          iconSize: 14,
                                          splashRadius: 15,
                                          onPressed: () {
                                            setState(() {
                                              showSearchOptions = false;
                                              nameController.text = '';
                                              name = '';
                                            });
                                          },
                                          icon: Icon(Icons.close),
                                          color: Colors.black,
                                        ),
                                        hintText: 'Nombre',
                                        hintStyle: TextStyle(
                                            color: Colors.black45,
                                            fontSize: 14),
                                        border: new OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(12.0),
                                          borderSide: new BorderSide(
                                            color: Colors.grey[350]!,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(12.0),
                                          borderSide: new BorderSide(
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          name = val;
                                          selectedCategory =
                                              'Todas las categorías';
                                          if (val != '') {
                                            showSearchOptions = true;
                                          } else {
                                            showSearchOptions = false;
                                          }
                                        });
                                      },
                                      onFieldSubmitted: ((value) {
                                        setState(() {
                                          selectedProduct = value;
                                          selectedCategory =
                                              'Todas las categorías';
                                        });
                                      }),
                                    ),
                                  ),
                                  //Categorias
                                  Container(
                                    width: 200,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      border:
                                          Border.all(color: Colors.grey[350]!),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12),
                                    child: DropdownButton(
                                      isExpanded: true,
                                      underline: SizedBox(),
                                      hint: Text(
                                        'Todas las categorías',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16,
                                            color: Colors.black),
                                      ),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          color: Colors.black),
                                      value: selectedCategory,
                                      items: listOfCategories.map((i) {
                                        return new DropdownMenuItem(
                                          value: i,
                                          child: new Text(i),
                                        );
                                      }).toList(),
                                      onChanged: (x) {
                                        setState(() {
                                          selectedCategory = x.toString();
                                          selectedProduct = null;
                                          nameController.text = '';
                                          name = '';
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Container(
                                    height: 40,
                                    width: 40,
                                    child: Tooltip(
                                      message: 'Quitar filtros',
                                      child: OutlinedButton(
                                        style: ButtonStyle(
                                          padding: MaterialStateProperty.all<
                                                  EdgeInsetsGeometry>(
                                              EdgeInsets.all(5)),
                                          alignment: Alignment.center,
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.white70),
                                          overlayColor: MaterialStateProperty
                                              .resolveWith<Color?>(
                                            (Set<MaterialState> states) {
                                              if (states.contains(
                                                  MaterialState.hovered))
                                                return Colors.grey.shade300;
                                              if (states.contains(
                                                      MaterialState.focused) ||
                                                  states.contains(
                                                      MaterialState.pressed))
                                                return Colors.white;
                                              return null; // Defer to the widget's default.
                                            },
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            filtered = false;
                                            showSearchOptions = false;
                                            selectedCategory =
                                                'Todas las categorías';
                                            selectedProduct = '';
                                            name = '';
                                          });
                                        },
                                        child: Center(
                                            child: Icon(
                                          Icons.filter_alt_off_outlined,
                                          color: Colors.black,
                                          size: 18,
                                        )),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  //Promos
                                  Container(
                                    height: 40,
                                    width: 40,
                                    child: Tooltip(
                                      message: 'Descuentos',
                                      child: OutlinedButton(
                                        style: ButtonStyle(
                                          padding: MaterialStateProperty.all<
                                                  EdgeInsetsGeometry>(
                                              EdgeInsets.all(5)),
                                          alignment: Alignment.center,
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.white70),
                                          overlayColor: MaterialStateProperty
                                              .resolveWith<Color?>(
                                            (Set<MaterialState> states) {
                                              if (states.contains(
                                                  MaterialState.hovered))
                                                return Colors.grey.shade300;
                                              if (states.contains(
                                                      MaterialState.focused) ||
                                                  states.contains(
                                                      MaterialState.pressed))
                                                return Colors.white;
                                              return null; // Defer to the widget's default.
                                            },
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      StreamProvider<
                                                          List<
                                                              Discounts>>.value(
                                                        initialData: [],
                                                        value: DatabaseService()
                                                            .allDiscountsList(widget
                                                                .currentBusiness),
                                                        child: DiscountsList(
                                                            widget
                                                                .currentBusiness),
                                                      )));
                                        },
                                        child: Center(
                                            child: Text(
                                          '%',
                                          style: TextStyle(
                                              fontSize: 21,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.grey.shade900),
                                        )),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  //Boton de categorias
                                  Container(
                                    height: 45,
                                    child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.black,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => StreamProvider<
                                                          List<Products>>.value(
                                                      initialData: [],
                                                      value: DatabaseService()
                                                          .allProductListNoLimit(
                                                              widget
                                                                  .currentBusiness),
                                                      child: CategoriesDesk(
                                                          widget
                                                              .currentBusiness,
                                                          categoriesProvider
                                                              .categoryList!,
                                                          widget.reloadApp))));
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 5),
                                          child: Text(
                                            'Categorías',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        )),
                                  ),
                                  SizedBox(width: 15),
                                  //Boton de agregar
                                  Container(
                                    height: 45,
                                    child: ElevatedButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.greenAccent[400]!),
                                          overlayColor: MaterialStateProperty
                                              .resolveWith<Color?>(
                                            (Set<MaterialState> states) {
                                              if (states.contains(
                                                  MaterialState.hovered))
                                                return Colors.greenAccent[300]!;
                                              if (states.contains(
                                                      MaterialState.focused) ||
                                                  states.contains(
                                                      MaterialState.pressed))
                                                return Colors.lightGreenAccent;
                                              return null; // Defer to the widget's default.
                                            },
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      NewProduct(
                                                          widget
                                                              .currentBusiness,
                                                          categoriesProvider
                                                              .categoryList!,
                                                          widget.businessField,
                                                          null)));
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 5),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.add,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                'Agregar Producto',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )
                                            ],
                                          ),
                                        )),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                ],
              ),
            ),
          ),
        ),
        //Titles
        SliverAppBar(
          backgroundColor: Colors.white,
          pinned: true,
          automaticallyImplyLeading: false,
          actions: <Widget>[Container()],
          flexibleSpace: SizedBox(
            width: double.infinity,
            height: 50,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //Imagen
                Container(
                    width: 75,
                    child: Text(
                      'Imagen',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black54),
                    )),
                //Nombre
                Container(
                    width: 150,
                    child: Text(
                      'Producto',
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black54),
                    )),
                //Código
                (MediaQuery.of(context).size.width > 800)
                    ? Container(
                        width: 100,
                        child: Text(
                          'Código',
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54),
                        ))
                    : SizedBox(),

                //Categoria
                (MediaQuery.of(context).size.width > 975)
                    ? Container(
                        width: 150,
                        child: Text(
                          'Categoría',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54),
                        ))
                    : SizedBox(),

                //Precio
                Container(
                    width: 150,
                    child: Text(
                      'Precio',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black54),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
                //Costo
                Container(
                    width: 150,
                    child: Text(
                      'Costo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black54),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),

                //Margen de ganancia
                (MediaQuery.of(context).size.width > 850)
                    ? Container(
                        width: 100,
                        child: Text(
                          'Margen %',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ))
                    : SizedBox(),
              ],
            ),
          ),
        ),
        //List of Products
        (name != '')
            ? StreamProvider<List<Products>>.value(
                initialData: [],
                value: DatabaseService().productListbyName(
                    name.toLowerCase(), widget.currentBusiness),
                child: ProductList(
                    widget.currentBusiness,
                    categoriesProvider.categoryList!,
                    widget.businessField,
                    loadMore,
                    limitSearch))
            : (selectedCategory != 'Todas las categorías')
                ? StreamProvider<List<Products>>.value(
                    initialData: [],
                    value: DatabaseService().productListbyCategory(
                        selectedCategory, widget.currentBusiness, limitSearch),
                    child: ProductList(
                        widget.currentBusiness,
                        categoriesProvider.categoryList!,
                        widget.businessField,
                        loadMore,
                        limitSearch))
                : StreamProvider<List<Products>>.value(
                    initialData: [],
                    value: DatabaseService()
                        .allProductList(widget.currentBusiness, limitSearch),
                    child: ProductList(
                        widget.currentBusiness,
                        categoriesProvider.categoryList!,
                        widget.businessField,
                        loadMore,
                        limitSearch))
      ]));
    } else {
      return Scaffold(
          body: CustomScrollView(slivers: [
        //Go Back /// Title //Filters
        SliverAppBar(
          floating: true,
          backgroundColor: Colors.white,
          pinned: false,
          automaticallyImplyLeading: false,
          actions: <Widget>[Container()],
          expandedHeight: 150,
          flexibleSpace: FlexibleSpaceBar(
            background: Column(
              children: [
                // Title
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            'Productos',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Spacer(),
                        //Promos
                        Container(
                          height: 40,
                          width: 40,
                          child: Tooltip(
                            message: 'Descuentos',
                            child: OutlinedButton(
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all<
                                    EdgeInsetsGeometry>(EdgeInsets.all(5)),
                                alignment: Alignment.center,
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.white70),
                                overlayColor:
                                    MaterialStateProperty.resolveWith<Color?>(
                                  (Set<MaterialState> states) {
                                    if (states.contains(MaterialState.hovered))
                                      return Colors.grey.shade300;
                                    if (states
                                            .contains(MaterialState.focused) ||
                                        states.contains(MaterialState.pressed))
                                      return Colors.white;
                                    return null; // Defer to the widget's default.
                                  },
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => StreamProvider<
                                                List<Discounts>>.value(
                                              initialData: [],
                                              value: DatabaseService()
                                                  .allDiscountsList(
                                                      widget.currentBusiness),
                                              child: DiscountsList(
                                                  widget.currentBusiness),
                                            )));
                              },
                              child: Center(
                                  child: Text(
                                '%',
                                style: TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.grey.shade900),
                              )),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        //Boton de categorias
                        Container(
                          height: 40,
                          width: 40,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black,
                              padding: EdgeInsets.all(5),
                              alignment: Alignment.center,
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          StreamProvider<List<Products>>.value(
                                              initialData: [],
                                              value: DatabaseService()
                                                  .allProductListNoLimit(
                                                      widget.currentBusiness),
                                              child: CategoriesDesk(
                                                  widget.currentBusiness,
                                                  categoriesProvider
                                                      .categoryList!,
                                                  widget.reloadApp))));
                            },
                            child: Center(
                                child: Icon(
                              Icons.list,
                              size: 18,
                              color: Colors.black,
                            )),
                          ),
                        ),
                        SizedBox(width: 5),
                        //Boton de agregar
                        Container(
                          height: 40,
                          child: FloatingActionButton(
                            backgroundColor: Colors.greenAccent,
                            foregroundColor: Colors.black,
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => NewProduct(
                                          widget.currentBusiness,
                                          categoriesProvider.categoryList!,
                                          widget.businessField,
                                          null)));
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
                //Filters
                Container(
                    height: 50,
                    width: double.infinity,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        //Proveedor
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Container(
                            width: 250,
                            height: 45,
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: TextFormField(
                              controller: nameController,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14),
                              cursorColor: Colors.grey,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.all(2),
                                  iconSize: 14,
                                  splashRadius: 15,
                                  onPressed: () {
                                    setState(() {
                                      showSearchOptions = false;
                                      nameController.text = '';
                                      name = '';
                                    });
                                  },
                                  icon: Icon(Icons.close),
                                  color: Colors.black,
                                ),
                                hintText: 'Nombre',
                                hintStyle: TextStyle(
                                    color: Colors.black45, fontSize: 14),
                                border: new OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(12.0),
                                  borderSide: new BorderSide(
                                    color: Colors.grey[350]!,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(12.0),
                                  borderSide: new BorderSide(
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  name = val;
                                  selectedCategory = 'Todas las categorías';
                                  if (val != '') {
                                    showSearchOptions = true;
                                  } else {
                                    showSearchOptions = false;
                                  }
                                });
                              },
                              onFieldSubmitted: ((value) {
                                setState(() {
                                  selectedProduct = value;
                                  selectedCategory = 'Todas las categorías';
                                });
                              }),
                            ),
                          ),
                        ),
                        //Payment Method
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: TextButton(
                            style: ButtonStyle(
                              overlayColor:
                                  MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.hovered)) {
                                    return Colors.greenAccent.withOpacity(
                                        0.2); // Customize the hover color here
                                  }
                                  return null; // Use default overlay color for other states
                                },
                              ),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.grey.shade300.withOpacity(0.2)),
                            ),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Dialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0)),
                                      child: Container(
                                          width: 400,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.8,
                                          padding: EdgeInsets.all(20),
                                          child: SingleChildScrollView(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                //Cancel Icon
                                                Container(
                                                  alignment:
                                                      Alignment(1.0, 0.0),
                                                  child: IconButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                      icon: Icon(Icons.close),
                                                      iconSize: 20.0),
                                                ),
                                                SizedBox(height: 10),
                                                //Title
                                                Container(
                                                  width: double.infinity,
                                                  child: Text(
                                                    'Categorías',
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    softWrap: true,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ),
                                                SizedBox(height: 20),
                                                //Payment Methods
                                                ListView.builder(
                                                    itemCount:
                                                        listOfCategories.length,
                                                    shrinkWrap: true,
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    itemBuilder: (context, i) {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 10.0),
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .black12,
                                                                  width: 1),
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          12))),
                                                          child: InkWell(
                                                            onTap: () {
                                                              setState(() {
                                                                selectedCategory =
                                                                    listOfCategories[
                                                                        i];
                                                                selectedProduct =
                                                                    null;
                                                                nameController
                                                                    .text = '';
                                                                name = '';
                                                                filtered = true;
                                                              });
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      12.0),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  //Name
                                                                  Text(
                                                                    listOfCategories[
                                                                        i],
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight.normal),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                              ],
                                            ),
                                          )),
                                    );
                                  });
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.account_balance_wallet_outlined,
                                  size: 16,
                                  color: Colors.black,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  (selectedCategory != 'Todas las categorías')
                                      ? selectedCategory
                                      : 'Categorías',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                        //Remove
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: TextButton(
                            style: ButtonStyle(
                              overlayColor:
                                  MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.hovered)) {
                                    return Colors.greenAccent.withOpacity(
                                        0.2); // Customize the hover color here
                                  }
                                  return null; // Use default overlay color for other states
                                },
                              ),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.grey.shade300.withOpacity(0.2)),
                            ),
                            onPressed: () {
                              setState(() {
                                filtered = false;
                                showSearchOptions = false;
                                selectedCategory = 'Todas las categorías';
                                selectedProduct = '';
                                name = '';
                              });
                            },
                            child: Icon(
                              Icons.filter_alt_off_outlined,
                              size: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ),
        //List of Products
        (name != '')
            ? StreamProvider<List<Products>>.value(
                initialData: [],
                value: DatabaseService().productListbyName(
                    name.toLowerCase(), widget.currentBusiness),
                child: ProductList(
                    widget.currentBusiness,
                    categoriesProvider.categoryList!,
                    widget.businessField,
                    loadMore,
                    limitSearch))
            : (selectedCategory != 'Todas las categorías')
                ? StreamProvider<List<Products>>.value(
                    initialData: [],
                    value: DatabaseService().productListbyCategory(
                        selectedCategory, widget.currentBusiness, limitSearch),
                    child: ProductList(
                        widget.currentBusiness,
                        categoriesProvider.categoryList!,
                        widget.businessField,
                        loadMore,
                        limitSearch))
                : StreamProvider<List<Products>>.value(
                    initialData: [],
                    value: DatabaseService()
                        .allProductList(widget.currentBusiness, limitSearch),
                    child: ProductList(
                        widget.currentBusiness,
                        categoriesProvider.categoryList!,
                        widget.businessField,
                        loadMore,
                        limitSearch))
      ]));
    }
  }
}

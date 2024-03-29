import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denario/Models/Categories.dart';
import 'package:denario/Models/DailyCash.dart';
import 'package:denario/Models/Expenses.dart';
import 'package:denario/Models/Mapping.dart';
import 'package:denario/Models/Payables.dart';
import 'package:denario/Models/PendingOrders.dart';
import 'package:denario/Models/Products.dart';
import 'package:denario/Models/Receivables.dart';
import 'package:denario/Models/Sales.dart';
import 'package:denario/Models/SavedOrders.dart';
import 'package:denario/Models/ScheduledSales.dart';
import 'package:denario/Models/Stats.dart';
import 'package:denario/Models/Supplier.dart';
import 'package:denario/Models/Supply.dart';
import 'package:denario/Models/Tables.dart';
import 'package:denario/Models/User.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Models/Discounts.dart';

class DatabaseService {
  //User Profile
  Future createUserProfile(String uid, String name, int tlf, String rol,
      String businessName, String businessID, List usage) async {
    return await FirebaseFirestore.instance.collection('Users').doc(uid).set({
      'UID': uid,
      'Name': name,
      'Phone': tlf,
      'Profile Image':
          'https://firebasestorage.googleapis.com/v0/b/cafe-galia.appspot.com/o/Profile%20Images%2FGeneric.png?alt=media&token=73dc5476-197b-4559-861f-ebd9d20907b9',
      'Active Business': businessID,
      'Businesses': [
        {
          'Business ID': businessID,
          'Business Name': businessName,
          'Business Rol': rol,
          'Table View': false
        }
      ],
      'App Intended Usage': usage,
    });
  }

  Future updateUserProfile(String name, int tlf, String pic) async {
    final User user = FirebaseAuth.instance.currentUser;
    final String uid = user.uid.toString();

    return await FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .update({
      'Name': name,
      'Phone': tlf,
      'Profile Image': pic,
    });
  }

  Future deleteUserBusiness(userBusiness, uid) async {
    return await FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .update({
      'Businesses': FieldValue.arrayRemove([userBusiness])
    });
  }

  Future updateUserBusinessProfile(Map newsUerBusiness, uid) async {
    return await FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .update({
      'Businesses': FieldValue.arrayUnion([newsUerBusiness])
    });
  }

  Future updateUserBusiness(
      String businessID,
      String businessName,
      String businessLocation,
      int businessSize,
      String businessPic,
      // String catalogBackgroundImage,
      List socialMedia,
      List businessSchedule) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .update({
      'Business Name': businessName,
      'Business Location': businessLocation,
      'Business Size': businessSize,
      'Business Image': businessPic,
      // 'Catalog Background Image': catalogBackgroundImage,
      'Social Media': socialMedia,
      'Business Schedule': businessSchedule
    });
  }

  Future updateBusinessStoreConfig(String businessID,
      String catalogBackgroundImage, List visibleStoreCategories) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .update({
      'Catalog Background Image': catalogBackgroundImage,
      'Visible Store Categories': visibleStoreCategories,
    });
  }

  Future changeActiveBusiness(String businessID) async {
    final User user = FirebaseAuth.instance.currentUser;
    final String uid = user.uid.toString();

    return await FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .update({
      'Active Business': businessID,
    });
  }

  //Get User Profile
  UserData _userProfileFromSnapshot(DocumentSnapshot snapshot) {
    try {
      return UserData(
          name: snapshot['Name'],
          phone: snapshot['Phone'],
          profileImage: snapshot['Profile Image'],
          activeBusiness: snapshot['Active Business'],
          uid: snapshot['UID'],
          businesses: !snapshot['Businesses'].isEmpty
              ? snapshot['Businesses'].map<UserBusinessData>((item) {
                  return UserBusinessData(
                    item['Business ID'] ?? '',
                    item['Business Name'] ?? '',
                    item['Business Rol'] ?? 0,
                    item.toString().contains('Table View')
                        ? item['Table View']
                        : false,
                  );
                }).toList()
              : [],
          usage: snapshot['App Intended Usage']);
    } catch (e) {
      print(e);
      return null;
    }
  }

  //User Stream
  Stream<UserData> userProfile(String uid) async* {
    yield* FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .snapshots()
        .map(_userProfileFromSnapshot);
  }

  //Get User Business Profile
  BusinessProfile _userBusinessProfileFromSnapshot(DocumentSnapshot snapshot) {
    try {
      return BusinessProfile(
          businessID: snapshot.data().toString().contains('Business ID')
              ? snapshot['Business ID']
              : '',
          businessName: snapshot.data().toString().contains('Business Name')
              ? snapshot['Business Name']
              : '',
          businessField: snapshot.data().toString().contains('Business Field')
              ? snapshot['Business Field']
              : '',
          businessImage: snapshot.data().toString().contains('Business Image')
              ? snapshot['Business Image']
              : '',
          businessSize: snapshot.data().toString().contains('Business Size')
              ? snapshot['Business Size']
              : 0,
          businessLocation:
              snapshot.data().toString().contains('Business Location')
                  ? snapshot['Business Location']
                  : '',
          businessUsers: snapshot.data().toString().contains('Business Users')
              ? snapshot['Business Users']
              : [],
          businessBackgroundImage:
              snapshot.data().toString().contains('Catalog Background Image')
                  ? snapshot['Catalog Background Image']
                  : '',
          businessSchedule:
              snapshot.data().toString().contains('Business Schedule')
                  ? snapshot['Business Schedule']
                  : [],
          socialMedia: snapshot.data().toString().contains('Social Media')
              ? snapshot['Social Media']
              : [],
          visibleStoreCategories:
              snapshot.data().toString().contains('Visible Store Categories')
                  ? snapshot['Visible Store Categories']
                  : ['All'],
          paymentMethods: snapshot.data().toString().contains('Payment Types')
              ? snapshot['Payment Types']
              : [
                  {
                    'Method': 'Efectivo',
                    'Image':
                        'https://firebasestorage.googleapis.com/v0/b/cafe-galia.appspot.com/o/App%20Assets%2FPayment%20Methods%2Ficons8-cash-100.png?alt=media&token=9d58b0f5-dcff-4ecb-bc8c-ffc51d05dc94'
                  },
                  {
                    'Method': 'Tarjeta de Débito',
                    'Image':
                        'https://firebasestorage.googleapis.com/v0/b/cafe-galia.appspot.com/o/App%20Assets%2FPayment%20Methods%2Ficons8-credit-card-80.png?alt=media&token=b349ec08-93ea-4120-91b8-c1b0a643c7da'
                  },
                  {
                    'Method': 'QR',
                    'Image':
                        'https://firebasestorage.googleapis.com/v0/b/cafe-galia.appspot.com/o/App%20Assets%2FPayment%20Methods%2Ficons8-qr-code-96.png?alt=media&token=a3a9d2f5-3ba6-4775-aaf9-a22159997694'
                  },
                  {
                    'Method': 'Transferencia Bancaria',
                    'Image':
                        'https://firebasestorage.googleapis.com/v0/b/cafe-galia.appspot.com/o/App%20Assets%2FPayment%20Methods%2Ficons8-bank-transfer-58.png?alt=media&token=71680c7e-a20c-4601-ba2d-3ea792c7c550'
                  },
                ],
          cashBalancing: snapshot.data().toString().contains('Arqueo de Caja')
              ? snapshot['Arqueo de Caja']
              : true);
    } catch (e) {
      print(e);
      return null;
    }
  }

  //User Business Stream
  Stream<BusinessProfile> userBusinessProfile(String businessID) async* {
    yield* FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .snapshots()
        .map(_userBusinessProfileFromSnapshot);
  }

  //Create Business Profile
  Future createBusinessProfile(
      String userUID,
      String userRol,
      String businessName,
      String businessID,
      String businessField,
      String businessLocation,
      int businessSize,
      List usage,
      bool cashBalancing) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .set({
      'Arqueo de Caja': cashBalancing,
      'Caja Abierta': false,
      'Caja Actual': '',
      'Payment Types': [
        {
          'Type': 'Efectivo',
          'Image':
              'https://firebasestorage.googleapis.com/v0/b/cafe-galia.appspot.com/o/App%20Assets%2FPayment%20Methods%2Ficons8-cash-100.png?alt=media&token=9d58b0f5-dcff-4ecb-bc8c-ffc51d05dc94'
        },
        {
          'Type': 'QR',
          'Image':
              'https://firebasestorage.googleapis.com/v0/b/cafe-galia.appspot.com/o/App%20Assets%2FPayment%20Methods%2Ficons8-qr-code-96.png?alt=media&token=a3a9d2f5-3ba6-4775-aaf9-a22159997694'
        },
        {
          'Type': 'Tarjeta de Débito',
          'Image':
              'https://firebasestorage.googleapis.com/v0/b/cafe-galia.appspot.com/o/App%20Assets%2FPayment%20Methods%2Ficons8-credit-card-80.png?alt=media&token=b349ec08-93ea-4120-91b8-c1b0a643c7da'
        },
        {
          'Type': 'Transferencia Bancaria',
          'Image':
              'https://firebasestorage.googleapis.com/v0/b/cafe-galia.appspot.com/o/App%20Assets%2FPayment%20Methods%2Ficons8-bank-transfer-58.png?alt=media&token=71680c7e-a20c-4601-ba2d-3ea792c7c550'
        }
      ],
      'Business Name': businessName,
      'Business Image': '',
      'Business ID': businessID,
      'Business Field': businessField,
      'Business Location': businessLocation,
      'Business Size': businessSize,
      'Business Users': ['$userUID'],
      'Catalog Background Image': '',
      'Social Media': [],
      'Business Schedule': [
        {
          'Open': {'Hour': 09, 'Minute': 00},
          'Close': {'Hour': 20, 'Minute': 00},
          'Opens': true
        },
        {
          'Open': {'Hour': 09, 'Minute': 00},
          'Close': {'Hour': 20, 'Minute': 00},
          'Opens': true
        },
        {
          'Open': {'Hour': 09, 'Minute': 00},
          'Close': {'Hour': 20, 'Minute': 00},
          'Opens': true
        },
        {
          'Open': {'Hour': 09, 'Minute': 00},
          'Close': {'Hour': 20, 'Minute': 00},
          'Opens': true
        },
        {
          'Open': {'Hour': 09, 'Minute': 00},
          'Close': {'Hour': 20, 'Minute': 00},
          'Opens': true
        },
        {
          'Open': {'Hour': 09, 'Minute': 00},
          'Close': {'Hour': 20, 'Minute': 00},
          'Opens': true
        },
        {
          'Open': {'Hour': 09, 'Minute': 00},
          'Close': {'Hour': 20, 'Minute': 00},
          'Opens': true
        },
      ],
      'Visible Store Categories': ['All']
    });
  }

  //Add user to Business Profile
  Future addUsertoBusiness(String businessID, String uid) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .update({
      'Business Users': FieldValue.arrayUnion([uid])
    });
  }

  //Add user to Business Profile
  Future updateBusinessPaymentTypes(
      String businessID, List paymentTypes) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .update({'Payment Types': paymentTypes});
  }

  //Create Business Categories
  Future createBusinessERPcategories(String businessID) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection('Master Data')
        .doc('Categories')
        .set({
      'Category List': ['Principal', 'Otros'],
    });
  }

  //Edit Categories
  Future editBusinessCategories(String businessID, List newCategoryList) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection('Master Data')
        .doc('Categories')
        .set({
      'Category List': newCategoryList,
    });
  }

  //Create High Levl Mapping
  Future createBusinessERPmapping(
    String businessID,
  ) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection('Master Data')
        .doc('High Level Mapping')
        .set({
      'Expense Group Mapping': [
        'Costo de Ventas',
        'Gastos de Empleados',
        'Gastos del Local',
        'Otros Gastos'
      ],
      'Expense Input Mapping': {
        'Costo de Ventas': {
          'Category': 'Principal',
          'Description': 'Gasto',
          'Vendor': 'Proveedor 1'
        },
        'Gastos de Empleados': {
          'Category': 'Salarios',
          'Description': 'Salarios',
          'Vendor': 'Empleado 1'
        },
        'Gastos del Local': {
          'Category': 'Alquiler del Local',
          'Description': 'Alquiler',
          'Vendor': 'Locador'
        },
        'Otros Gastos': {
          'Category': 'Servicios Profesionales',
          'Description': 'Fumigación',
          'Vendor': 'Fumigador'
        },
      },
      'PnL Account Group Mapping': [
        'Ventas',
        'Costo de Ventas',
        'Gastos de Empleados',
        'Gastos del Local',
        'Otros Gastos'
      ],
      'PnL Mapping': {
        'Costo de Ventas': ['Costos de Principal', 'Costos de Otros'],
        'Gastos de Empleados': [
          'Salarios',
          'Impuestos de Nómina',
          'Alimentación y Entretenimiento',
          'Otros Gastos de Empleados'
        ],
        'Gastos del Local': [
          'Insumos Generales',
          'Alquiler del Local',
          'Servicios del Local'
        ],
        'Otros Gastos': [
          'Servicios Profesionales',
          'Reparaciones y Mantenimiento',
          'Promoción y Publicidad',
          'Cargos Bancarios',
          'Seguros',
          'Mobiliario y Materiales del Local',
          'Impuestos',
          'Misceláneos'
        ],
        'Ventas': ['Ventas de Principal', 'Ventas de Otros']
      }
    });
  }

  //Create Account Mapping
  // Future createBusinessERPaccountMapping(
  //   String businessID,
  // ) async {
  //   return await FirebaseFirestore.instance
  //       .collection('ERP')
  //       .doc(businessID)
  //       .collection('Master Data')
  //       .doc('Account Mapping')
  //       .set({
  //     'Account Mapping': {
  //       'Costo de Ventas': [
  //         {
  //           'Category': 'Principal',
  //           'Description': 'Insumos',
  //           'Vendors': ['Proveedor 1']
  //         },
  //         {
  //           'Category': 'Otros',
  //           'Description': 'Insumos',
  //           'Vendors': ['Proveedor 1']
  //         }
  //       ],
  //       'Gastos de Empleados': [
  //         {
  //           'Category': 'Salarios',
  //           'Description': 'Salarios',
  //           'Vendors': ['Empleado 1', 'Empleado 2']
  //         },
  //         {
  //           'Category': 'Impuestos de Nómina',
  //           'Description': 'Cargas Sociales',
  //           'Vendors': ['AFIP', 'AGIP']
  //         },
  //         {
  //           'Category': 'Alimentación y Entretenimiento',
  //           'Description': 'Alimentación',
  //           'Vendors': ['Mercado', 'Verdulería', 'Otro']
  //         },
  //         {
  //           'Category': 'Otros Gastos de Empleados',
  //           'Description': 'Insumos',
  //           'Vendors': ['Mercado', 'Farmacia', 'Taxi', 'Otro']
  //         }
  //       ],
  //       'Gastos del Local': [
  //         {
  //           'Category': 'Insumos Generales',
  //           'Description': 'Insumos',
  //           'Vendors': ['Mercado', 'Papelería', 'Otro']
  //         },
  //         {
  //           'Category': 'Alquiler del Local',
  //           'Description': 'Alquiler',
  //           'Vendors': ['Locador', 'Consorcio de Propietarios']
  //         },
  //         {
  //           'Category': 'Servicios del Local',
  //           'Description': 'Servicios del Local',
  //           'Vendors': ['Edenor', 'Metrogas', 'Telecentro']
  //         },
  //       ],
  //       'Otros Gastos': [
  //         {
  //           'Category': 'Servicios Profesionales',
  //           'Description': 'Fumigación',
  //           'Vendors': ['Fumigador', 'Contador', 'Otro']
  //         },
  //         {
  //           'Category': 'Reparaciones y Mantenimiento',
  //           'Description': 'Reparaciones',
  //           'Vendors': ['Electricista', 'Plomero', 'Otro']
  //         },
  //         {
  //           'Category': 'Promoción y Publicidad',
  //           'Description': 'Promoción',
  //           'Vendors': ['Imprenta', 'Agencia Publicitaria', 'Otro']
  //         },
  //         {
  //           'Category': 'Cargos Bancarios',
  //           'Description': 'Comisión Bancaria',
  //           'Vendors': ['Banco', 'MercadoPago', 'Otro']
  //         },
  //         {
  //           'Category': 'Seguros',
  //           'Description': 'Seguro de Responsabilidad Civíl',
  //           'Vendors': ['Aseguradora', 'Banco', 'Otro']
  //         },
  //         {
  //           'Category': 'Mobiliario y Materiales del Local',
  //           'Description': 'Compras de Materiales',
  //           'Vendors': ['Librería', 'Mercado', 'Otro']
  //         },
  //         {
  //           'Category': 'Impuestos',
  //           'Description': 'Impuesto',
  //           'Vendors': ['AFIP', 'AGIP', 'Otro']
  //         },
  //         {
  //           'Category': 'Misceláneos',
  //           'Description': 'Misceláneo',
  //           'Vendors': ['AFIP', 'AGIP', 'Otro']
  //         },
  //       ]
  //     },
  //   });
  // }

  //Create Product List
  Future createBusinessProductList(String businessID) async {
    return await FirebaseFirestore.instance
        .collection('Products')
        .doc(businessID)
        .collection('Menu')
        .doc('Producto 1')
        .set({
      'Available': true,
      'Category': 'Principal',
      'Image': '',
      'Product': 'Producto 1',
      'Price': 100,
      'Description': 'Ejemplo de producto estándar',
      'Code': '',
      'Product Options': [],
      'Historic Prices': [
        {'From Date': DateTime.now(), 'To Date': null, 'Price': 100}
      ],
      'Search Name': [
        'p',
        'pr',
        'pro',
        'prod',
        'produ',
        'produc',
        'producto',
        'producto 1',
      ],
      'Ingredients': [],
      'Vegan': false,
      'Show': true,
    });
  }

  //Changing business profile settings
  //Categories =>
  //// change categories list,
  //// update costo de ventas en PnL Mapping on Account Mapping doc,
  //// category, description and supplier on Account Mapping
  //Expense groups modify all mappings => Request subaccounts, vendors, etc

  ///////////////////////// PRODUCTS //////////////////////////

  // Product List from snapshot
  List<Products> _productListFromSnapshot(QuerySnapshot snapshot) {
    try {
      return snapshot.docs.map((doc) {
        return Products(
          product:
              doc.data().toString().contains('Product') ? doc['Product'] : '',
          price: doc.data().toString().contains('Price') ? doc['Price'] : 0,
          category:
              doc.data().toString().contains('Category') ? doc['Category'] : '',
          image: doc.data().toString().contains("Image") ? doc['Image'] : '',
          description: doc.data().toString().contains('Description')
              ? doc['Description']
              : '',
          productOptions: doc.data().toString().contains('Product Options')
              ? doc['Product Options'].map<ProductOptions>((item) {
                  return ProductOptions(
                    item.toString().contains('Title') ? item['Title'] : '',
                    item.toString().contains('Mandatory')
                        ? item['Mandatory']
                        : false,
                    item.toString().contains('Multiple Options')
                        ? item['Multiple Options']
                        : false,
                    item.toString().contains('Price Structure')
                        ? item['Price Structure']
                        : 'Non',
                    item.toString().contains('Price Options')
                        ? item['Price Options']
                        : [],
                  );
                }).toList()
              : [],
          available: doc.data().toString().contains('Available')
              ? doc['Available']
              : true,
          productID: doc.id,
          historicPrices: doc.data().toString().contains('Historic Prices')
              ? doc['Historic Prices']
              : [],
          code: doc.data().toString().contains('Code') ? doc['Code'] : '',
          searchName: doc.data().toString().contains('Search Name')
              ? doc['Search Name']
              : [],
          listOfIngredients:
              doc.data().toString().contains('List of Ingredients')
                  ? doc['List of Ingredients']
                  : [],
          ingredients: doc.data().toString().contains('Ingredients')
              ? doc['Ingredients']
              : [],
          vegan: doc.data().toString().contains('Vegan') ? doc['Vegan'] : false,
          showOnMenu:
              doc.data().toString().contains('Show') ? doc['Show'] : true,
          featured: doc.data().toString().contains('Featured')
              ? doc['Featured']
              : false,
          expectedMargin: doc.data().toString().contains('Expected Margin')
              ? (doc['Expected Margin'] != null)
                  ? doc['Expected Margin']
                  : 0
              : 0,
          lowMarginAlert: doc.data().toString().contains('Low Margin Alert')
              ? (doc['Low Margin Alert'] != null)
                  ? doc['Low Margin Alert']
                  : 0
              : 0,
        );
      }).toList();
    } catch (e) {
      print(e);
      return null;
    }
  }

  //Create Product
  Future createProduct(
      String businessID,
      name,
      image,
      category,
      double price,
      description,
      productOptions,
      searchName,
      code,
      listOfIngredients,
      ingredients,
      vegan,
      show,
      featured,
      double expectedMargin,
      double lowMarginAlert) async {
    return await FirebaseFirestore.instance
        .collection('Products')
        .doc(businessID)
        .collection('Menu')
        .doc(code + ' ' + name)
        .set({
      'Available': true,
      'Category': category,
      'Image': image,
      'Product': name,
      'Price': price,
      'Description': description,
      'Code': code,
      'Product Options': productOptions,
      'Historic Prices': [
        {'From Date': DateTime.now(), 'To Date': null, 'Price': price}
      ],
      'Search Name': searchName,
      'List Of Ingredients': listOfIngredients,
      'Ingredients': ingredients,
      'Vegan': vegan,
      'Show': show,
      'Featured': featured,
      'Expected Margin': (expectedMargin == null) ? 0 : expectedMargin,
      'Low Margin Alert': (lowMarginAlert == null) ? 0 : lowMarginAlert
    });
  }

  //Edit Product
  Future editProduct(
      String businessID,
      productID,
      bool available,
      name,
      image,
      category,
      double price,
      description,
      productOptions,
      searchName,
      code,
      listOfIngredients,
      ingredients,
      vegan,
      show,
      historicPrices,
      featured,
      double expectedMargin,
      double lowMarginAlert) async {
    return await FirebaseFirestore.instance
        .collection('Products')
        .doc(businessID)
        .collection('Menu')
        .doc(productID)
        .update({
      'Available': available,
      'Category': category,
      'Image': image,
      'Product': name,
      'Price': price,
      'Description': description,
      'Code': code,
      'Product Options': productOptions,
      'Historic Prices': historicPrices,
      'Search Name': searchName,
      'List Of Ingredients': listOfIngredients,
      'Ingredients': ingredients,
      'Vegan': vegan,
      'Show': show,
      'Featured': featured,
      'Expected Margin': expectedMargin,
      'Low Margin Alert': lowMarginAlert
    });
  }

  //Edit product supply
  Future editProductSupply(
    String businessID,
    productID,
    ingredients,
  ) async {
    return await FirebaseFirestore.instance
        .collection('Products')
        .doc(businessID)
        .collection('Menu')
        .doc(productID)
        .update({
      'Ingredients': ingredients,
    });
  }

  // Product Stream by categpry
  Stream<List<Products>> productList(
      String category, String businessID) async* {
    yield* FirebaseFirestore.instance
        .collection('Products')
        .doc(businessID)
        .collection('Menu')
        .where('Category', isEqualTo: category)
        .snapshots()
        .map(_productListFromSnapshot);
  }

  Stream<List<Products>> fullProductList(String businessID) async* {
    yield* FirebaseFirestore.instance
        .collection('Products')
        .doc(businessID)
        .collection('Menu')
        .snapshots()
        .map(_productListFromSnapshot);
  }

  Stream<List<Products>> productListbyCategory(
      String category, String businessID, int limit) async* {
    yield* FirebaseFirestore.instance
        .collection('Products')
        .doc(businessID)
        .collection('Menu')
        .where('Category', isEqualTo: category)
        .limit(limit)
        .snapshots()
        .map(_productListFromSnapshot);
  }

  // Product Stream by name
  Stream<List<Products>> productListbyentireName(
      String name, String businessID) async* {
    yield* FirebaseFirestore.instance
        .collection('Products')
        .doc(businessID)
        .collection('Menu')
        .where('Product', isEqualTo: name)
        .snapshots()
        .map(_productListFromSnapshot);
  }

  Stream<List<Products>> productListbyName(
      String name, String businessID) async* {
    yield* FirebaseFirestore.instance
        .collection('Products')
        .doc(businessID)
        .collection('Menu')
        .where('Search Name', arrayContains: name)
        .snapshots()
        .map(_productListFromSnapshot);
  }

  // Product Stream
  Stream<List<Products>> allProductList(String businessID, int limit) async* {
    yield* FirebaseFirestore.instance
        .collection('Products')
        .doc(businessID)
        .collection('Menu')
        .limit(limit)
        .snapshots()
        .map(_productListFromSnapshot);
  }

  Stream<List<Products>> allProductListNoLimit(String businessID) async* {
    yield* FirebaseFirestore.instance
        .collection('Products')
        .doc(businessID)
        .collection('Menu')
        .snapshots()
        .map(_productListFromSnapshot);
  }

  //Make Product Availble/Unavailable
  Future updateProductAvailability(
      String businessID, String productID, bool available) async {
    return await FirebaseFirestore.instance
        .collection('Products')
        .doc(businessID)
        .collection('Menu')
        .doc(productID)
        .update({
      'Available': available,
    });
  }

  Future deleteProduct(String businessID, String productID) async {
    return await FirebaseFirestore.instance
        .collection('Products')
        .doc(businessID)
        .collection('Menu')
        .doc(productID)
        .delete();
  }

  ///////////////////////// ORDERS //////////////////////////

  // Save order function
  void saveNewOrder(
      String documentID,
      String activeBusiness,
      bool splitPayment,
      List splitPaymentDetails,
      invoiceNO,
      cashRegister,
      bool isTable,
      tableCode,
      bool isSavedOrder,
      savedOrderID,
      bool reveresed,
      orderName,
      cartList,
      subtotal,
      total,
      paymentType,
      orderType,
      tax,
      discount,
      discountCode) async {
    //Date variables
    var year = DateTime.now().year.toString();
    var month = DateTime.now().month.toString();

    //Gather TicketBloc values before they get cleared using doc.get()
    // final cartList = bloc.ticketItems['Items'];
    // final subtotal = bloc.subtotalTicketAmount;
    // final total = bloc.totalTicketAmount;
    // final paymentType = bloc.ticketItems['Payment Type'];
    // final orderType = bloc.ticketItems['Order Type'];
    // final discountCode = bloc.ticketItems['Discount Code'];

    //Get total ingredients cost
    double totalCostOfIngredients = 0;
    for (var i = 0; i < cartList.length; i++) {
      double totalCost = 0;
      List ingredients = cartList[i]['Supplies'];
      if (ingredients.length > 0) {
        //Loop through supplies
        for (int x = 0; x < ingredients.length; x++) {
          //Check Ingredient total
          if (ingredients[x]['Supply Cost'] != null &&
              ingredients[x]['Supply Quantity'] != null &&
              ingredients[x]['Quantity'] != null &&
              ingredients[x]['Yield'] != null) {
            double ingredientTotal = ((ingredients[x]['Supply Cost'] /
                        ingredients[x]['Supply Quantity']) *
                    ingredients[x]['Quantity']) /
                ingredients[x]['Yield'];
            //Add Ingredient Total to product cost if not null
            if (!ingredientTotal.isNaN &&
                !ingredientTotal.isInfinite &&
                !ingredientTotal.isNegative &&
                ingredientTotal != null) {
              totalCost = totalCost + ingredientTotal;
            }
          }
        }
        if (totalCost != null && totalCost > 0) {
          totalCostOfIngredients = totalCostOfIngredients + totalCost;
        }
      }
    }

    // //////////Create Sale
    createOrder(
        activeBusiness,
        documentID,
        year,
        month,
        DateTime.now(),
        subtotal,
        discount,
        tax,
        total,
        cartList,
        orderName,
        splitPayment ? 'Split' : paymentType,
        orderName,
        {
          'Name': orderName,
          'Address': '',
          'Phone': 0,
          'email': '',
        },
        invoiceNO,
        (cashRegister == null) ? 'Independiente' : cashRegister,
        false,
        splitPaymentDetails,
        orderType,
        totalCostOfIngredients);

    if (discountCode != '') {
      useDiscount(activeBusiness, discountCode);
      registerDiscountUse(
          discountCode,
          activeBusiness,
          documentID,
          year,
          month,
          DateTime.now(),
          subtotal,
          discount,
          tax,
          total,
          cartList,
          orderName,
          splitPayment ? 'Split' : paymentType,
          orderName,
          {
            'Name': orderName,
            'Address': '',
            'Phone': 0,
            'email': '',
          },
          invoiceNO,
          (cashRegister == null) ? 'Independiente' : cashRegister,
          false,
          splitPaymentDetails,
          orderType);
    }

    // ////////////////////////Update Accounts (sales and categories)

    //Firestore reference
    var firestore = FirebaseFirestore.instance;
    var docRef = firestore
        .collection('ERP')
        .doc(activeBusiness)
        .collection(year)
        .doc(month);

    final doc = await docRef.get();

    try {
      if (doc.exists) {
        docRef.update({'Ventas': FieldValue.increment(total)});
      } else {
        docRef.set({'Ventas': total});
      }
    } catch (error) {
      print('Error updating Total Sales Value: $error');
    }

    /////Update each Account for the month based on order's categories
    Map orderCategories = {};

    //Logic to retrieve and add up categories totals
    for (var i = 0; i < cartList.length; i++) {
      //Check if the map contains the key
      if (orderCategories.containsKey('Ventas de ${cartList[i]["Category"]}')) {
        //Add to existing category amount
        orderCategories.update(
            'Ventas de ${cartList[i]["Category"]}',
            (value) =>
                value + (cartList[i]["Price"] * cartList[i]["Quantity"]));
      } else {
        //Add new category with amount
        orderCategories['Ventas de ${cartList[i]["Category"]}'] =
            cartList[i]["Price"] * cartList[i]["Quantity"];
      }
    }
    ////Logic to add Sales by Categories to Firebase based on current Values from snap
    orderCategories.forEach((k, v) {
      docRef.update({k: FieldValue.increment(v)});
    });

    /////////////////////////// MONTH STATS ///////////////////////////

    //Increment stats
    var monthStatsRef = firestore
        .collection('ERP')
        .doc(activeBusiness)
        .collection(year)
        .doc(month)
        .collection('Stats')
        .doc('Monthly Stats');

    //Update STATS for MONTH
    try {
      final monthStatsdoc = await monthStatsRef.get();

      if (monthStatsdoc.exists) {
        //MONTHLY Stats
        if (!splitPayment) {
          monthStatsRef.update({
            'Total Sales Count': FieldValue.increment(1),
            'Total Sales': FieldValue.increment(total),
            'Total Items Sold': FieldValue.increment(cartList.length),
            'Sales by Order Type.$orderType': FieldValue.increment(total),
            'Sales by Payment Type.$paymentType': FieldValue.increment(total),
            'Cost of Used Supplies':
                FieldValue.increment(totalCostOfIngredients)
          });
        } else {
          monthStatsRef.update({
            'Total Sales Count': FieldValue.increment(1),
            'Total Sales': FieldValue.increment(total),
            'Total Items Sold': FieldValue.increment(cartList.length),
            'Sales by Order Type.$orderType': FieldValue.increment(total),
            'Cost of Used Supplies':
                FieldValue.increment(totalCostOfIngredients)
          });
          for (var x in splitPaymentDetails) {
            monthStatsRef.update({
              'Sales by Payment Type.${x['Type']}':
                  FieldValue.increment(x['Amount']),
            });
          }
        }
        //MONTHLY Stats By PRODUCTS and CATEGORIES'
        for (var i = 0; i < cartList.length; i++) {
          monthStatsRef.update({
            'Sales Amount by Product.${cartList[i]["Name"]}':
                FieldValue.increment(
                    cartList[i]["Price"] * cartList[i]["Quantity"]),
            'Sales Count by Product.${cartList[i]["Name"]}':
                FieldValue.increment(cartList[i]["Quantity"]),
            'Sales Amount by Category.${cartList[i]["Category"]}':
                FieldValue.increment(
                    cartList[i]["Price"] * cartList[i]["Quantity"]),
            'Sales Count by Category.${cartList[i]["Category"]}':
                FieldValue.increment(cartList[i]["Quantity"]),
          });
        }
      } else {
        Map<String, dynamic> orderStats = {
          'Total Sales Count': 0,
          'Total Sales': 0,
          'Total Items Sold': 0,
          'Sales by Order Type': {},
          'Sales by Payment Type': {},
          'Sales Amount by Product': {},
          'Sales Count by Product': {},
          'Sales Amount by Category': {},
          'Sales Count by Category': {}
        };

        orderStats['Total Sales Count'] = 1;
        orderStats['Total Sales'] = total;
        orderStats['Total Items Sold'] = cartList.length;
        orderStats['Sales by Order Type'] = {orderType: total};
        orderStats['Cost of Used Supplies'] = totalCostOfIngredients;

        //Add list of payment types to the Map
        if (splitPayment) {
          for (var x in splitPaymentDetails) {
            orderStats['Sales by Payment Type']['${x['Type']}'] = x['Amount'];
          }
        } else {
          orderStats['Sales by Payment Type']['$paymentType'] = total;
        }

        //Add product and categories stats
        for (var i = 0; i < cartList.length; i++) {
          //Product Amounts
          orderStats['Sales Amount by Product']['${cartList[i]["Name"]}'] =
              (orderStats['Sales Amount by Product']
                          ['${cartList[i]["Name"]}'] ??
                      0) +
                  (cartList[i]["Price"] * cartList[i]["Quantity"]);
          //Products Count
          orderStats['Sales Count by Product']['${cartList[i]["Name"]}'] =
              (orderStats['Sales Count by Product']['${cartList[i]["Name"]}'] ??
                      0) +
                  cartList[i]["Quantity"];
          //Categories Amount
          orderStats['Sales Amount by Category']['${cartList[i]["Category"]}'] =
              (orderStats['Sales Amount by Category']
                          ['${cartList[i]["Category"]}'] ??
                      0) +
                  (cartList[i]["Price"] * cartList[i]["Quantity"]);
          //Categories Count
          orderStats['Sales Count by Category']['${cartList[i]["Category"]}'] =
              (orderStats['Sales Count by Category']
                          ['${cartList[i]["Category"]}'] ??
                      0) +
                  cartList[i]["Quantity"];
        }

        await monthStatsRef.set(orderStats);
      }
    } catch (error) {
      print('Error updating Monthly Stats: $error');
    }

    /////////////////////////// DAILY STATS ///////////////////////////

    ///Increment stats
    if (cashRegister != null) {
      var dayStatsRef = firestore
          .collection('ERP')
          .doc(activeBusiness)
          .collection(year)
          .doc(month)
          .collection('Daily')
          .doc(cashRegister);

      //Update STATS for DAY
      try {
        final dayStatsdoc = await dayStatsRef.get();

        if (dayStatsdoc.exists) {
          //DAILY Stats
          if (!splitPayment) {
            dayStatsRef.update({
              'Total Sales Count': FieldValue.increment(1),
              'Ventas': FieldValue.increment(total),
              'Transacciones del Día': FieldValue.increment(total),
              'Total Items Sold': FieldValue.increment(cartList.length),
              'Sales by Order Type.$orderType': FieldValue.increment(total),
              'Ventas por Medio.$paymentType': FieldValue.increment(total),
              'Cost of Used Supplies':
                  FieldValue.increment(totalCostOfIngredients)
            });
          } else {
            dayStatsRef.update({
              'Total Sales Count': FieldValue.increment(1),
              'Ventas': FieldValue.increment(total),
              'Transacciones del Día': FieldValue.increment(total),
              'Total Items Sold': FieldValue.increment(cartList.length),
              'Sales by Order Type.$orderType': FieldValue.increment(total),
              'Cost of Used Supplies':
                  FieldValue.increment(totalCostOfIngredients)
            });
            for (var x in splitPaymentDetails) {
              dayStatsRef.update({
                'Ventas por Medio.${x['Type']}':
                    FieldValue.increment(x['Amount']),
              });
            }
          }

          //DAILY Stats By PRODUCTS and CATEGORIES'
          for (var i = 0; i < cartList.length; i++) {
            dayStatsRef.update({
              'Sales Amount by Product.${cartList[i]["Name"]}':
                  FieldValue.increment(
                      cartList[i]["Price"] * cartList[i]["Quantity"]),
              'Sales Count by Product.${cartList[i]["Name"]}':
                  FieldValue.increment(cartList[i]["Quantity"]),
              'Sales Amount by Category.${cartList[i]["Category"]}':
                  FieldValue.increment(
                      cartList[i]["Price"] * cartList[i]["Quantity"]),
              'Sales Count by Category.${cartList[i]["Category"]}':
                  FieldValue.increment(cartList[i]["Quantity"]),
            });
          }
        }
      } catch (error) {
        print('Error updating Daily Stats: $error');
      }
    }

    //If is table
    if (isTable) {
      DatabaseService().updateTable(
        activeBusiness,
        tableCode,
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
      DatabaseService().deleteOrder(activeBusiness, 'Mesa ' + tableCode);
    }

    //If is saved order
    if (isSavedOrder) {
      DatabaseService().deleteOrder(activeBusiness, savedOrderID);
    }
  }

  // orders List from snapshot
  List<SavedOrders> _savedOrderListFromSnapshot(QuerySnapshot snapshot) {
    try {
      return snapshot.docs.map((doc) {
        return SavedOrders(
            orderName: doc.data().toString().contains('Order Name')
                ? doc['Order Name']
                : '',
            subTotal: doc.data().toString().contains('Subtotal')
                ? doc['Subtotal']
                : 0,
            total: doc.data().toString().contains('Total') ? doc['Total'] : 0,
            tax: doc.data().toString().contains('IVA') ? doc['IVA'] : 0,
            discount: doc.data().toString().contains('Discount')
                ? doc['Discount']
                : 0,
            orderColor:
                doc.data().toString().contains('Color') ? doc['Color'] : 0,
            paymentType: doc.data().toString().contains('Payment Type')
                ? doc['Payment Type']
                : '',
            orderDetail:
                doc.data().toString().contains('Items') ? doc['Items'] : [],
            id: doc.data().toString().contains('Document ID')
                ? doc['Document ID']
                : '',
            isTable:
                doc.data().toString().contains('Table') ? doc['Table'] : false,
            orderType: doc.data().toString().contains('Order Type')
                ? doc['Order Type']
                : '',
            savedDate: doc.data().toString().contains('Saved Date')
                ? doc['Saved Date'].toDate()
                : DateTime(1999, 1, 1),
            client:
                doc.data().toString().contains('Client') ? doc['Client'] : {});
      }).toList();
    } catch (e) {
      print(e);
      return null;
    }
  }

  // orders Stream
  Stream<List<SavedOrders>> orderList(businessID) async* {
    yield* FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection('Saved')
        .orderBy('Saved Date')
        .snapshots()
        .map(_savedOrderListFromSnapshot);
  }

  Stream<List<SavedOrders>> savedCounterOrders(businessID) async* {
    yield* FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection('Saved')
        .where('Order Type', isNotEqualTo: 'Mesa')
        .snapshots()
        .map(_savedOrderListFromSnapshot);
  }

  // // orders List from snapshot
  List<PendingOrders> _pendingOrderListFromSnapshot(QuerySnapshot snapshot) {
    try {
      return snapshot.docs.map((doc) {
        return PendingOrders(
            orderName: doc.data().toString().contains('Order Name')
                ? doc['Order Name']
                : '',
            total: doc.data().toString().contains('Total') ? doc['Total'] : 0,
            phone: doc.data().toString().contains('Phone') ? doc['Phone'] : 0,
            address:
                doc.data().toString().contains('Address') ? doc['Address'] : '',
            paymentType: doc.data().toString().contains('Payment Type')
                ? doc['Payment Type']
                : '',
            orderDetail:
                doc.data().toString().contains('Items') ? doc['Items'] : [],
            orderDate: doc.data().toString().contains('Saved Date')
                ? doc['Saved Date'].toDate()
                : DateTime(1999, 1, 1),
            orderType: doc.data().toString().contains('Order Type')
                ? doc['Order Type']
                : 'Delivery',
            docID: doc.id);
      }).toList();
    } catch (e) {
      print(e);
      return null;
    }
  }

  // // orders Stream
  Stream<List<PendingOrders>> pendingOrderList(businessID) async* {
    yield* FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection('Pending')
        .snapshots()
        .map(_pendingOrderListFromSnapshot);
  }

  // Delete pending order

  Future deletePendingOrder(businessID, orderDoc) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection('Pending')
        .doc(orderDoc)
        .delete();
  }

  //Create Order
  Future createOrder(
      String businessID,
      String documentID,
      String year,
      String month,
      DateTime transactionDate,
      subTotal,
      discount,
      tax,
      total,
      orderDetail,
      orderName,
      paymentType,
      String clientName,
      Map clientDetails,
      transactionID,
      String currentCashRegister,
      bool reversed,
      List splitPaymentDetails,
      orderType,
      double totalCostOfIngredients) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection(year)
        .doc(month)
        .collection('Sales')
        .doc(documentID)
        .set({
      'Account': 'Ventas',
      'Date': transactionDate,
      'Discount': discount,
      'IVA': tax,
      'Items': orderDetail,
      'Order Name': orderName,
      'Payment Type': paymentType,
      'Subtotal': subTotal,
      'Total': total,
      'Client': clientName,
      'Client Details': clientDetails,
      'Transaction ID': transactionID,
      'Cash Register': currentCashRegister,
      'Reversed': reversed,
      'Split Payment Details': splitPaymentDetails,
      'Order Type': orderType,
      'Cost of Supplies': totalCostOfIngredients
    });
  }

  //Wastage Order
  Future createWastage(
    String year,
    String month,
    String transactionID,
    totalCost,
    totalSale,
    orderDetail,
  ) async {
    final User user = FirebaseAuth.instance.currentUser;
    final String uid = user.uid.toString();

    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(uid)
        .collection(year)
        .doc(month)
        .collection('Wastage and Employee Consumption')
        .doc('Wastage')
        .collection('History')
        .doc(transactionID)
        .set({
      'Date': DateTime.now(),
      'Items': orderDetail,
      'Total Cost': totalCost,
      'Total Sale': totalSale,
    });
  }

  //Save Wastage Details
  Future saveWastageDetails(String ticketConcept, Map wastageByCategory) async {
    var year = DateTime.now().year.toString();
    var month = DateTime.now().month.toString();

    final User user = FirebaseAuth.instance.currentUser;
    final String uid = user.uid.toString();

    if (ticketConcept == 'Desperdicios') {
      try {
        return await FirebaseFirestore.instance
            .collection('ERP')
            .doc(uid)
            .collection(year)
            .doc(month)
            .collection('Wastage and Employee Consumption')
            .doc('Wastage')
            .update(wastageByCategory);
      } catch (e) {
        return await FirebaseFirestore.instance
            .collection('ERP')
            .doc(uid)
            .collection(year)
            .doc(month)
            .collection('Wastage and Employee Consumption')
            .doc('Wastage')
            .set(wastageByCategory);
      }
    } else if (ticketConcept == 'Consumo de Empleados') {
      try {
        return await FirebaseFirestore.instance
            .collection('ERP')
            .doc(uid)
            .collection(year)
            .doc(month)
            .collection('Wastage and Employee Consumption')
            .doc('Employee Consumption')
            .update(wastageByCategory);
      } catch (e) {
        return await FirebaseFirestore.instance
            .collection('ERP')
            .doc(uid)
            .collection(year)
            .doc(month)
            .collection('Wastage and Employee Consumption')
            .doc('Employee Consumption')
            .set(wastageByCategory);
      }
    }
  }

  //Save Account/Category
  Future saveOrderType(String businessID, Map salesByCategory) async {
    var year = DateTime.now().year.toString();
    var month = DateTime.now().month.toString();

    try {
      return await FirebaseFirestore.instance
          .collection('ERP')
          .doc(businessID)
          .collection(year)
          .doc(month)
          .update(salesByCategory);
    } catch (e) {
      return await FirebaseFirestore.instance
          .collection('ERP')
          .doc(businessID)
          .collection(year)
          .doc(month)
          .set(salesByCategory);
    }
  }

  //Save Stats Details
  Future saveOrderStats(String businessID, Map orderStats) async {
    var year = DateTime.now().year.toString();
    var month = DateTime.now().month.toString();

    try {
      return await FirebaseFirestore.instance
          .collection('ERP')
          .doc(businessID)
          .collection(year)
          .doc(month)
          .collection('Stats')
          .doc('Monthly Stats')
          .update(orderStats);
    } catch (e) {
      return await FirebaseFirestore.instance
          .collection('ERP')
          .doc(businessID)
          .collection(year)
          .doc(month)
          .collection('Stats')
          .doc('Monthly Stats')
          .set(orderStats);
    }
  }

  //Save Order
  Future saveOrder(
      businessID,
      String transactionID,
      subTotal,
      discount,
      tax,
      total,
      orderDetail,
      orderName,
      paymentType,
      orderColor,
      isTable,
      orderType,
      client) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection('Saved')
        .doc(transactionID)
        .set({
      'Discount': discount,
      'IVA': tax,
      'Items': orderDetail,
      'Order Name': orderName,
      'Payment Type': paymentType,
      'Subtotal': subTotal,
      'Total': total,
      'Color': orderColor,
      'Document ID': transactionID,
      'Table': isTable,
      'Order Type': orderType,
      'Saved Date': DateTime.now(),
      'Client': client
    });
  }

  //Delete Saved Order
  Future deleteOrder(businessID, orderDoc) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection('Saved')
        .doc(orderDoc)
        .delete();
  }

  ///////////////////////// RECEIVABLES //////////////////////////

  //Create Receivable (Por cobrar)
  Future createReceivable(
      businessID,
      String documentID,
      subTotal,
      discount,
      tax,
      total,
      orderDetail,
      orderName,
      orderType,
      clientName,
      clientDetails) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection('Receivables')
        .doc(documentID)
        .set({
      'Discount': discount,
      'IVA': tax,
      'Items': orderDetail,
      'Order Name': orderName,
      'Subtotal': subTotal,
      'Total': total,
      'Order Type': orderType,
      'Saved Date': DateTime.now(),
      'Client Name': clientName,
      'Client Details': clientDetails,
      'Pending': true,
    });
  }

  // //Update Amount
  Future updateReceivable(businessID, receivableID, remainingBalance) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection('Receivables')
        .doc(receivableID)
        .update({
      'Remaining Blanace': remainingBalance,
    });
  }

  // //Mark as paid
  Future paidReceivable(businessID, receivableID) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection('Receivables')
        .doc(receivableID)
        .update({'Pending': false});
  }

  // Receivables List from snapshot
  List<Receivables> _receivablesListFromSnapshot(QuerySnapshot snapshot) {
    try {
      return snapshot.docs.map((doc) {
        return Receivables(
          orderName: doc.data().toString().contains('Order Name')
              ? doc['Order Name']
              : '',
          subTotal:
              doc.data().toString().contains('Subtotal') ? doc['Subtotal'] : 0,
          total: doc.data().toString().contains('Total') ? doc['Total'] : 0,
          tax: doc.data().toString().contains('IVA') ? doc['IVA'] : 0,
          discount:
              doc.data().toString().contains('Discount') ? doc['Discount'] : 0,
          orderDetail: doc.data().toString().contains('Items')
              ? doc['Items'].map<SoldItems>((item) {
                  return SoldItems(
                    product:
                        item.toString().contains('Name') ? item['Name'] : '',
                    category: item.toString().contains('Category')
                        ? item['Category']
                        : '',
                    price:
                        item.toString().contains('Price') ? item['Price'] : 0,
                    qty: item.toString().contains('Quantity')
                        ? item['Quantity']
                        : 0,
                    total: item.toString().contains('Total Price')
                        ? item['Total Price']
                        : 0,
                    supplies: item.toString().contains('Supplies')
                        ? item['Supplies']
                        : 0,
                  );
                }).toList()
              : [],
          id: doc.id,
          orderType: doc.data().toString().contains('Order Type')
              ? doc['Order Type']
              : '',
          savedDate: doc.data().toString().contains('Saved Date')
              ? doc['Saved Date'].toDate()
              : DateTime(1999, 1, 1),
          clientName: doc.data().toString().contains('Client Name')
              ? doc['Client Name']
              : '',
          clientDetails: doc.data().toString().contains('Client Details')
              ? doc['Client Details']
              : {},
          pending:
              doc.data().toString().contains('Pending') ? doc['Pending'] : true,
        );
      }).toList();
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Receivables Stream
  Stream<List<Receivables>> receivablesList(businessID) async* {
    yield* FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection('Receivables')
        .where('Saved Date',
            isGreaterThanOrEqualTo:
                DateTime(DateTime.now().year, DateTime.now().month, 1))
        .where('Pending', isEqualTo: true)
        .orderBy('Saved Date')
        .snapshots()
        .map(_receivablesListFromSnapshot);
  }

  Stream<List<Receivables>> shortReceivablesList(businessID) async* {
    yield* FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection('Receivables')
        .where('Pending', isEqualTo: true)
        .orderBy('Saved Date')
        .snapshots()
        .map(_receivablesListFromSnapshot);
  }

  // //Filtered Receivables
  // Stream<List<Receivables>> filteredReceivablesList(String businessID,
  //     DateTime dateFrom, DateTime dateTo, orderName, String pending) async* {
  //   if (pending == 'Pending') {
  //     if (orderName == null || orderName == '') {
  //       if (dateTo == null) {
  //         yield* FirebaseFirestore.instance
  //             .collection('ERP')
  //             .doc(businessID)
  //             .collection('Receivables')
  //             .where('Saved Date', isGreaterThanOrEqualTo: dateFrom)
  //             .where('Saved Date', isLessThan: DateTime.now())
  //             .where('Pending', isEqualTo: true)
  //             .snapshots()
  //             .map(_receivablesListFromSnapshot);
  //       } else {
  //         yield* FirebaseFirestore.instance
  //             .collection('ERP')
  //             .doc(businessID)
  //             .collection('Receivables')
  //             .where('Saved Date', isGreaterThanOrEqualTo: dateFrom)
  //             .where('Saved Date', isLessThanOrEqualTo: dateTo)
  //             .where('Pending', isEqualTo: true)
  //             .snapshots()
  //             .map(_receivablesListFromSnapshot);
  //       }
  //     } else {
  //       if (dateTo == null) {
  //         yield* FirebaseFirestore.instance
  //             .collection('ERP')
  //             .doc(businessID)
  //             .collection('Receivables')
  //             .where('Saved Date', isGreaterThanOrEqualTo: dateFrom)
  //             .where('Saved Date', isLessThan: DateTime.now())
  //             .where('Order Name', isEqualTo: orderName)
  //             .where('Pending', isEqualTo: true)
  //             .snapshots()
  //             .map(_receivablesListFromSnapshot);
  //       } else {
  //         yield* FirebaseFirestore.instance
  //             .collection('ERP')
  //             .doc(businessID)
  //             .collection('Receivables')
  //             .where('Saved Date', isGreaterThanOrEqualTo: dateFrom)
  //             .where('Saved Date', isLessThanOrEqualTo: dateTo)
  //             .where('Order Name', isEqualTo: orderName)
  //             .where('Pending', isEqualTo: true)
  //             .snapshots()
  //             .map(_receivablesListFromSnapshot);
  //       }
  //     }
  //   } else if (pending == 'Cobrado') {
  //     if (orderName == null || orderName == '') {
  //       if (dateTo == null) {
  //         yield* FirebaseFirestore.instance
  //             .collection('ERP')
  //             .doc(businessID)
  //             .collection('Receivables')
  //             .where('Saved Date', isGreaterThanOrEqualTo: dateFrom)
  //             .where('Saved Date', isLessThan: DateTime.now())
  //             .where('Pending', isEqualTo: false)
  //             .snapshots()
  //             .map(_receivablesListFromSnapshot);
  //       } else {
  //         yield* FirebaseFirestore.instance
  //             .collection('ERP')
  //             .doc(businessID)
  //             .collection('Receivables')
  //             .where('Saved Date', isGreaterThanOrEqualTo: dateFrom)
  //             .where('Saved Date', isLessThanOrEqualTo: dateTo)
  //             .where('Pending', isEqualTo: false)
  //             .snapshots()
  //             .map(_receivablesListFromSnapshot);
  //       }
  //     } else {
  //       if (dateTo == null) {
  //         yield* FirebaseFirestore.instance
  //             .collection('ERP')
  //             .doc(businessID)
  //             .collection('Receivables')
  //             .where('Saved Date', isGreaterThanOrEqualTo: dateFrom)
  //             .where('Saved Date', isLessThan: DateTime.now())
  //             .where('Order Name', isEqualTo: orderName)
  //             .where('Pending', isEqualTo: false)
  //             .snapshots()
  //             .map(_receivablesListFromSnapshot);
  //       } else {
  //         yield* FirebaseFirestore.instance
  //             .collection('ERP')
  //             .doc(businessID)
  //             .collection('Receivables')
  //             .where('Saved Date', isGreaterThanOrEqualTo: dateFrom)
  //             .where('Saved Date', isLessThanOrEqualTo: dateTo)
  //             .where('Order Name', isEqualTo: orderName)
  //             .where('Pending', isEqualTo: false)
  //             .snapshots()
  //             .map(_receivablesListFromSnapshot);
  //       }
  //     }
  //   } else {
  //     if (orderName == null || orderName == '') {
  //       if (dateTo == null) {
  //         yield* FirebaseFirestore.instance
  //             .collection('ERP')
  //             .doc(businessID)
  //             .collection('Receivables')
  //             .where('Saved Date', isGreaterThanOrEqualTo: dateFrom)
  //             .where('Saved Date', isLessThan: DateTime.now())
  //             .snapshots()
  //             .map(_receivablesListFromSnapshot);
  //       } else {
  //         yield* FirebaseFirestore.instance
  //             .collection('ERP')
  //             .doc(businessID)
  //             .collection('Receivables')
  //             .where('Saved Date', isGreaterThanOrEqualTo: dateFrom)
  //             .where('Saved Date', isLessThanOrEqualTo: dateTo)
  //             .snapshots()
  //             .map(_receivablesListFromSnapshot);
  //       }
  //     } else {
  //       if (dateTo == null) {
  //         yield* FirebaseFirestore.instance
  //             .collection('ERP')
  //             .doc(businessID)
  //             .collection('Receivables')
  //             .where('Saved Date', isGreaterThanOrEqualTo: dateFrom)
  //             .where('Saved Date', isLessThan: DateTime.now())
  //             .where('Order Name', isEqualTo: orderName)
  //             .snapshots()
  //             .map(_receivablesListFromSnapshot);
  //       } else {
  //         yield* FirebaseFirestore.instance
  //             .collection('ERP')
  //             .doc(businessID)
  //             .collection('Receivables')
  //             .where('Saved Date', isGreaterThanOrEqualTo: dateFrom)
  //             .where('Saved Date', isLessThanOrEqualTo: dateTo)
  //             .where('Order Name', isEqualTo: orderName)
  //             .snapshots()
  //             .map(_receivablesListFromSnapshot);
  //       }
  //     }
  //   }
  // }

  ///////////////////////// ACCOUNTS/CATEGORIES //////////////////////////

  //Get High Level Mapping
  HighLevelMapping _highLevelMappingFromSnapshot(DocumentSnapshot snapshot) {
    try {
      return HighLevelMapping(
          expenseInputMapping: snapshot['Expense Input Mapping'],
          pnlAccountGroups: snapshot['PnL Account Group Mapping'],
          pnlMapping: snapshot['PnL Mapping'],
          expenseGroups: snapshot['Expense Group Mapping']);
    } catch (e) {
      print(e);
      return null;
    }
  }

  //High Level Mapping Stream
  Stream<HighLevelMapping> highLevelMapping(businessID) async* {
    yield* FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection('Master Data')
        .doc('High Level Mapping')
        .snapshots()
        .map(_highLevelMappingFromSnapshot);
  }

  //Edit Categories (Cost and sales)
  Future editCategoriesonPnlMapping(businessID, newPnlMapping) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection('Master Data')
        .doc('High Level Mapping')
        .update({'PnL Mapping': newPnlMapping});
  }

  //Get Categories (Costo de Ventas)
  CategoryList _categoriesFromSnapshot(DocumentSnapshot snapshot) {
    try {
      return CategoryList(categoryList: snapshot['Category List']);
    } catch (e) {
      print(e);
      return null;
    }
  }

  //Categories Stream (Costo de Ventas)
  Stream<CategoryList> categoriesList(businessID) async* {
    yield* FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection('Master Data')
        .doc('Categories')
        .snapshots()
        .map(_categoriesFromSnapshot);
  }

  //Get Account Groups with Categories
  AccountsList _accountsFromSnapshot(DocumentSnapshot snapshot) {
    try {
      return AccountsList(accountsMapping: snapshot['Account Mapping']);
    } catch (e) {
      print(e);
      return null;
    }
  }

  //Accounts Stream
  Stream<AccountsList> accountsList(businessID) async* {
    yield* FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection('Master Data')
        .doc('Account Mapping')
        .snapshots()
        .map(_accountsFromSnapshot);
  }

  ////////////////////////// TABLES ///////////////////////

  // Product List from snapshot
  List<Tables> _tableListFromSnapshot(QuerySnapshot snapshot) {
    try {
      return snapshot.docs.map((doc) {
        return Tables(
            table: doc.data().toString().contains('Code') ? doc['Code'] : '',
            assignedOrder: doc.data().toString().contains('Assigned Order')
                ? doc['Assigned Order']
                : '',
            isOpen:
                doc.data().toString().contains('Open') ? doc['Open'] : false,
            openSince: doc.data().toString().contains("Open Since")
                ? doc['Open Since'].toDate()
                : DateTime.now(),
            numberOfPeople:
                doc.data().toString().contains('People') ? doc['People'] : 0,
            //Order
            subTotal: doc.data().toString().contains('Subtotal')
                ? doc['Subtotal']
                : 0,
            total: doc.data().toString().contains('Total') ? doc['Total'] : 0,
            tax: doc.data().toString().contains('IVA') ? doc['IVA'] : 0,
            discount: doc.data().toString().contains('Discount')
                ? doc['Discount']
                : 0,
            orderColor: doc.data().toString().contains('Color')
                ? doc['Color']
                : Colors.grey.value,
            paymentType: doc.data().toString().contains('Payment Type')
                ? doc['Payment Type']
                : '',
            orderDetail:
                doc.data().toString().contains('Items') ? doc['Items'] : [],
            client: doc.data().toString().contains('Assigned Client')
                ? doc['Assigned Client']
                : {},
            //Draggable section
            isOccupied: doc.data().toString().contains('Occupied')
                ? doc['Occupied']
                : false,
            shape: doc.data().toString().contains('Shape')
                ? doc['Shape']
                : 'Square',
            x: doc.data().toString().contains('X Axis') ? doc['X Axis'] : 0,
            y: doc.data().toString().contains('Y Axis') ? doc['Y Axis'] : 0,
            tableSize: doc.data().toString().contains('Table Size')
                ? doc['Table Size']
                : 75,
            docID: doc.id);
      }).toList();
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Product Stream
  Stream<List<Tables>> tableList(String businessID) async* {
    yield* FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection('Tables')
        .snapshots()
        .map(_tableListFromSnapshot);
  }

  //Create Table
  Future createTable(businessID, Map<String, dynamic> table) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection('Tables')
        .doc('Table ' + table['Code'])
        .set(table);
  }

  Future updateExistingTable(String businessID, String tableID,
      String tableCode, double x, double y, double tableSize) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection('Tables')
        .doc(tableID)
        .update({
      'Code': tableCode,
      'X Axis': x,
      'Y Axis': y,
      'Table Size': tableSize
    });
  }

  Future updateTable(
      String businessID,
      tableCode,
      subTotal,
      discount,
      tax,
      total,
      orderDetail,
      paymentType,
      orderColor,
      isOpen,
      Map assignedClient) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection('Tables')
        .doc('Table ' + tableCode)
        .update({
      'Discount': discount,
      'IVA': tax,
      'Items': orderDetail,
      'Payment Type': paymentType,
      'Subtotal': subTotal,
      'Total': total,
      'Color': orderColor,
      'Open': isOpen,
      'Assigned Client': assignedClient
    });
  }

  Future deleteTable(String businessID, String tableDocID) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection('Tables')
        .doc(tableDocID)
        .delete();
  }

  ////////////////////////// EXPENSES ///////////////////////

  //Create Expense
  Future saveExpense(
      activeBusiness,
      costType,
      vendor,
      total,
      paymentType,
      items,
      DateTime date,
      year,
      month,
      cashRegister,
      reversed,
      usedCashfromRegister,
      amountFromRegister,
      orderNo,
      vendorSearchName,
      referenceNo) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(activeBusiness)
        .collection(year)
        .doc(month)
        .collection('Expenses')
        .doc(orderNo)
        .set({
      'Fecha': date,
      'Fecha de Creación': DateTime.now(),
      'Cost Type': costType,
      'Vendor': vendor,
      'Items': items,
      'Total': total,
      'Payment Type': paymentType,
      'Cash Register': cashRegister,
      'Reversed': reversed,
      'Cash from Register': usedCashfromRegister,
      'Amount from Register': amountFromRegister,
      'Expense ID': orderNo,
      'Vendor Search Name': vendorSearchName,
      'Reference': referenceNo
    });
  }

  //Create Payable
  Future createPayable(activeBusiness, costType, vendor, total, paymentType,
      items, DateTime date, orderNo, vendorSearchName, referenceNo) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(activeBusiness)
        .collection('Payables')
        .doc(orderNo)
        .set({
      'Fecha': date,
      'Fecha de Creación': DateTime.now(),
      'Cost Type': costType,
      'Vendor': vendor,
      'Items': items,
      'Total': total,
      'Payment Type': paymentType,
      'Expense ID': orderNo,
      'Vendor Search Name': vendorSearchName,
      'Reference': referenceNo
    });
  }

  //Save Account/Category
  Future saveExpenseType(activeBusiness, expenseCategories, year, month) async {
    try {
      return await FirebaseFirestore.instance
          .collection('ERP')
          .doc(activeBusiness)
          .collection(year)
          .doc(month)
          .update(expenseCategories);
    } catch (e) {
      return await FirebaseFirestore.instance
          .collection('ERP')
          .doc(activeBusiness)
          .collection(year)
          .doc(month)
          .set(expenseCategories);
    }
  }

  // Expense List from snapshot
  List<Expenses> _expensesFromSnapshot(QuerySnapshot snapshot) {
    try {
      return snapshot.docs.map((doc) {
        return Expenses(
          costType: doc.data().toString().contains('Cost Type')
              ? doc['Cost Type']
              : '',
          date: doc.data().toString().contains('Fecha')
              ? doc['Fecha'].toDate()
              : DateTime.now(),
          creationDate: doc.data().toString().contains('Fecha de Creación')
              ? doc['Fecha de Creación'].toDate()
              : DateTime.now(),
          paymentType: doc.data().toString().contains('Payment Type')
              ? doc['Payment Type']
              : '',
          items: doc.data().toString().contains('Items')
              ? doc['Items'].map<ExpenseItems>((item) {
                  return ExpenseItems(
                    product: item['Name'] ?? '',
                    category: item['Category'] ?? '',
                    price: item['Price'] ?? 0,
                    qty: item['Quantity'] ?? 0,
                    total: item['Total Price'] ?? 0,
                  );
                }).toList()
              : [],
          total: doc.data().toString().contains('Total') ? doc['Total'] : 0,
          vendor: doc.data().toString().contains('Vendor') ? doc['Vendor'] : '',
          cashRegister: doc.data().toString().contains('Cash Register')
              ? doc['Cash Register']
              : '',
          reversed: doc.data().toString().contains('Reversed')
              ? doc['Reversed']
              : false,
          usedCashfromRegister:
              doc.data().toString().contains('Cash from Register')
                  ? doc['Cash from Register']
                  : false,
          amountFromRegister:
              doc.data().toString().contains('Amount from Register')
                  ? doc['Amount from Register']
                  : 0,
          expenseID: doc.data().toString().contains('Expense ID')
              ? doc['Expense ID']
              : '',
          vendorSearchName: doc.data().toString().contains('Vendor Search Name')
              ? doc['Vendor Search Name']
              : [],
          referenceNo: doc.data().toString().contains('Reference')
              ? doc['Reference']
              : '',
        );
      }).toList();
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Expense Stream
  Stream<List<Expenses>> shortExpenseList(activeBusiness, month, year) async* {
    yield* FirebaseFirestore.instance
        .collection('ERP')
        .doc(activeBusiness)
        .collection(year)
        .doc(month)
        .collection('Expenses')
        .limit(10)
        .orderBy('Fecha', descending: true)
        .snapshots()
        .map(_expensesFromSnapshot);
  }

  Stream<List<Expenses>> expenseList(activeBusiness, month, year) async* {
    yield* FirebaseFirestore.instance
        .collection('ERP')
        .doc(activeBusiness)
        .collection(year)
        .doc(month)
        .collection('Expenses')
        .snapshots()
        .map(_expensesFromSnapshot);
  }

  Stream<List<Expenses>> filteredExpenseList(activeBusiness, month, year,
      dateFrom, dateTo, paymentMethod, vendor) async* {
    if (paymentMethod == null || paymentMethod == 'Todos') {
      if (vendor == null || vendor == '') {
        yield* FirebaseFirestore.instance
            .collection('ERP')
            .doc(activeBusiness)
            .collection(year)
            .doc(month)
            .collection('Expenses')
            .where('Fecha', isGreaterThanOrEqualTo: dateFrom)
            .where('Fecha', isLessThanOrEqualTo: dateTo)
            .snapshots()
            .map(_expensesFromSnapshot);
      } else {
        try {
          yield* FirebaseFirestore.instance
              .collection('ERP')
              .doc(activeBusiness)
              .collection(year)
              .doc(month)
              .collection('Expenses')
              .where('Fecha', isGreaterThanOrEqualTo: dateFrom)
              .where('Fecha', isLessThanOrEqualTo: dateTo)
              .where('Vendor Search Name', arrayContains: vendor)
              .snapshots()
              .map(_expensesFromSnapshot);
        } catch (e) {
          yield* FirebaseFirestore.instance
              .collection('ERP')
              .doc(activeBusiness)
              .collection(year)
              .doc(month)
              .collection('Expenses')
              .where('Fecha', isGreaterThanOrEqualTo: dateFrom)
              .where('Fecha', isLessThanOrEqualTo: dateTo)
              .snapshots()
              .map(_expensesFromSnapshot);
        }
      }
    } else {
      if (vendor == null || vendor == '') {
        yield* FirebaseFirestore.instance
            .collection('ERP')
            .doc(activeBusiness)
            .collection(year)
            .doc(month)
            .collection('Expenses')
            .where('Fecha', isGreaterThanOrEqualTo: dateFrom)
            .where('Fecha', isLessThanOrEqualTo: dateTo)
            .where('Payment Type', isEqualTo: paymentMethod)
            .snapshots()
            .map(_expensesFromSnapshot);
      } else {
        yield* FirebaseFirestore.instance
            .collection('ERP')
            .doc(activeBusiness)
            .collection(year)
            .doc(month)
            .collection('Expenses')
            .where('Fecha', isGreaterThanOrEqualTo: dateFrom)
            .where('Fecha', isLessThanOrEqualTo: dateTo)
            .where('Payment Type', isEqualTo: paymentMethod)
            .where('Vendor Search Name', arrayContains: vendor)
            .snapshots()
            .map(_expensesFromSnapshot);
      }
    }
  }

  // Payables List from snapshot
  List<Payables> _payablesFromSnapshot(QuerySnapshot snapshot) {
    try {
      return snapshot.docs.map((doc) {
        return Payables(
          costType: doc.data().toString().contains('Cost Type')
              ? doc['Cost Type']
              : '',
          date: doc.data().toString().contains('Fecha')
              ? doc['Fecha'].toDate()
              : DateTime.now(),
          creationDate: doc.data().toString().contains('Fecha de Creación')
              ? doc['Fecha de Creación'].toDate()
              : DateTime.now(),
          paymentType: doc.data().toString().contains('Payment Type')
              ? doc['Payment Type']
              : '',
          items: doc.data().toString().contains('Items')
              ? doc['Items'].map<ExpenseItems>((item) {
                  return ExpenseItems(
                    product: item['Name'] ?? '',
                    category: item['Category'] ?? '',
                    price: item['Price'] ?? 0,
                    qty: item['Quantity'] ?? 0,
                    total: item['Total Price'] ?? 0,
                  );
                }).toList()
              : [],
          total: doc.data().toString().contains('Total') ? doc['Total'] : 0,
          vendor: doc.data().toString().contains('Vendor') ? doc['Vendor'] : '',
          expenseID: doc.data().toString().contains('Expense ID')
              ? doc['Expense ID']
              : '',
          vendorSearchName: doc.data().toString().contains('Vendor Search Name')
              ? doc['Vendor Search Name']
              : [],
          referenceNo: doc.data().toString().contains('Reference')
              ? doc['Reference']
              : '',
        );
      }).toList();
    } catch (e) {
      print(e);
      return null;
    }
  }

  Stream<List<Payables>> payablesList(activeBusiness) async* {
    yield* FirebaseFirestore.instance
        .collection('ERP')
        .doc(activeBusiness)
        .collection('Payables')
        .where('Payment Type', isEqualTo: 'Por pagar')
        .orderBy('Fecha', descending: false)
        .snapshots()
        .map(_payablesFromSnapshot);
  }

  //Payable List by Vendor
  Stream<List<Payables>> payablesListbyVendor(activeBusiness, supplier) async* {
    yield* FirebaseFirestore.instance
        .collection('ERP')
        .doc(activeBusiness)
        .collection('Payables')
        .where('Payment Type', isEqualTo: 'Por pagar')
        .where('Vendor', isEqualTo: supplier)
        .orderBy('Fecha', descending: false)
        .snapshots()
        .map(_payablesFromSnapshot);
  }

  //Reverse expense
  Future markExpenseReversed(
    activeBusiness,
    expenseID,
    year,
    month,
  ) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(activeBusiness)
        .collection(year)
        .doc(month)
        .collection('Expenses')
        .doc(expenseID)
        .update({
      'Reversed': true,
    });
  }

  //Change from payable to paid
  Future markExpensePaid(
      activeBusiness, expenseID, year, month, paymentType) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(activeBusiness)
        .collection(year)
        .doc(month)
        .collection('Expenses')
        .doc(expenseID)
        .update({
      'Payment Type': paymentType,
    });
  }

  Future markPayablePaid(activeBusiness, expenseID, paymentType) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(activeBusiness)
        .collection('Payables')
        .doc(expenseID)
        .update({
      'Payment Type': paymentType,
    });
  }

  Future deletePayable(activeBusiness, expenseID) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(activeBusiness)
        .collection('Payables')
        .doc(expenseID)
        .delete();
  }

  //Associate invoice to vendor
  Future associateExpensetoVendor(activeBusiness, expenseID, reference, date,
      vendor, amount, pending) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(activeBusiness)
        .collection('Proveedores')
        .doc(vendor)
        .collection('Invoices')
        .doc(expenseID)
        .set({
      'Expense ID': expenseID,
      'Reference': reference,
      'Date': date,
      'Saved Date': DateTime.now(),
      'Total': amount,
      'Pending': pending
    });
  }

  /////////////////////////////////Cash Register ///////////////////////////

  //Open Cash Register
  Future openCashRegister(
      businessID, userName, initialAmount, DateTime date) async {
    var year = DateTime.now().year.toString();
    var month = DateTime.now().month.toString();

    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection(year)
        .doc(month)
        .collection('Daily')
        .doc('${date.toString()}')
        .set({
      'Fecha Apertura': date,
      'Fecha Cierre': date,
      'Usuario': userName,
      'Monto Inicial': initialAmount,
      'Abierto': true,
      'Transacciones del Día': 0,
      'Ventas': 0,
      'Ingresos': 0,
      'Egresos': 0,
      'Monto al Cierre': 0,
      'Ventas por Medio': {},
      'Detalle de Ingresos y Egresos': [
        {
          'Type': 'Apertura',
          'Motive': 'Apertura de Caja',
          'Amount': initialAmount,
          'Time': DateTime.now()
        }
      ],
      'Total Items Sold': 0,
      'Total Sales Count': 0,
      'Sales Count by Product': {},
      'Sales Count by Category': {},
      'Sales Amount by Product': {},
      'Sales by Order Type': {},
    });
  }

  Future recordOpenedRegister(
      businessID, bool openRegister, String registerID) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .update({
      'Caja Abierta': openRegister,
      'Caja Actual': registerID,
    });
  }

  //Update Cash Register (Inflows/Outflows)
  Future updateCashRegister(
      businessID,
      registerDate,
      String transactionType,
      double transactionAmount,
      double totalDailyTransactions,
      Map transactionDetails) async {
    DateTime date = DateTime.parse(registerDate);

    var year = date.year.toString();
    var month = date.month.toString();

    if (transactionDetails.isEmpty) {
      return await FirebaseFirestore.instance
          .collection('ERP')
          .doc(businessID)
          .collection(year)
          .doc(month)
          .collection('Daily')
          .doc('$registerDate')
          .update({
        'Transacciones del Día': totalDailyTransactions,
        transactionType: transactionAmount
      });
    } else {
      return await FirebaseFirestore.instance
          .collection('ERP')
          .doc(businessID)
          .collection(year)
          .doc(month)
          .collection('Daily')
          .doc('$registerDate')
          .update({
        'Transacciones del Día': totalDailyTransactions,
        transactionType: transactionAmount,
        'Detalle de Ingresos y Egresos':
            FieldValue.arrayUnion([transactionDetails])
      });
    }
  }

  //Update Cash Register (Inflows/Outflows)
  Future updateSalesinCashRegister(
    businessID,
    registerDate,
    double totalSales,
    List salesByMedium,
    double totalDailyTransactions,
  ) async {
    DateTime date = DateTime.parse(registerDate);

    var year = date.year.toString();
    var month = date.month.toString();

    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection(year)
        .doc(month)
        .collection('Daily')
        .doc('$registerDate')
        .update({
      'Transacciones del Día': totalDailyTransactions,
      'Ventas': totalSales,
      'Ventas por Medio': salesByMedium,
    });
  }

  //Close Cash Register
  Future closeCashRegister(businessID, closeAmount, registerDate) async {
    DateTime date = DateTime.parse(registerDate);

    var year = date.year.toString();
    var month = date.month.toString();

    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection(year)
        .doc(month)
        .collection('Daily')
        .doc('$registerDate')
        .update({
      'Fecha Cierre': DateTime.now(),
      'Abierto': false,
      'Monto al Cierre': closeAmount,
      'Detalle de Ingresos y Egresos': FieldValue.arrayUnion([
        {
          'Type': 'Cierre',
          'Motive': 'Cierre de Caja',
          'Amount': closeAmount,
          'Time': DateTime.now()
        }
      ])
    });
  }

  //Read Cash Register Status
  //Get First Level Cash Register Data
  CashRegister _cashRegisterFromSnapshot(DocumentSnapshot snapshot) {
    try {
      return CashRegister(
          registerName: snapshot.data().toString().contains('Caja Actual')
              ? snapshot['Caja Actual']
              : '',
          registerisOpen: snapshot.data().toString().contains('Caja Abierta')
              ? snapshot['Caja Abierta']
              : false,
          paymentTypes: snapshot.data().toString().contains('Payment Types')
              ? snapshot['Payment Types']
              : false);
    } catch (e) {
      print(e);
      return null;
    }
  }

  //Categories Stream (Costo de Ventas)
  Stream<CashRegister> cashRegisterStatus(businessID) async* {
    yield* FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .snapshots()
        .map(_cashRegisterFromSnapshot);
  }

  //Get Daily Transactions
  DailyTransactions _dailyTransactionsFromSnapshot(DocumentSnapshot snapshot) {
    try {
      return DailyTransactions(
        openDate: snapshot.data().toString().contains('Fecha Apertura')
            ? snapshot['Fecha Apertura'].toDate()
            : DateTime.now(),
        closeDate: snapshot.data().toString().contains('Fecha Cierre')
            ? snapshot['Fecha Cierre'].toDate()
            : DateTime.now(),
        user: snapshot.data().toString().contains('Usuario')
            ? snapshot['Usuario']
            : '',
        initialAmount: snapshot.data().toString().contains('Monto Inicial')
            ? snapshot['Monto Inicial']
            : 0,
        isOpen: snapshot.data().toString().contains('Abierto')
            ? snapshot['Abierto']
            : false,
        dailyTransactions:
            snapshot.data().toString().contains('Transacciones del Día')
                ? snapshot['Transacciones del Día']
                : 0,
        registerTransactionList:
            snapshot.data().toString().contains('Detalle de Ingresos y Egresos')
                ? snapshot['Detalle de Ingresos y Egresos']
                : [],
        sales: snapshot.data().toString().contains('Ventas')
            ? snapshot['Ventas']
            : 0,
        inflows: snapshot.data().toString().contains('Ingresos')
            ? snapshot['Ingresos']
            : 0,
        outflows: snapshot.data().toString().contains('Egresos')
            ? snapshot['Egresos']
            : 0,
        closeAmount: snapshot.data().toString().contains('Monto al Cierre')
            ? snapshot['Monto al Cierre']
            : 0,
        salesByMedium: snapshot.data().toString().contains('Ventas por Medio')
            ? (snapshot['Ventas por Medio'].runtimeType == List)
                ? {}
                : snapshot['Ventas por Medio']
            : {},
        totalItemsSold: snapshot.data().toString().contains('Total Items Sold')
            ? snapshot['Total Items Sold']
            : 0,
        totalSalesCount:
            snapshot.data().toString().contains('Total Sales Count')
                ? snapshot['Total Sales Count']
                : 0,
        salesCountbyProduct:
            snapshot.data().toString().contains('Sales Count by Product')
                ? snapshot['Sales Count by Product']
                : {},
        salesCountbyCategory:
            snapshot.data().toString().contains('Sales Count by Category')
                ? snapshot['Sales Count by Category']
                : {},
        salesAmountbyProduct:
            snapshot.data().toString().contains('Sales Amount by Product')
                ? snapshot['Sales Amount by Product']
                : {},
        salesAmountbyCategory:
            snapshot.data().toString().contains('Sales Amount by Category')
                ? snapshot['Sales Amount by Category']
                : {},
        salesbyOrderType:
            snapshot.data().toString().contains('Sales by Order Type')
                ? snapshot['Sales by Order Type']
                : {},
        totalSuppliesCost:
            snapshot.data().toString().contains('Cost of Used Supplies')
                ? snapshot['Cost of Used Supplies']
                : 0,
      );
    } catch (e) {
      print(e);
      return null;
    }
  }

  List<DailyTransactions> _specificDayTransactionsFromSnapshot(
      QuerySnapshot snapshot) {
    try {
      return snapshot.docs.map((doc) {
        return DailyTransactions(
          openDate: doc.data().toString().contains('Fecha Apertura')
              ? doc['Fecha Apertura'].toDate()
              : DateTime.now(),
          closeDate: doc.data().toString().contains('Fecha Cierre')
              ? doc['Fecha Cierre'].toDate()
              : DateTime.now(),
          user: doc.data().toString().contains('Usuario') ? doc['Usuario'] : '',
          initialAmount: doc.data().toString().contains('Monto Inicial')
              ? doc['Monto Inicial']
              : 0,
          isOpen: doc.data().toString().contains('Abierto')
              ? doc['Abierto']
              : false,
          dailyTransactions:
              doc.data().toString().contains('Transacciones del Día')
                  ? doc['Transacciones del Día']
                  : 0,
          registerTransactionList:
              doc.data().toString().contains('Detalle de Ingresos y Egresos')
                  ? doc['Detalle de Ingresos y Egresos']
                  : [],
          sales: doc.data().toString().contains('Ventas') ? doc['Ventas'] : 0,
          inflows:
              doc.data().toString().contains('Ingresos') ? doc['Ingresos'] : 0,
          outflows:
              doc.data().toString().contains('Egresos') ? doc['Egresos'] : 0,
          closeAmount: doc.data().toString().contains('Monto al Cierre')
              ? doc['Monto al Cierre']
              : 0,
          salesByMedium: doc.data().toString().contains('Ventas por Medio')
              ? (doc['Ventas por Medio'].runtimeType == List)
                  ? {}
                  : doc['Ventas por Medio']
              : {},
          totalItemsSold: doc.data().toString().contains('Total Items Sold')
              ? doc['Total Items Sold']
              : 0,
          totalSalesCount: doc.data().toString().contains('Total Sales Count')
              ? doc['Total Sales Count']
              : 0,
          salesCountbyProduct:
              doc.data().toString().contains('Sales Count by Product')
                  ? doc['Sales Count by Product']
                  : {},
          salesCountbyCategory:
              doc.data().toString().contains('Sales Count by Category')
                  ? doc['Sales Count by Category']
                  : {},
          salesAmountbyProduct:
              doc.data().toString().contains('Sales Amount by Product')
                  ? doc['Sales Amount by Product']
                  : {},
          salesAmountbyCategory:
              doc.data().toString().contains('Sales Amount by Category')
                  ? doc['Sales Amount by Category']
                  : {},
          salesbyOrderType:
              doc.data().toString().contains('Sales by Order Type')
                  ? doc['Sales by Order Type']
                  : {},
          totalSuppliesCost:
              doc.data().toString().contains('Cost of Used Supplies')
                  ? doc['Cost of Used Supplies']
                  : 0,
        );
      }).toList();
    } catch (e) {
      print(e);
      return null;
    }
  }

  //Daily  Stream (Costo de Ventas)
  Stream<DailyTransactions> dailyTransactions(
      businessID, String openRegister) async* {
    var year = DateTime.now().year.toString();
    var month = DateTime.now().month.toString();
    yield* FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection(year)
        .doc(month)
        .collection('Daily')
        .doc(openRegister)
        .snapshots()
        .map(_dailyTransactionsFromSnapshot);
  }

  Stream<List<DailyTransactions>> specificDailyTransactions(
      businessID, String year, String month, DateTime selectedDate) async* {
    yield* FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection(year)
        .doc(month)
        .collection('Daily')
        .where('Fecha Apertura',
            isGreaterThanOrEqualTo: DateTime(selectedDate.year,
                selectedDate.month, selectedDate.day, 00, 00))
        .where('Fecha Apertura',
            isLessThanOrEqualTo: DateTime(selectedDate.year, selectedDate.month,
                selectedDate.day, 23, 59, 59))
        .snapshots()
        .map(_specificDayTransactionsFromSnapshot);
  }

  // Daily Transactions List from snapshot
  List<DailyTransactions> _dailyTransactionsListFromSnapshot(
      QuerySnapshot snapshot) {
    try {
      return snapshot.docs.map((doc) {
        return DailyTransactions(
          openDate: doc.data().toString().contains('Fecha Apertura')
              ? doc['Fecha Apertura'].toDate()
              : DateTime(1900, 1, 1),
          closeDate: doc.data().toString().contains('Fecha Cierre')
              ? doc['Fecha Cierre'].toDate()
              : DateTime(1900, 1, 1),
          user: doc.data().toString().contains('Usuario') ? doc['Usuario'] : '',
          initialAmount: doc.data().toString().contains('Monto Inicial')
              ? doc['Monto Inicial']
              : 0,
          isOpen: doc.data().toString().contains('Abierto')
              ? doc['Abierto']
              : false,
          dailyTransactions:
              doc.data().toString().contains('Transacciones del día')
                  ? doc['Transacciones del día']
                  : 0,
          registerTransactionList:
              doc.data().toString().contains('Detalle de Ingresos y Egresos')
                  ? doc['Detalle de Ingresos y Egresos']
                  : [],
          sales: doc.data().toString().contains('Ventas') ? doc['Ventas'] : 0,
          inflows:
              doc.data().toString().contains('Ingresos') ? doc['Ingresos'] : 0,
          outflows:
              doc.data().toString().contains('Egresos') ? doc['Egresos'] : 0,
          closeAmount: doc.data().toString().contains('Monto al Cierre')
              ? doc['Monto al Cierre']
              : 0,
          salesByMedium: doc.data().toString().contains('Ventas por Medio')
              ? (doc['Ventas por Medio'].runtimeType == List)
                  ? {}
                  : doc['Ventas por Medio']
              : {},
          totalItemsSold: doc.data().toString().contains('Total Items Sold')
              ? doc['Total Items Sold']
              : 0,
          totalSalesCount: doc.data().toString().contains('Total Sales Count')
              ? doc['Total Sales Count']
              : 0,
          salesCountbyProduct:
              doc.data().toString().contains('Sales Count by Product')
                  ? doc['Sales Count by Product']
                  : {},
          salesCountbyCategory:
              doc.data().toString().contains('Sales Count by Category')
                  ? doc['Sales Count by Category']
                  : {},
          salesAmountbyProduct:
              doc.data().toString().contains('Sales Amount by Product')
                  ? doc['Sales Amount by Product']
                  : {},
          salesAmountbyCategory:
              doc.data().toString().contains('Sales Amount by Category')
                  ? doc['Sales Amount by Category']
                  : {},
          salesbyOrderType:
              doc.data().toString().contains('Sales by Order Type')
                  ? doc['Sales by Order Type']
                  : {},
          totalSuppliesCost:
              doc.data().toString().contains('Cost of Used Supplies')
                  ? doc['Cost of Used Supplies']
                  : 0,
        );
      }).toList();
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Daily Transactions List Stream
  Stream<List<DailyTransactions>> dailyTransactionsList(businessID) async* {
    var year = DateTime.now().year.toString();
    var month = DateTime.now().month.toString();

    yield* FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection(year)
        .doc(month)
        .collection('Daily')
        .orderBy('Fecha Apertura', descending: true)
        .limit(7)
        .snapshots()
        .map(_dailyTransactionsListFromSnapshot);
  }

  //Save Stats Details
  Future saveDailyOrderStats(
      businessID,
      registerDate,
      int totalItemsSold,
      int totalSalesCount,
      Map salesCountbyProduct,
      Map salesCountbyCategory,
      Map salesAmountbyProduct,
      Map salesByOrderType) async {
    var year = DateTime.now().year.toString();
    var month = DateTime.now().month.toString();

    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection(year)
        .doc(month)
        .collection('Daily')
        .doc('$registerDate')
        .update({
      'Total Items Sold': totalItemsSold,
      'Total Sales Count': totalSalesCount,
      'Sales Count by Product': salesCountbyProduct,
      'Sales Count by Category': salesCountbyCategory,
      'Sales Amount by Product': salesAmountbyProduct,
      'Sales by Order Type': salesByOrderType,
    });
  }

  ///////////////////////// Sales Data from Firestore //////////////////////////

  // Sales List from snapshot
  List<Sales> _salesFromSnapshot(QuerySnapshot snapshot) {
    try {
      return snapshot.docs.map((doc) {
        return Sales(
          account:
              doc.data().toString().contains('Account') ? doc['Account'] : '',
          date: doc.data().toString().contains('Date')
              ? doc['Date'].toDate()
              : DateTime.now(),
          discount:
              doc.data().toString().contains('Discount') ? doc['Discount'] : 0,
          tax: doc.data().toString().contains('IVA') ? doc['IVA'] : 0,
          soldItems: doc.data().toString().contains('Items')
              ? doc['Items'].map<SoldItems>((item) {
                  return SoldItems(
                    product: item['Name'] ?? '',
                    category: item['Category'] ?? '',
                    price: item['Price'] ?? 0,
                    qty: item['Quantity'] ?? 0,
                    total: item['Total Price'] ?? 0,
                    supplies: item.toString().contains('Supplies')
                        ? item['Supplies']
                        : [],
                  );
                }).toList()
              : [],
          orderName: doc.data().toString().contains('Order Name')
              ? doc['Order Name']
              : '',
          subTotal:
              doc.data().toString().contains('Subtotal') ? doc['Subtotal'] : 0,
          total: doc.data().toString().contains('Total') ? doc['Total'] : 0,
          paymentType: doc.data().toString().contains('Payment Type')
              ? doc['Payment Type']
              : '',
          clientName:
              doc.data().toString().contains('Client') ? doc['Client'] : '',
          clientDetails: doc.data().toString().contains('Client Details')
              ? doc['Client Details']
              : {},
          transactionID: doc.data().toString().contains('Transaction ID')
              ? doc['Transaction ID']
              : '',
          docID: doc.id,
          cashRegister: doc.data().toString().contains('Cash Register')
              ? doc['Cash Register']
              : '',
          reversed: doc.data().toString().contains('Reversed')
              ? doc['Reversed']
              : false,
          orderType: doc.data().toString().contains('Order Type')
              ? doc['Order Type']
              : '',
          splitPaymentDetails:
              doc.data().toString().contains('Split Payment Details')
                  ? doc['Split Payment Details'].toList()
                  : [],
          totalSuppliesCost: doc.data().toString().contains('Cost of Supplies')
              ? doc['Cost of Supplies']
              : 0,
        );
      }).toList();
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Sales Stream
  Stream<List<Sales>> salesList(String businessID) async* {
    var year = DateTime.now().year.toString();
    var month = DateTime.now().month.toString();

    yield* FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection(year)
        .doc(month)
        .collection('Sales')
        .where('Date',
            isGreaterThan: DateTime(DateTime.now().year, DateTime.now().month,
                    DateTime.now().day, 00, 00)
                .subtract(Duration(days: 1)))
        // .where('Payment Type', isEqualTo: 'Efectivo')
        // .where('Order Name', isEqualTo: '1')
        .snapshots()
        .map(_salesFromSnapshot);
  }

  //Limited sales list reversed

  //Filtered Sales
  Stream<List<Sales>> filteredSalesList(String businessID, DateTime dateFrom,
      DateTime dateTo, String paymentMethod) async* {
    if (paymentMethod == null ||
        paymentMethod == '' ||
        paymentMethod == 'Todos') {
      if (dateTo == null) {
        yield* FirebaseFirestore.instance
            .collection('ERP')
            .doc(businessID)
            .collection(dateFrom.year.toString())
            .doc(dateFrom.month.toString())
            .collection('Sales')
            .where('Date', isGreaterThanOrEqualTo: dateFrom)
            .where('Date', isLessThan: DateTime.now())
            // .where('Order Name', isEqualTo: '1')
            .snapshots()
            .map(_salesFromSnapshot);
      } else {
        yield* FirebaseFirestore.instance
            .collection('ERP')
            .doc(businessID)
            .collection(dateFrom.year.toString())
            .doc(dateFrom.month.toString())
            .collection('Sales')
            .where('Date', isGreaterThanOrEqualTo: dateFrom)
            .where('Date', isLessThanOrEqualTo: dateTo)
            // .where('Order Name', isEqualTo: '1')
            .snapshots()
            .map(_salesFromSnapshot);
      }
    } else {
      if (dateTo == null) {
        yield* FirebaseFirestore.instance
            .collection('ERP')
            .doc(businessID)
            .collection(dateFrom.year.toString())
            .doc(dateFrom.month.toString())
            .collection('Sales')
            .where('Date', isGreaterThanOrEqualTo: dateFrom)
            .where('Date', isLessThan: DateTime.now())
            .where('Payment Type', isEqualTo: paymentMethod)
            // .where('Order Name', isEqualTo: '1')
            .snapshots()
            .map(_salesFromSnapshot);
      } else {
        yield* FirebaseFirestore.instance
            .collection('ERP')
            .doc(businessID)
            .collection(dateFrom.year.toString())
            .doc(dateFrom.month.toString())
            .collection('Sales')
            .where('Date', isGreaterThanOrEqualTo: dateFrom)
            .where('Date', isLessThanOrEqualTo: dateTo)
            .where('Payment Type', isEqualTo: paymentMethod)
            // .where('Order Name', isEqualTo: '1')
            .snapshots()
            .map(_salesFromSnapshot);
      }
    }
  }

  Stream<List<Sales>> shortsalesList(String businessID) async* {
    var year = DateTime.now().year.toString();
    var month = DateTime.now().month.toString();

    yield* FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection(year)
        .doc(month)
        .collection('Sales')
        .orderBy("Date", descending: true)
        .limit(10)
        .snapshots()
        .map(_salesFromSnapshot);
  }

  Stream<List<Sales>> shortFilteredSalesList(
      String businessID, DateTime dateFrom, DateTime dateTo) async* {
    if (dateTo == null) {
      yield* FirebaseFirestore.instance
          .collection('ERP')
          .doc(businessID)
          .collection(dateFrom.year.toString())
          .doc(dateFrom.month.toString())
          .collection('Sales')
          .where('Date', isGreaterThanOrEqualTo: dateFrom)
          .where('Date', isLessThan: DateTime.now())
          .orderBy("Date", descending: true)
          .snapshots()
          .map(_salesFromSnapshot);
    } else {
      yield* FirebaseFirestore.instance
          .collection('ERP')
          .doc(businessID)
          .collection(dateFrom.year.toString())
          .doc(dateFrom.month.toString())
          .collection('Sales')
          .where('Date', isGreaterThanOrEqualTo: dateFrom)
          .where('Date', isLessThanOrEqualTo: dateTo)
          .orderBy("Date", descending: true)
          // .where('Order Name', isEqualTo: '1')
          .snapshots()
          .map(_salesFromSnapshot);
    }
  }

  //Edit Sale Payment Method
  Future editSalePaymentMethod(
    businessID,
    year,
    month,
    docID,
    paymentMethod,
  ) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection(year.toString())
        .doc(month.toString())
        .collection('Sales')
        .doc('$docID')
        .update({
      'Payment Type': paymentMethod,
    });
  }

  //Edit Sale Payment Method
  Future markSaleReversed(
    businessID,
    docID,
  ) async {
    var year = DateTime.now().year.toString();
    var month = DateTime.now().month.toString();

    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection(year)
        .doc(month)
        .collection('Sales')
        .doc('$docID')
        .update({
      'Reversed': true,
    });
  }

  //Stats from Snap
  Stream<MonthlyStats> monthlyStatsfromSnapshot(String businessID) async* {
    var year = DateTime.now().year.toString();
    var month = DateTime.now().month.toString();

    yield* FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection(year)
        .doc(month)
        .collection('Stats')
        .doc('Monthly Stats')
        .snapshots()
        .map(_monthlyStats);
  }

  //Get Daily Transactions
  MonthlyStats _monthlyStats(DocumentSnapshot snapshot) {
    try {
      return MonthlyStats(
        totalSales: snapshot.data().toString().contains('Total Sales')
            ? snapshot['Total Sales']
            : 0,
        totalSalesCount:
            snapshot.data().toString().contains('Total Sales Count')
                ? snapshot['Total Sales Count']
                : 0,
        totalItemsSold: snapshot.data().toString().contains('Total Items Sold')
            ? snapshot['Total Items Sold']
            : 0,
        salesCountbyProduct:
            snapshot.data().toString().contains('Sales Count by Product')
                ? snapshot['Sales Count by Product']
                : {},
        salesAmountbyProduct:
            snapshot.data().toString().contains('Sales Amount by Product')
                ? snapshot['Sales Amount by Product']
                : {},
        salesCountbyCategory:
            snapshot.data().toString().contains('Sales Count by Category')
                ? snapshot['Sales Count by Category']
                : {},
        salesAmountbyCategory:
            snapshot.data().toString().contains('Sales Amount by Category')
                ? snapshot['Sales Amount by Category']
                : {},
        salesbyOrderType:
            snapshot.data().toString().contains('Sales by Order Type')
                ? snapshot['Sales by Order Type']
                : {},
        salesByMedium:
            snapshot.data().toString().contains('Sales by Payment Type')
                ? snapshot['Sales by Payment Type']
                : {},
        totalSuppliesCost:
            snapshot.data().toString().contains('Cost of Used Supplies')
                ? snapshot['Cost of Used Supplies']
                : 0,
      );
    } catch (e) {
      print(e);
      return null;
    }
  }

  ////////////////////// AGENDAR VENTA

  /// Schedule
  Future scheduleSale(
      businessID,
      String transactionID,
      subTotal,
      discount,
      tax,
      total,
      orderDetail,
      orderName,
      DateTime dueDate,
      client,
      initialPayment,
      remainingBalance,
      String note) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection('Schedule')
        .doc(transactionID)
        .set({
      'Discount': discount,
      'IVA': tax,
      'Items': orderDetail,
      'Order Name': orderName,
      'Subtotal': subTotal,
      'Total': total,
      'Initial Payment': initialPayment,
      'Remaining Blanace': remainingBalance,
      'Document ID': transactionID,
      'Order Type': 'Encargo',
      'Saved Date': DateTime.now(),
      'Due Date': dueDate,
      'Client': client,
      'Pending': true,
      'Note': note
    });
  }

  //Delete scheduled Sale
  Future deleteScheduleSale(businessID, docID) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection('Schedule')
        .doc(docID)
        .delete();
  }

  // //Update Amount
  Future updateScheduledSale(businessID, scheduledID, remainingBalance) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection('Schedule')
        .doc(scheduledID)
        .update({
      'Remaining Blanace': remainingBalance,
    });
  }

  // //Mark as paid
  Future paidScheduledSale(businessID, scheduledID) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection('Schedule')
        .doc(scheduledID)
        .update({'Remaining Blanace': 0, 'Pending': false});
  }

  // // Receivables List from snapshot
  List<ScheduledSales> _scheduledListFromSnapshot(QuerySnapshot snapshot) {
    try {
      return snapshot.docs.map((doc) {
        return ScheduledSales(
          orderName: doc.data().toString().contains('Order Name')
              ? doc['Order Name']
              : '',
          subTotal:
              doc.data().toString().contains('Subtotal') ? doc['Subtotal'] : 0,
          total: doc.data().toString().contains('Total') ? doc['Total'] : 0,
          tax: doc.data().toString().contains('IVA') ? doc['IVA'] : 0,
          discount:
              doc.data().toString().contains('Discount') ? doc['Discount'] : 0,
          orderDetail:
              doc.data().toString().contains('Items') ? doc['Items'] : [],
          id: doc.data().toString().contains('Document ID')
              ? doc['Document ID']
              : '',
          savedDate: doc.data().toString().contains('Saved Date')
              ? doc['Saved Date'].toDate()
              : DateTime(1999, 1, 1),
          dueDate: doc.data().toString().contains('Due Date')
              ? doc['Due Date'].toDate()
              : DateTime(1999, 1, 1),
          client: doc.data().toString().contains('Client') ? doc['Client'] : {},
          initialPayment: doc.data().toString().contains('Initial Payment')
              ? doc['Initial Payment']
              : 0,
          remainingBalance: doc.data().toString().contains('Remaining Blanace')
              ? doc['Remaining Blanace']
              : 0,
          pending:
              doc.data().toString().contains('Pending') ? doc['Pending'] : true,
          note: doc.data().toString().contains('Note') ? doc['Note'] : '',
        );
      }).toList();
    } catch (e) {
      print(e);
      return null;
    }
  }

  // // Schedule initial Stream
  Stream<List<ScheduledSales>> scheduledList(businessID, DateTime date) async* {
    yield* FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection('Schedule')
        .where('Due Date',
            isGreaterThan: DateTime(date.year, date.month, date.day, 23, 59, 99)
                .subtract(Duration(days: 1)))
        .where('Due Date',
            isLessThanOrEqualTo:
                DateTime(date.year, date.month, date.day, 23, 59, 99))
        .orderBy('Due Date')
        .snapshots()
        .map(_scheduledListFromSnapshot);
  }

  ///////////////////////// Suppliers Data from Firestore //////////////////////////

  //Create Vendor
  Future createSupplier(
      activeBusiness,
      name,
      List searchName,
      id,
      email,
      phone,
      address,
      String predefinedCategory,
      String predefinedDescription,
      String account,
      List costTypes,
      docID) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(activeBusiness)
        .collection('Proveedores')
        .doc(name)
        .set({
      'Name': name,
      'Search Name': searchName,
      'ID': id,
      'email': email,
      'Phone': phone,
      'Address': address,
      'Products': [],
      'Invoices': [],
      'Doc ID': docID,
      'Cost Types': costTypes,
      'Initial Expense Description': predefinedDescription,
      'Predefined Category': predefinedCategory,
      'Predefined Account': account
    });
  }

  //  Edit Vendor
  Future editSupplierData(
    activeBusiness,
    docID,
    name,
    List searchName,
    id,
    email,
    phone,
    address,
    List costTypes,
    String predefinedCategory,
    String predefinedDescription,
    String account,
  ) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(activeBusiness)
        .collection('Proveedores')
        .doc(docID)
        .update({
      'Name': name,
      'Search Name': searchName,
      'ID': id,
      'email': email,
      'Phone': phone,
      'Address': address,
      'Cost Types': costTypes,
      'Initial Expense Description': predefinedDescription,
      'Predefined Category': predefinedCategory,
      'Predefined Account': account
    });
  }

  // Suppliers List from snapshot
  List<Supplier> _supplierList(QuerySnapshot snapshot) {
    try {
      return snapshot.docs.map((doc) {
        return Supplier(
            name: doc.data().toString().contains('Name') ? doc['Name'] : '',
            searchName: doc.data().toString().contains('Search Name')
                ? doc['Search Name']
                : [],
            id: doc.data().toString().contains('ID') ? doc['ID'] : '',
            email: doc.data().toString().contains('email') ? doc['email'] : '',
            phone:
                doc.data().toString().contains('Phone') ? doc['Phone'] : 0000,
            address:
                doc.data().toString().contains('Address') ? doc['Address'] : '',
            products: doc.data().toString().contains('Products')
                ? doc['Products']
                : [],
            invoices: doc.data().toString().contains('Invoices')
                ? doc['Invoices']
                : [],
            costTypeAssociated: doc.data().toString().contains('Cost Types')
                ? doc['Cost Types']
                : [],
            predefinedCategory:
                doc.data().toString().contains('Predefined Category')
                    ? doc['Predefined Category']
                    : '',
            initialExpenseDescription:
                doc.data().toString().contains('Initial Expense Description')
                    ? doc['Initial Expense Description']
                    : '',
            predefinedAccount:
                doc.data().toString().contains('Predefined Account')
                    ? doc['Predefined Account']
                    : '',
            docID: doc.id);
      }).toList();
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Suppliers List Stream by name
  Stream<List<Supplier>> allSuppliersList(String businessID, int limit) async* {
    yield* FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection('Proveedores')
        // .orderBy('Name')
        // .limit(limit)
        .snapshots()
        .map(_supplierList);
  }

  // Suppliers List Stream by name
  Stream<List<Supplier>> suppliersList(
      String businessID, String searchName) async* {
    yield* FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection('Proveedores')
        .where('Search Name', arrayContains: searchName)
        .snapshots()
        .map(_supplierList);
  }

  // Suppliers List by Account/Category Stream
  Stream<List<Supplier>> suppliersListbyCategory(
      String businessID, String costType) async* {
    yield* FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection('Proveedores')
        .where('Cost Types', arrayContains: costType)
        .snapshots()
        .map(_supplierList);
  }

  //Supplier from Snap
  Stream<Supplier> supplierfromSnapshot(
      String businessID, String supplierID) async* {
    yield* FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection('Proveedores')
        .doc(supplierID)
        .snapshots()
        .map(_supplier);
  }

  //Get Supplier
  Supplier _supplier(DocumentSnapshot snapshot) {
    try {
      return Supplier(
          name: snapshot.data().toString().contains('Name')
              ? snapshot['Name']
              : '',
          searchName: snapshot.data().toString().contains('Search Name')
              ? snapshot['Search Name']
              : [],
          id: snapshot.data().toString().contains('ID') ? snapshot['ID'] : '',
          email: snapshot.data().toString().contains('email')
              ? snapshot['email']
              : '',
          phone: snapshot.data().toString().contains('Phone')
              ? snapshot['Phone']
              : 0000,
          address: snapshot.data().toString().contains('Address')
              ? snapshot['Address']
              : '',
          products: snapshot.data().toString().contains('Products')
              ? snapshot['Products']
              : [],
          costTypeAssociated: snapshot.data().toString().contains('Cost Types')
              ? snapshot['Cost Types']
              : [],
          predefinedCategory:
              snapshot.data().toString().contains('Predefined Category')
                  ? snapshot['Predefined Category']
                  : '',
          initialExpenseDescription:
              snapshot.data().toString().contains('Initial Expense Description')
                  ? snapshot['Initial Expense Description']
                  : '',
          predefinedAccount:
              snapshot.data().toString().contains('Predefined Account')
                  ? snapshot['Predefined Account']
                  : '',
          invoices: snapshot.data().toString().contains('Invoices')
              ? snapshot['Invoices']
              : [],
          docID: snapshot.id);
    } catch (e) {
      print(e);
      return null;
    }
  }

  //////////////////// INSUMOS ///////////////////////////

  //Create Supply
  Future createSuppy(
      activeBusiness,
      supply,
      List searchName,
      double price,
      String unit,
      double qty,
      List suppliers,
      List suppliersSearchName,
      List recipe,
      List priceHistory,
      List listofIngredients) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(activeBusiness)
        .collection('Supplies')
        .doc(supply)
        .set({
      'Name': supply,
      'Search Name': searchName,
      'Price': price,
      'Unit': unit,
      'Quantity': qty,
      'Suppliers': suppliers,
      'Suppliers Search Name': suppliersSearchName,
      'Recipe': recipe,
      'Price History': priceHistory,
      'List of Ingredients': listofIngredients
    });
  }

  //Edit Supply
  Future editSuppy(
      activeBusiness,
      String docID,
      String supply,
      List searchName,
      double price,
      String unit,
      double qty,
      List suppliers,
      List suppliersSearchName,
      List recipe,
      List priceHistory,
      List listofIngredients) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(activeBusiness)
        .collection('Supplies')
        .doc(docID)
        .update({
      'Name': supply,
      'Search Name': searchName,
      'Price': price,
      'Unit': unit,
      'Quantity': qty,
      'Suppliers': suppliers,
      'Suppliers Search Name': suppliersSearchName,
      'Recipe': recipe,
      'Price History': priceHistory,
      'List of Ingredients': listofIngredients
    });
  }

  //Edit Supply Cost
  Future editSupplyCost(
      activeBusiness, String supply, double price, priceHistory) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(activeBusiness)
        .collection('Supplies')
        .doc(supply)
        .update({
      'Price': price,
      'Price History': priceHistory,
    });
  }

  //Edit product supply
  Future editSupplyIngredients(
    String activeBusiness,
    supply,
    ingredients,
  ) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(activeBusiness)
        .collection('Supplies')
        .doc(supply)
        .update({
      'Recipe': ingredients,
    });
  }

  // Suppliers List from snapshot
  List<Supply> _supplyList(QuerySnapshot snapshot) {
    try {
      return snapshot.docs.map((doc) {
        return Supply(
            supply: doc.data().toString().contains('Name') ? doc['Name'] : '',
            searchName: doc.data().toString().contains('Search Name')
                ? doc['Search Name']
                : [],
            price: doc.data().toString().contains('Price') ? doc['Price'] : 0,
            unit: doc.data().toString().contains('Unit') ? doc['Unit'] : '',
            qty: doc.data().toString().contains('Quantity')
                ? doc['Quantity']
                : 0,
            suppliersSearchName:
                doc.data().toString().contains('Suppliers Search Name')
                    ? doc['Suppliers Search Name']
                    : [],
            suppliers: doc.data().toString().contains('Suppliers')
                ? doc['Suppliers']
                : [],
            recipe: doc.data().toString().contains('Recipe')
                ? doc['Recipe']
                // doc['Recipe'].map<SupplyRecipe>((item) {
                //     return SupplyRecipe(
                //       ingredient: item['Ingredient'] ?? '',
                //       qty: item['Quantity'] ?? 0,
                //     );
                //   }).toList()
                : [],
            priceHistory: doc.data().toString().contains('Price History')
                ? doc['Price History']
                : [],
            listofIngredients:
                doc.data().toString().contains('List of Ingredients')
                    ? doc['List of Ingredients']
                    : [],
            docID: doc.id);
      }).toList();
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Suppliers List from snapshot
  Supply _supply(DocumentSnapshot doc) {
    try {
      return Supply(
          supply: doc.data().toString().contains('Name') ? doc['Name'] : '',
          searchName: doc.data().toString().contains('Search Name')
              ? doc['Search Name']
              : [],
          price: doc.data().toString().contains('Price') ? doc['Price'] : 0,
          unit: doc.data().toString().contains('Unit') ? doc['Unit'] : '',
          qty: doc.data().toString().contains('Quantity') ? doc['Quantity'] : 0,
          suppliersSearchName:
              doc.data().toString().contains('Suppliers Search Name')
                  ? doc['Suppliers Search Name']
                  : [],
          suppliers: doc.data().toString().contains('Suppliers')
              ? doc['Suppliers']
              : [],
          recipe: doc.data().toString().contains('Recipe')
              ? doc['Recipe']
              // doc['Recipe'].map<SupplyRecipe>((item) {
              //     return SupplyRecipe(
              //       ingredient: item['Ingredient'] ?? '',
              //       qty: item['Quantity'] ?? 0,
              //     );
              //   }).toList()
              : [],
          priceHistory: doc.data().toString().contains('Price History')
              ? doc['Price History']
              : [],
          listofIngredients:
              doc.data().toString().contains('List of Ingredients')
                  ? doc['List of Ingredients']
                  : [],
          docID: doc.id);
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Supplies List Stream by name
  Stream<List<Supply>> allSuppliesList(String businessID, int limit) async* {
    yield* FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection('Supplies')
        .orderBy('Name')
        .limit(limit)
        .snapshots()
        .map(_supplyList);
  }

  // Supplies List Stream by name
  Stream<List<Supply>> suppliesListbyName(
      String businessID, String searchName) async* {
    yield* FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection('Supplies')
        .where('Search Name', arrayContains: searchName)
        .snapshots()
        .map(_supplyList);
  }

  // Supplies List Stream by name
  Stream<List<Supply>> suppliesListbyVendor(
      String businessID, String vendor) async* {
    yield* FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection('Supplies')
        .where('Suppliers Search Name', arrayContains: vendor)
        .snapshots()
        .map(_supplyList);
  }

  // Individual Ingredient for cost calculation
  Stream<Supply> supplyFromSnapshot(String businessID, String name) async* {
    yield* FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection('Supplies')
        .doc(name)
        .snapshots()
        .map(_supply);
  }

  //Create Order
  Future createOrderTest() async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc('xmsjeOqo8ech27t')
        .collection('Pending')
        .doc(DateTime.now().toString())
        .set({
      'Order Name': 'Test',
      'Address': 'Test',
      'Phone': 0000000,
      'Saved Date': DateTime.now(),
      'Discount': 0,
      'IVA': 0,
      'Items': [],
      'Payment Type': 'Efectivo',
      'Total': 100,
      'Order Type': 'Takeaway'
    });
  }

  //////////////////////////////////// DISCOUNTS ////////////////////////////////////

  //Discount Lists
  List<Discounts> discountList(QuerySnapshot snapshot) {
    try {
      return snapshot.docs.map((doc) {
        return Discounts(
            code: doc.data().toString().contains('Code') ? doc['Code'] : '',
            description: doc.data().toString().contains('Description')
                ? doc['Description']
                : [],
            discount: doc.data().toString().contains('Discount')
                ? doc['Discount']
                : 0,
            active: doc.data().toString().contains('Active')
                ? doc['Active']
                : false,
            numberOfUses: doc.data().toString().contains('Number of Uses')
                ? doc['Number of Uses']
                : 0,
            createdDate: doc.data().toString().contains('Created Date')
                ? doc['Created Date'].toDate()
                : null,
            validUntil: (doc.data().toString().contains('Valid Until') &&
                    doc['Valid Until'] != null)
                ? doc['Valid Until'].toDate()
                : null);
      }).toList();
    } catch (e) {
      print(e);
      return null;
    }
  }

  Stream<List<Discounts>> allDiscountsList(String businessID) async* {
    yield* FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection('Discounts')
        .orderBy('Created Date', descending: true)
        .snapshots()
        .map(discountList);
  }

  Future createDiscount(
      activeBusiness, String code, String description, double discount) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(activeBusiness)
        .collection('Discounts')
        .doc(code)
        .set({
      'Code': code,
      'Description': description,
      'Discount': discount,
      'Active': true,
      'Number of Uses': 0,
      'Created Date': DateTime.now(),
      'Valid Until': null,
    });
  }

  Future useDiscount(activeBusiness, String code) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(activeBusiness)
        .collection('Discounts')
        .doc(code)
        .update({
      'Number of Uses': FieldValue.increment(1),
    });
  }

  Future editDiscount(
      activeBusiness, String code, String description, bool active) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(activeBusiness)
        .collection('Discounts')
        .doc(code)
        .update({
      'Description': description,
      'Active': active,
    });
  }

  Future deleteDiscount(activeBusiness, String code) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(activeBusiness)
        .collection('Discounts')
        .doc(code)
        .delete();
  }

  //Discount Uses
  List<Sales> discountUsesList(QuerySnapshot snapshot) {
    try {
      return snapshot.docs.map((doc) {
        return Sales(
          account:
              doc.data().toString().contains('Account') ? doc['Account'] : '',
          date: doc.data().toString().contains('Date')
              ? doc['Date'].toDate()
              : DateTime.now(),
          discount:
              doc.data().toString().contains('Discount') ? doc['Discount'] : 0,
          tax: doc.data().toString().contains('IVA') ? doc['IVA'] : 0,
          soldItems: doc.data().toString().contains('Items')
              ? doc['Items'].map<SoldItems>((item) {
                  return SoldItems(
                    product: item['Name'] ?? '',
                    category: item['Category'] ?? '',
                    price: item['Price'] ?? 0,
                    qty: item['Quantity'] ?? 0,
                    total: item['Total Price'] ?? 0,
                  );
                }).toList()
              : [],
          orderName: doc.data().toString().contains('Order Name')
              ? doc['Order Name']
              : '',
          subTotal:
              doc.data().toString().contains('Subtotal') ? doc['Subtotal'] : 0,
          total: doc.data().toString().contains('Total') ? doc['Total'] : 0,
          paymentType: doc.data().toString().contains('Payment Type')
              ? doc['Payment Type']
              : '',
          clientName:
              doc.data().toString().contains('Client') ? doc['Client'] : '',
          clientDetails: doc.data().toString().contains('Client Details')
              ? doc['Client Details']
              : {},
          transactionID: doc.data().toString().contains('Transaction ID')
              ? doc['Transaction ID']
              : '',
          docID: doc.id,
          cashRegister: doc.data().toString().contains('Cash Register')
              ? doc['Cash Register']
              : '',
          reversed: doc.data().toString().contains('Reversed')
              ? doc['Reversed']
              : false,
          orderType: doc.data().toString().contains('Order Type')
              ? doc['Order Type']
              : '',
          splitPaymentDetails:
              doc.data().toString().contains('Split Payment Details')
                  ? doc['Split Payment Details'].toList()
                  : [],
        );
      }).toList();
    } catch (e) {
      print(e);
      return null;
    }
  }

  Stream<List<Sales>> allDiscountUsesList(
      String businessID, String code) async* {
    yield* FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection('Discounts')
        .doc(code)
        .collection('Uses')
        .snapshots()
        .map(discountUsesList);
  }

  Future registerDiscountUse(
      String discountCode,
      String businessID,
      String documentID,
      String year,
      String month,
      DateTime transactionDate,
      subTotal,
      discount,
      tax,
      total,
      orderDetail,
      orderName,
      paymentType,
      String clientName,
      Map clientDetails,
      transactionID,
      String currentCashRegister,
      bool reversed,
      List splitPaymentDetails,
      orderType) async {
    return await FirebaseFirestore.instance
        .collection('ERP')
        .doc(businessID)
        .collection('Discounts')
        .doc(discountCode)
        .collection('Uses')
        .doc(documentID)
        .set({
      'Account': 'Ventas',
      'Date': transactionDate,
      'Discount': discount,
      'IVA': tax,
      'Items': orderDetail,
      'Order Name': orderName,
      'Payment Type': paymentType,
      'Subtotal': subTotal,
      'Total': total,
      'Client': clientName,
      'Client Details': clientDetails,
      'Transaction ID': transactionID,
      'Cash Register': currentCashRegister,
      'Reversed': reversed,
      'Split Payment Details': splitPaymentDetails,
      'Order Type': orderType
    });
  }

  ////////////////////////////////////Clone Products Collection
  // Future cloneGaliaMenu() async {
  //   final QuerySnapshot snapshot = await FirebaseFirestore.instance
  //       .collection('Products')
  //       .doc('VTam7iYZhiWiAFs3IVRBaLB5s3m2')
  //       .collection('Menu')
  //       .get();
  //   final CollectionReference newCollectionRef = FirebaseFirestore.instance
  //       .collection('Products')
  //       .doc('DjGEhTFq4pPzHMr')
  //       .collection('Menu');

  //   snapshot.docs.forEach((doc) {
  //     newCollectionRef.doc(doc.id).set(doc.data());
  //   });

  //   print('Finito');
  // }

  ////////////////////////////////////Get total of a collection
  // Future totalGaliaExp() async {
  //   final QuerySnapshot snapshot = await FirebaseFirestore.instance
  //       .collection('ERP')
  //       .doc('VTam7iYZhiWiAFs3IVRBaLB5s3m2')
  //       .collection('2023')
  //       .doc('4')
  //       .collection('Sales')
  //       .get();

  //   double sum = 0.0;

  //   snapshot.docs.forEach((doc) {
  //     sum += doc['Total'];
  //   });

  //   print(sum);
  // }
}

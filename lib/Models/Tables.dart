import 'package:flutter/material.dart';

class Tables {
  String? table;
  String? assignedOrder;
  bool? isOpen;
  DateTime? openSince;
  int? numberOfPeople;
  int? subTotal;
  int? total;
  int? tax;
  int? discount;
  String? paymentType;
  List? orderDetail;
  int? orderColor;
  Map? client;
  //Draggable section
  bool? isOccupied;
  String? shape;
  double? x;
  double? y;
  double? tableSize;
  String? docID;

  Tables(
      {this.table,
      this.assignedOrder,
      this.isOpen,
      this.openSince,
      this.numberOfPeople,
      this.subTotal,
      this.total,
      this.tax,
      this.discount,
      this.paymentType,
      this.orderDetail,
      this.orderColor,
      this.client,
      //draggable section
      this.isOccupied,
      this.shape,
      this.x,
      this.y,
      this.tableSize,
      this.docID});

  Map<String, dynamic> toMap() {
    return {
      'Code': table,
      'Assigned Order': assignedOrder,
      'Open': isOpen,
      'Open Since': openSince,
      'People': numberOfPeople,
      'Subtotal': subTotal,
      'Total': total,
      'IVA': tax,
      'Discount': discount,
      'Payment Type': paymentType,
      'docID': docID,
      'Items': orderDetail,
      'Color': orderColor,
      'Assigned Client': client,
      'Occupied': isOccupied,
      'Shape': shape,
      'X Axis': x,
      'Y Axis': y,
      'Table Size': tableSize
    };
  }

  factory Tables.fromFirestore(Map<String, dynamic> data, String docID) {
    return Tables(
        table: data.toString().contains('Code') ? data['Code'] : '',
        assignedOrder: data.toString().contains('Assigned Order')
            ? data['Assigned Order']
            : '',
        isOpen: data.toString().contains('Open') ? data['Open'] : false,
        openSince: data.toString().contains("Open Since")
            ? data['Open Since'].toDate()
            : DateTime.now(),
        numberOfPeople: data.toString().contains('People') ? data['People'] : 0,
        //Order
        subTotal: data.toString().contains('Subtotal') ? data['Subtotal'] : 0,
        total: data.toString().contains('Total') ? data['Total'] : 0,
        tax: data.toString().contains('IVA') ? data['IVA'] : 0,
        discount: data.toString().contains('Discount') ? data['Discount'] : 0,
        orderColor: data.toString().contains('Color')
            ? data['Color']
            : Colors.grey.value,
        paymentType: data.toString().contains('Payment Type')
            ? data['Payment Type']
            : '',
        orderDetail: data.toString().contains('Items') ? data['Items'] : [],
        client: data.toString().contains('Assigned Client')
            ? data['Assigned Client']
            : {},
        //Draggable section
        isOccupied:
            data.toString().contains('Occupied') ? data['Occupied'] : false,
        shape: data.toString().contains('Shape') ? data['Shape'] : 'Square',
        x: data.toString().contains('X Axis') ? data['X Axis'] : 0,
        y: data.toString().contains('Y Axis') ? data['Y Axis'] : 0,
        tableSize:
            data.toString().contains('Table Size') ? data['Table Size'] : 75,
        docID: docID);
  }
}

class TablesNotifier extends ChangeNotifier {
  List<Tables> tables = [];
  List<Tables> get myTables => tables;

  TablesNotifier({List<Tables>? initialItems}) : tables = initialItems ?? [];

  void addTable(Tables table) {
    tables = [...tables, table];
    notifyListeners();
  }

  void editTable(Tables table, int tableIndex) {
    tables[tableIndex] = table;
    notifyListeners();
  }

  void basicTest(int i) {
    print(i);
  }

  void removeTable(Tables table) {
    tables.remove(table);
    notifyListeners();
  }
}

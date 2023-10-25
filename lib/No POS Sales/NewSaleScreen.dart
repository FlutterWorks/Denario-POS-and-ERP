import 'dart:math';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Backend/Ticket.dart';
import 'package:denario/Models/Categories.dart';
import 'package:denario/Models/DailyCash.dart';
import 'package:denario/Models/Stats.dart';
import 'package:denario/Models/User.dart';
import 'package:denario/No%20POS%20Sales/ScheduleSaleDialog.dart';
import 'package:denario/No%20POS%20Sales/SelectItemDialog.dart';
import 'package:denario/POS/ConfirmOrder.dart';
import 'package:denario/POS/DiscountDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NewSaleScreen extends StatefulWidget {
  final String currentBusiness;
  final bool fromPOS;
  NewSaleScreen(this.currentBusiness, {required this.fromPOS});

  @override
  State<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends State<NewSaleScreen> {
  final formatCurrency = new NumberFormat.simpleCurrency();
  int numberOfItems = 0;
  late String invoiceNo;
  late DateTime selectedIvoiceDate;
  String clientName = '';
  final FocusNode _clientNode = FocusNode();
  List saleStatusList = ['Cobrado', 'Venta por cobrar'];
  String saleStatus = 'Cobrado';

  String? orderName;
  double? tax;
  double? discount;

  List<TextEditingController> _controllers = [];
  late TextEditingController invoiceController;
  late TextEditingController clientController;

  ValueKey redrawObject = ValueKey('List');

  Map<String, dynamic>? orderCategories;
  double? salesAmount;
  String? paymentType;

  //Month Stats Variables
  Map<String, dynamic> orderStats = {};
  int? currentSalesCount;
  Map<String, dynamic> currentItemsCount = {};
  Map<String, dynamic> currentItemsAmount = {};
  Map<String, dynamic> salesCountbyCategory = {};
  Map<String, dynamic> currentSalesbyOrderType = {};
  int? newSalesCount;
  int? currentTicketItemsCount;
  int? newTicketItemsCount;

  void nothing(BuildContext context) {}

  void clearControllers() {
    setState(() {
      _controllers = [];
      invoiceNo = '00' +
          (DateTime.now().day).toString() +
          (DateTime.now().month).toString() +
          (DateTime.now().year).toString() +
          (DateTime.now().hour).toString() +
          (DateTime.now().minute).toString() +
          (DateTime.now().millisecond).toString();
      selectedIvoiceDate = DateTime.now();
      orderName = 'Sin Agregar';
      tax = 0;
      discount = 0;
      clientController = new TextEditingController(text: '');
      invoiceController = new TextEditingController(text: invoiceNo);
      clientName = '';
      bloc.removeAllFromCart();
    });
  }

  void initState() {
    invoiceNo = '00' +
        (DateTime.now().day).toString() +
        (DateTime.now().month).toString() +
        (DateTime.now().year).toString() +
        (DateTime.now().hour).toString() +
        (DateTime.now().minute).toString() +
        (DateTime.now().millisecond).toString();
    selectedIvoiceDate = DateTime.now();
    orderName = 'Sin Agregar';
    tax = 0;
    discount = 0;
    invoiceController = new TextEditingController(text: invoiceNo);

    if (bloc.ticketItems["Order Name"] != '') {
      clientController =
          new TextEditingController(text: bloc.ticketItems["Order Name"]);
    } else {
      clientController = new TextEditingController(text: '');
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = Provider.of<UserData>(context);
    final registerStatus = Provider.of<CashRegister>(context);

    if (registerStatus == CashRegister()) {
      return Container();
    }

    final String? businessName = userProfile
        .businesses![userProfile.businesses!
            .indexWhere((x) => x.businessID == userProfile.activeBusiness)]
        .businessName;

    if (MediaQuery.of(context).size.width > 650) {
      return StreamBuilder(
          stream: bloc.getStream,
          initialData: bloc.ticketItems,
          builder: (context, AsyncSnapshot snapshot) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: (MediaQuery.of(context).size.width > 1100)
                              ? const EdgeInsets.fromLTRB(20, 30, 20, 30)
                              : EdgeInsets.only(bottom: 20),
                          child: IconButton(
                              onPressed: () {
                                if (widget.fromPOS) {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                } else {
                                  bloc.removeAllFromCart();
                                  Navigator.of(context).pop();
                                }
                              },
                              icon: Icon(Icons.arrow_back),
                              iconSize: 20.0),
                        ),
                        SizedBox(
                          width: 25,
                        ),
                        Padding(
                          padding: (MediaQuery.of(context).size.width > 1100)
                              ? const EdgeInsets.fromLTRB(20, 30, 20, 30)
                              : EdgeInsets.only(bottom: 20),
                          child: Text(
                            'Nueva venta',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize:
                                    (MediaQuery.of(context).size.width > 1100)
                                        ? 28
                                        : 24),
                          ),
                        ),
                      ],
                    ),
                    //Sales Fields
                    Container(
                      width: 900,
                      padding: EdgeInsets.all(
                          (MediaQuery.of(context).size.width > 650) ? 40 : 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: <BoxShadow>[
                          new BoxShadow(
                            color: Colors.grey[350]!,
                            offset: new Offset(0, 0),
                            blurRadius: 10.0,
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //Heading
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //Negocio
                              Text(
                                businessName!,
                                style: TextStyle(
                                    fontWeight: FontWeight.w800, fontSize: 24),
                              ),
                              Spacer(),
                              Text(
                                DateFormat('dd/MM/yyyy').format(DateTime.now()),
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w300,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                          SizedBox(height: 30),
                          //Invoice and client
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //Invoice
                              Expanded(
                                child: Container(
                                  child: TextFormField(
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16),
                                    cursorColor: Colors.grey,
                                    controller: invoiceController,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      label: Text(
                                        'Nro de referencia',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12,
                                            color: Colors.black45),
                                      ),
                                      border: new OutlineInputBorder(
                                        borderRadius:
                                            new BorderRadius.circular(12.0),
                                        borderSide: new BorderSide(
                                          color: Colors.grey,
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
                                  ),
                                ),
                              ),
                              SizedBox(width: 20),
                              //Client
                              Expanded(
                                child: Container(
                                  child: TextFormField(
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16),
                                    cursorColor: Colors.grey,
                                    focusNode: _clientNode,
                                    controller: clientController,
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      label: Text(
                                        'Cliente',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12,
                                            color: Colors.black45),
                                      ),
                                      errorStyle: TextStyle(
                                          color: Colors.redAccent[700],
                                          fontSize: 12),
                                      border: new OutlineInputBorder(
                                        borderRadius:
                                            new BorderRadius.circular(12.0),
                                        borderSide: new BorderSide(
                                          color: Colors.grey,
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
                                    onFieldSubmitted: (term) {
                                      _clientNode.unfocus();
                                      // FocusScope.of(context).requestFocus(_tlfNode);
                                    },
                                    onChanged: (val) {
                                      setState(() {
                                        clientName = val;
                                        clientController.text = val;
                                        clientController.selection =
                                            TextSelection.fromPosition(
                                                TextPosition(
                                                    offset: clientController
                                                        .text.length));
                                        bloc.changeOrderName(val);
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          //Date
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Fecha de venta',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          color: Colors.black45),
                                    ),
                                    SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      padding: EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          Text(
                                            DateFormat('dd/MM/yyyy')
                                                .format(selectedIvoiceDate),
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 16),
                                          ),
                                          Spacer(),
                                          Container(
                                            height: 20,
                                            width: 20,
                                            child: IconButton(
                                              splashRadius: 1,
                                              onPressed: () async {
                                                DateTime? pickedDate =
                                                    await showDatePicker(
                                                        context: context,
                                                        initialDate:
                                                            DateTime.now(),
                                                        firstDate: DateTime
                                                                .now()
                                                            .subtract(Duration(
                                                                days: 10)),
                                                        lastDate:
                                                            DateTime.now(),
                                                        builder:
                                                            ((context, child) {
                                                          return Theme(
                                                              data: Theme.of(
                                                                      context)
                                                                  .copyWith(
                                                                colorScheme:
                                                                    ColorScheme
                                                                        .light(
                                                                  primary: Colors
                                                                      .black, // header background color
                                                                  onPrimary: Colors
                                                                      .white, // header text color
                                                                  onSurface: Colors
                                                                      .black, // body text color
                                                                ),
                                                                textButtonTheme:
                                                                    TextButtonThemeData(
                                                                  style: TextButton
                                                                      .styleFrom(
                                                                    foregroundColor:
                                                                        Colors
                                                                            .black, // button text color
                                                                  ),
                                                                ),
                                                              ),
                                                              child: child!);
                                                        }));
                                                setState(() {
                                                  selectedIvoiceDate =
                                                      pickedDate!;
                                                });
                                              },
                                              padding: EdgeInsets.all(0),
                                              tooltip:
                                                  'Seleccionar fecha de la venta',
                                              iconSize: 18,
                                              icon: Icon(Icons.calendar_month),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              )),
                              SizedBox(width: 40),
                              Expanded(child: Container()),
                            ],
                          ),
                          SizedBox(height: 25),
                          //Lista de items
                          Text(
                            'Items',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 18),
                          ),
                          SizedBox(height: 20),
                          ListView.builder(
                              key: redrawObject,
                              shrinkWrap: true,
                              itemCount: snapshot.data["Items"].length,
                              itemBuilder: (context, i) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 15.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      //Product
                                      Expanded(
                                        flex: 6,
                                        child: Container(
                                          width: 400,
                                          height: 50,
                                          child: TextFormField(
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14),
                                            cursorColor: Colors.grey,
                                            textInputAction:
                                                TextInputAction.next,
                                            initialValue: snapshot.data["Items"]
                                                [i]['Name'],
                                            readOnly: true,
                                            decoration: InputDecoration(
                                              label: Text('Descripción'),
                                              labelStyle: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12),
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
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      //Price
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          width: 100,
                                          child: TextFormField(
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14),
                                            autofocus: true,
                                            cursorColor: Colors.grey,
                                            textInputAction:
                                                TextInputAction.next,
                                            inputFormatters: [
                                              CurrencyTextInputFormatter(
                                                name: '\$',
                                                locale: 'en',
                                                decimalDigits: 2,
                                              ),
                                            ],
                                            initialValue: (snapshot
                                                            .data["Items"][i]
                                                        ['Price'] >
                                                    0)
                                                ? '\$${snapshot.data["Items"][i]['Price']}'
                                                : null,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              floatingLabelBehavior:
                                                  FloatingLabelBehavior.always,
                                              hintText: '\$0.00',
                                              label: Text('Precio'),
                                              labelStyle: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12),
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
                                            onFieldSubmitted: (term) {
                                              // _nameNode.unfocus();
                                              // FocusScope.of(context).requestFocus(_tlfNode);
                                            },
                                            onChanged: (val) {
                                              bloc.editPrice(
                                                  i,
                                                  double.tryParse((val
                                                          .substring(1))
                                                      .replaceAll(',', '')));
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      //Qty
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          width: 75,
                                          child: TextFormField(
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14),
                                            textAlign: TextAlign.center,
                                            autofocus: true,
                                            cursorColor: Colors.grey,
                                            textInputAction:
                                                TextInputAction.next,
                                            initialValue: snapshot.data["Items"]
                                                    [i]['Quantity']
                                                .toString(),
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              label: Text('Cantidad'),
                                              labelStyle: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12),
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
                                            onFieldSubmitted: (term) {
                                              // _nameNode.unfocus();
                                              // FocusScope.of(context).requestFocus(_tlfNode);
                                            },
                                            onChanged: (val) {
                                              bloc.editQuantity(
                                                  i, int.parse(val));
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      //Total
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          width: 100,
                                          decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          padding: EdgeInsets.all(12),
                                          child: Text(
                                            formatCurrency.format(
                                                snapshot.data["Items"][i]
                                                    ['Total Price']),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      //Detele
                                      IconButton(
                                          onPressed: () {
                                            bloc.removeFromCart(
                                                snapshot.data["Items"][i]);

                                            final random = Random();
                                            const availableChars =
                                                'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
                                            final randomString = List.generate(
                                                10,
                                                (index) => availableChars[random
                                                    .nextInt(availableChars
                                                        .length)]).join();
                                            setState(() {
                                              redrawObject =
                                                  ValueKey(randomString);
                                            });
                                          },
                                          icon: Icon(Icons.delete))
                                    ],
                                  ),
                                );
                              }),

                          //Boton de Agregar Items (cuadrado con +) => Lleva a seleccionar productos
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 20),
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black,
                              ),
                              onPressed: () {
                                for (var x = 0; x < 3; x++) {
                                  _controllers.add(new TextEditingController());
                                }

                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return StreamProvider<CategoryList>.value(
                                          initialData: CategoryList(),
                                          value: DatabaseService()
                                              .categoriesList(
                                                  userProfile.activeBusiness),
                                          child: SelectItemDialog(userProfile));
                                    });
                              },
                              child: Container(
                                height: 70,
                                width: 70,
                                child: Center(
                                    child: Icon(
                                  Icons.add,
                                  color: Colors.black87,
                                  size: 30,
                                )),
                              ),
                            ),
                          ),
                          //Spacer

                          //Impuesto + boton para editar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //Text
                              Text(
                                'Subtotal',
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: Colors.black),
                              ),
                              SizedBox(width: 25),
                              //Amount
                              Text(
                                formatCurrency
                                    .format(bloc.subtotalTicketAmount),
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 18,
                                    color: Colors.black),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          //Discount
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              //Button
                              IconButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return DiscountDialog(
                                            widget.currentBusiness);
                                      });
                                },
                                icon: Icon(Icons.edit),
                                splashRadius: 5,
                              ),
                              SizedBox(width: 15),
                              //Text
                              Text(
                                (snapshot.data['Discount Code'] == '')
                                    ? 'Descuento'
                                    : 'Descuento ' +
                                        snapshot.data['Discount Code'],
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: Colors.black),
                              ),
                              SizedBox(width: 25),
                              //Amount
                              Text(
                                formatCurrency
                                    .format(snapshot.data['Discount']),
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 18,
                                    color: (snapshot.data['Discount'] > 0)
                                        ? Colors.redAccent
                                        : Colors.black),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          //Total
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //Text
                              Text(
                                'TOTAL',
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                    color: Colors.black),
                              ),
                              SizedBox(width: 25),
                              //Amount
                              Text(
                                formatCurrency.format(bloc.totalTicketAmount),
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                    color: Colors.black),
                              ),
                            ],
                          ),
                          SizedBox(height: 50),
                          //Confirm Button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //Schedule
                              OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.black,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return ScheduleSaleDialog(
                                              widget.currentBusiness,
                                              bloc.totalTicketAmount,
                                              discount!,
                                              tax!,
                                              bloc.subtotalTicketAmount,
                                              bloc.ticketItems['Items'],
                                              clientName,
                                              clearControllers);
                                        });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 15),
                                    child: Center(
                                      child: Text('Agendar venta'),
                                    ),
                                  )),
                              SizedBox(width: 25),
                              //Confirm and close
                              ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.black),
                                    overlayColor: MaterialStateProperty
                                        .resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                        if (states
                                            .contains(MaterialState.hovered))
                                          return Colors.grey;
                                        if (states.contains(
                                                MaterialState.focused) ||
                                            states.contains(
                                                MaterialState.pressed))
                                          return Colors.grey.shade300;
                                        return Colors.grey
                                            .shade300; // Defer to the widget's default.
                                      },
                                    ),
                                  ),
                                  onPressed: () {
                                    if (bloc.totalTicketAmount <= 0) {
                                    } else {
                                      bloc.changePaymentType('Efectivo');
                                      bloc.changeOrderName(orderName);
                                      bloc.changeOrderType(
                                          'Venta Independiente');
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return MultiProvider(
                                              providers: [
                                                StreamProvider<
                                                        MonthlyStats>.value(
                                                    initialData: MonthlyStats(),
                                                    value: DatabaseService()
                                                        .monthlyStatsfromSnapshot(
                                                            userProfile
                                                                .activeBusiness!)),
                                                StreamProvider<UserData>.value(
                                                    initialData: UserData(),
                                                    value: DatabaseService()
                                                        .userProfile(
                                                            userProfile.uid!)),
                                              ],
                                              child: ConfirmOrder(
                                                total: bloc.totalTicketAmount,
                                                items: snapshot.data["Items"],
                                                discount:
                                                    snapshot.data['Discount'],
                                                discountCode: snapshot
                                                    .data['Discount Code'],
                                                orderDetail:
                                                    snapshot.data["Items"],
                                                orderName: orderName!,
                                                subTotal:
                                                    bloc.subtotalTicketAmount,
                                                tax: tax!,
                                                controller: clientController,
                                                clearVariables:
                                                    clearControllers,
                                                paymentTypes: registerStatus
                                                    .paymentTypes!,
                                                isTable: false,
                                                tableCode: null,
                                                businessID:
                                                    userProfile.activeBusiness!,
                                                tablePageController: null,
                                                isSavedOrder: false,
                                                savedOrderID: '',
                                                orderType:
                                                    'Venta Independiente',
                                                onTableView: false,
                                                register: null,
                                              ),
                                            );
                                          });
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 15),
                                    child: Center(
                                      child: Text('Confirmar y volver'),
                                    ),
                                  )),
                            ],
                          ),
                          SizedBox(height: 25),
                        ],
                      ),
                    ),
                    SizedBox(height: 50)
                  ],
                ),
              ),
            );
          });
    } else {
      return StreamBuilder(
          stream: bloc.getStream,
          initialData: bloc.ticketItems,
          builder: (context, AsyncSnapshot snapshot) {
            return SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //Heading
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                                onPressed: () {
                                  if (widget.fromPOS) {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                  } else {
                                    bloc.removeAllFromCart();
                                    Navigator.of(context).pop();
                                  }
                                },
                                icon: Icon(Icons.arrow_back),
                                iconSize: 20.0),
                            SizedBox(width: 10),

                            //Negocio
                            Text(
                              businessName!,
                              style: TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 24),
                            ),
                            Spacer(),
                            Text(
                              DateFormat('dd/MM/yyyy').format(DateTime.now()),
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w300,
                                  fontSize: 16),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        //Invoice and client
                        Container(
                          width: double.infinity,
                          child: TextFormField(
                            style: TextStyle(color: Colors.black, fontSize: 16),
                            cursorColor: Colors.grey,
                            controller: invoiceController,
                            readOnly: true,
                            decoration: InputDecoration(
                              label: Text(
                                'Nro de referencia',
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: Colors.black45),
                              ),
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
                        SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          child: TextFormField(
                            style: TextStyle(color: Colors.black, fontSize: 16),
                            cursorColor: Colors.grey,
                            focusNode: _clientNode,
                            controller: clientController,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              label: Text(
                                'Cliente',
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: Colors.black45),
                              ),
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
                            onFieldSubmitted: (term) {
                              _clientNode.unfocus();
                              // FocusScope.of(context).requestFocus(_tlfNode);
                            },
                            onChanged: (val) {
                              setState(() {
                                clientName = val;
                                clientController.text = val;
                                clientController.selection =
                                    TextSelection.fromPosition(TextPosition(
                                        offset: clientController.text.length));
                                bloc.changeOrderName(val);
                              });
                            },
                          ),
                        ),
                        SizedBox(height: 20),
                        //Date
                        Container(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fecha de venta',
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: Colors.black45),
                              ),
                              SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                padding: EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Text(
                                      DateFormat('dd/MM/yyyy')
                                          .format(selectedIvoiceDate),
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16),
                                    ),
                                    Spacer(),
                                    Container(
                                      height: 20,
                                      width: 20,
                                      child: IconButton(
                                        splashRadius: 1,
                                        onPressed: () async {
                                          DateTime? pickedDate =
                                              await showDatePicker(
                                                  context: context,
                                                  initialDate: DateTime.now(),
                                                  firstDate: DateTime.now()
                                                      .subtract(
                                                          Duration(days: 10)),
                                                  lastDate: DateTime.now(),
                                                  builder: ((context, child) {
                                                    return Theme(
                                                        data: Theme.of(context)
                                                            .copyWith(
                                                          colorScheme:
                                                              ColorScheme.light(
                                                            primary: Colors
                                                                .black, // header background color
                                                            onPrimary: Colors
                                                                .white, // header text color
                                                            onSurface: Colors
                                                                .black, // body text color
                                                          ),
                                                          textButtonTheme:
                                                              TextButtonThemeData(
                                                            style: TextButton
                                                                .styleFrom(
                                                              foregroundColor:
                                                                  Colors
                                                                      .black, // button text color
                                                            ),
                                                          ),
                                                        ),
                                                        child: child!);
                                                  }));
                                          setState(() {
                                            selectedIvoiceDate = pickedDate!;
                                          });
                                        },
                                        padding: EdgeInsets.all(0),
                                        tooltip:
                                            'Seleccionar fecha de la venta',
                                        iconSize: 18,
                                        icon: Icon(Icons.calendar_month),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 25),
                        //Lista de items
                        Text(
                          'Items',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 18),
                        ),
                        SizedBox(height: 20),
                        ListView.builder(
                            key: redrawObject,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data["Items"].length,
                            itemBuilder: (context, i) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 15.0),
                                child: Slidable(
                                  key: const ValueKey(0),
                                  endActionPane: ActionPane(
                                    dismissible:
                                        DismissiblePane(onDismissed: () {
                                      bloc.removeFromCart(
                                          snapshot.data["Items"][i]);

                                      final random = Random();
                                      const availableChars =
                                          'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
                                      final randomString = List.generate(
                                              10,
                                              (index) => availableChars[
                                                  random.nextInt(
                                                      availableChars.length)])
                                          .join();
                                      setState(() {
                                        redrawObject = ValueKey(randomString);
                                      });
                                    }),
                                    motion: ScrollMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: nothing,
                                        backgroundColor: Colors.redAccent,
                                        foregroundColor: Colors.white,
                                        icon: Icons.delete,
                                        label: 'Eliminar',
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    height: 140,
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          new BorderRadius.circular(12.0),
                                      boxShadow: <BoxShadow>[
                                        new BoxShadow(
                                          color: Colors.grey[350]!,
                                          offset: Offset(0.0, 0.0),
                                          blurRadius: 10.0,
                                        )
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        //Product
                                        Container(
                                          width: double.infinity,
                                          height: 50,
                                          child: TextFormField(
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14),
                                            cursorColor: Colors.grey,
                                            textInputAction:
                                                TextInputAction.next,
                                            initialValue: snapshot.data["Items"]
                                                [i]['Name'],
                                            readOnly: true,
                                            decoration: InputDecoration(
                                              label: Text('Descripción'),
                                              labelStyle: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12),
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
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        //Other
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            //Price
                                            Expanded(
                                              flex: 4,
                                              child: TextFormField(
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14),
                                                autofocus: true,
                                                cursorColor: Colors.grey,
                                                textInputAction:
                                                    TextInputAction.next,
                                                inputFormatters: [
                                                  CurrencyTextInputFormatter(
                                                    name: '\$',
                                                    locale: 'en',
                                                    decimalDigits: 2,
                                                  ),
                                                ],
                                                initialValue: (snapshot
                                                                .data["Items"]
                                                            [i]['Price'] >
                                                        0)
                                                    ? '\$${snapshot.data["Items"][i]['Price']}'
                                                    : null,
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                  floatingLabelBehavior:
                                                      FloatingLabelBehavior
                                                          .always,
                                                  hintText: '\$0.00',
                                                  label: Text('Precio'),
                                                  labelStyle: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12),
                                                  errorStyle: TextStyle(
                                                      color:
                                                          Colors.redAccent[700],
                                                      fontSize: 12),
                                                  border:
                                                      new OutlineInputBorder(
                                                    borderRadius:
                                                        new BorderRadius
                                                            .circular(12.0),
                                                    borderSide: new BorderSide(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        new BorderRadius
                                                            .circular(12.0),
                                                    borderSide: new BorderSide(
                                                      color: Colors.green,
                                                    ),
                                                  ),
                                                ),
                                                onFieldSubmitted: (term) {
                                                  // _nameNode.unfocus();
                                                  // FocusScope.of(context).requestFocus(_tlfNode);
                                                },
                                                onChanged: (val) {
                                                  bloc.editPrice(
                                                      i,
                                                      double.tryParse(
                                                          (val.substring(1))));
                                                },
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            //Qty
                                            Expanded(
                                              flex: 2,
                                              child: TextFormField(
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14),
                                                textAlign: TextAlign.center,
                                                autofocus: true,
                                                cursorColor: Colors.grey,
                                                textInputAction:
                                                    TextInputAction.next,
                                                initialValue: snapshot
                                                    .data["Items"][i]
                                                        ['Quantity']
                                                    .toString(),
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                  label: Text('Cantidad'),
                                                  labelStyle: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12),
                                                  errorStyle: TextStyle(
                                                      color:
                                                          Colors.redAccent[700],
                                                      fontSize: 12),
                                                  border:
                                                      new OutlineInputBorder(
                                                    borderRadius:
                                                        new BorderRadius
                                                            .circular(12.0),
                                                    borderSide: new BorderSide(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        new BorderRadius
                                                            .circular(12.0),
                                                    borderSide: new BorderSide(
                                                      color: Colors.green,
                                                    ),
                                                  ),
                                                ),
                                                onFieldSubmitted: (term) {
                                                  // _nameNode.unfocus();
                                                  // FocusScope.of(context).requestFocus(_tlfNode);
                                                },
                                                onChanged: (val) {
                                                  bloc.editQuantity(
                                                      i, int.parse(val));
                                                },
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            //Total
                                            Expanded(
                                              flex: 4,
                                              child: Container(
                                                width: 100,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.grey),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                ),
                                                padding: EdgeInsets.all(12),
                                                child: Text(
                                                  formatCurrency.format(
                                                      snapshot.data["Items"][i]
                                                          ['Total Price']),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),

                        //Boton de Agregar Items (cuadrado con +) => Lleva a seleccionar productos
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () {
                            for (var x = 0; x < 3; x++) {
                              _controllers.add(new TextEditingController());
                            }

                            if (MediaQuery.of(context).size.width > 650) {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return StreamProvider<CategoryList>.value(
                                        initialData: CategoryList(),
                                        value: DatabaseService().categoriesList(
                                            userProfile.activeBusiness),
                                        child: SelectItemDialog(userProfile));
                                  });
                            } else {
                              showModalBottomSheet(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          topRight: Radius.circular(15))),
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (context) {
                                    return StreamProvider<CategoryList>.value(
                                        initialData: CategoryList(),
                                        value: DatabaseService().categoriesList(
                                            userProfile.activeBusiness),
                                        child: SelectItemDialog(userProfile));
                                  });
                            }
                          },
                          child: Container(
                            height: 70,
                            width: 70,
                            child: Center(
                                child: Icon(
                              Icons.add,
                              color: Colors.black87,
                              size: 30,
                            )),
                          ),
                        ),
                        SizedBox(height: 20),
                        //Impuesto + boton para editar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //Text
                            Text(
                              'Subtotal',
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  color: Colors.black),
                            ),
                            Spacer(),
                            //Amount
                            Text(
                              formatCurrency.format(bloc.subtotalTicketAmount),
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 18,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        //Discount
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            //Text
                            Text(
                              (snapshot.data['Discount Code'] == '')
                                  ? 'Descuento'
                                  : 'Descuento ' +
                                      snapshot.data['Discount Code'],
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  color: Colors.black),
                            ),
                            SizedBox(width: 10),
                            IconButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return DiscountDialog(
                                          widget.currentBusiness);
                                    });
                              },
                              icon: Icon(
                                Icons.edit,
                                size: 18,
                              ),
                              splashRadius: 5,
                            ),
                            Spacer(),
                            //Amount
                            Text(
                              formatCurrency.format(snapshot.data['Discount']),
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 18,
                                  color: (snapshot.data['Discount'] > 0)
                                      ? Colors.redAccent
                                      : Colors.black),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        //Total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //Text
                            Text(
                              'TOTAL',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: Colors.black),
                            ),
                            Spacer(),
                            //Amount
                            Text(
                              formatCurrency.format(bloc.totalTicketAmount),
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                        SizedBox(height: 50),
                        //Confirm and close
                        Row(
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.black,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ScheduleSaleDialog(
                                                    widget.currentBusiness,
                                                    bloc.totalTicketAmount,
                                                    discount!,
                                                    tax!,
                                                    bloc.subtotalTicketAmount,
                                                    bloc.ticketItems['Items'],
                                                    clientName,
                                                    clearControllers)));
                                  },
                                  child: Center(
                                    child: Icon(
                                      Icons.calendar_today,
                                      size: 18,
                                    ),
                                  )),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.black),
                                    overlayColor: MaterialStateProperty
                                        .resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                        if (states
                                            .contains(MaterialState.hovered))
                                          return Colors.grey;
                                        if (states.contains(
                                                MaterialState.focused) ||
                                            states.contains(
                                                MaterialState.pressed))
                                          return Colors.grey.shade300;
                                        return Colors.grey
                                            .shade300; // Defer to the widget's default.
                                      },
                                    ),
                                  ),
                                  onPressed: () {
                                    if (bloc.totalTicketAmount <= 0) {
                                    } else {
                                      bloc.changePaymentType('Efectivo');
                                      bloc.changeOrderName(orderName);
                                      bloc.changeOrderType(
                                          'Venta Independiente');
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return MultiProvider(
                                              providers: [
                                                StreamProvider<
                                                        MonthlyStats>.value(
                                                    initialData: MonthlyStats(),
                                                    value: DatabaseService()
                                                        .monthlyStatsfromSnapshot(
                                                            userProfile
                                                                .activeBusiness!)),
                                                StreamProvider<UserData>.value(
                                                    initialData: UserData(),
                                                    value: DatabaseService()
                                                        .userProfile(
                                                            userProfile.uid!)),
                                              ],
                                              child: ConfirmOrder(
                                                total: bloc.totalTicketAmount,
                                                items: snapshot.data["Items"],
                                                discount:
                                                    snapshot.data['Discount'],
                                                discountCode: snapshot
                                                    .data['Discount Code'],
                                                orderDetail:
                                                    snapshot.data["Items"],
                                                orderName: orderName,
                                                subTotal:
                                                    bloc.subtotalTicketAmount,
                                                tax: tax,
                                                controller: clientController,
                                                clearVariables:
                                                    clearControllers,
                                                paymentTypes:
                                                    registerStatus.paymentTypes,
                                                isTable: false,
                                                tableCode: null,
                                                businessID:
                                                    userProfile.activeBusiness,
                                                tablePageController: null,
                                                isSavedOrder: false,
                                                savedOrderID: '',
                                                orderType:
                                                    'Venta Independiente',
                                                onTableView: false,
                                                register: null,
                                              ),
                                            );
                                          });
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 15),
                                    child: Center(
                                      child: Text('Confirmar'),
                                    ),
                                  )),
                            ),
                          ],
                        ),
                        SizedBox(height: 25),
                      ])),
            );
          });
    }
  }
}

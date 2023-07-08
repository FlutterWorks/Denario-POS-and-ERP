import 'dart:ui';

import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Models/Categories.dart';
import 'package:denario/Models/Tables.dart';
import 'package:denario/Models/User.dart';
import 'package:denario/User%20Settings/AddUserDialog.dart';
import 'package:denario/User%20Settings/BusinessScheduleSettings.dart';
import 'package:denario/User%20Settings/FloorPlanConfig.dart';
import 'package:denario/User%20Settings/SocialMediaSettings.dart';
import 'package:denario/User%20Settings/StoreConfig.dart';
import 'package:denario/User%20Settings/UserCard.dart';
import 'package:denario/Wrapper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:universal_html/html.dart' as html;

class UserBusinessSettingsForm extends StatefulWidget {
  final String rol;
  UserBusinessSettingsForm(this.rol);

  @override
  State<UserBusinessSettingsForm> createState() =>
      _UserBusinessSettingsFormState();
}

class _UserBusinessSettingsFormState extends State<UserBusinessSettingsForm> {
  final _formKey = GlobalKey<FormState>();
  final controller = PageController();

  final FocusNode _businessNameNode = FocusNode();
  final FocusNode _businessLocationNode = FocusNode();
  final FocusNode _businessSizeNode = FocusNode();

  String businessName = "";
  List businessFieldList = [
    'Gastronómico', //Vista de Mesas/Mostrador + Botón de venta manual
    'Servicios Profesionales', //Solo boton de venta manual
    'Minorista', //Solo venta de mostrador + boton de venta manual
    'Otro' //Solo boton de venta manual
  ];
  String businessLocation = "";
  int businessSize = 0;
  String businessImage = '';

  Uint8List webImage = Uint8List(8);
  String downloadUrl;
  bool changedImage = false;

  Future getImage() async {
    XFile selectedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (selectedImage != null) {
      Uint8List uploadFile = await selectedImage.readAsBytes();
      setState(() {
        webImage = uploadFile;
        changedImage = true;
      });
    }
  }

  Future uploadPic(businessID) async {
    ////Upload to Clod Storage

    String fileName = 'Business Images/' + businessID + '.png';
    var ref = FirebaseStorage.instance.ref().child(fileName);

    TaskSnapshot uploadTask = await ref.putData(webImage);

    ///Save to Firestore
    if (uploadTask.state == TaskState.success) {
      downloadUrl = await uploadTask.ref.getDownloadURL();
    }
  }

  List socialMedia = [
    {'Social Media': 'Whatsapp', 'Link': '', 'Active': false},
    {'Social Media': 'Instagram', 'Link': '', 'Active': false},
    {'Social Media': 'Google', 'Link': '', 'Active': false},
    {'Social Media': 'Facebook', 'Link': '', 'Active': false},
    {'Social Media': 'Twitter', 'Link': '', 'Active': false}
  ];
  List businessSchedule = [
    {
      'Opens': false,
      'Open': {'Hour': 9, 'Minute': 00},
      'Close': {'Hour': 19, 'Minute': 00},
    },
    {
      'Opens': false,
      'Open': {'Hour': 9, 'Minute': 00},
      'Close': {'Hour': 19, 'Minute': 00},
    },
    {
      'Opens': false,
      'Open': {'Hour': 9, 'Minute': 00},
      'Close': {'Hour': 19, 'Minute': 00},
    },
    {
      'Opens': false,
      'Open': {'Hour': 9, 'Minute': 00},
      'Close': {'Hour': 19, 'Minute': 00},
    },
    {
      'Opens': false,
      'Open': {'Hour': 9, 'Minute': 00},
      'Close': {'Hour': 19, 'Minute': 00},
    },
    {
      'Opens': false,
      'Open': {'Hour': 9, 'Minute': 00},
      'Close': {'Hour': 19, 'Minute': 00},
    },
    {
      'Opens': false,
      'Open': {'Hour': 9, 'Minute': 00},
      'Close': {'Hour': 19, 'Minute': 00},
    },
  ];
  String catalogBackgroundImage = '';

  void changeLink(value, i) {
    socialMedia[i]['Link'] = value;
  }

  void activeRRSS(bool active, i) {
    socialMedia[i]['Active'] = active;
  }

  void businessOpens(bool opens, i) {
    businessSchedule[i]['Opens'] = opens;
  }

  void changeOpenTime(time, i) {
    businessSchedule[i]['Open'] = time;
  }

  void changeCloseTime(time, i) {
    businessSchedule[i]['Close'] = time;
  }

  @override
  Widget build(BuildContext context) {
    final userBusiness = Provider.of<BusinessProfile>(context);
    final businessCategories = Provider.of<CategoryList>(context);

    if (userBusiness == null || businessCategories == null) {
      return Container();
    }

    //Get social media links
    for (var x = 0; x < userBusiness.socialMedia.length; x++) {
      if (userBusiness.socialMedia[x]['Link'] != '') {
        int index = socialMedia.indexWhere((element) =>
            element['Social Media'] ==
            userBusiness.socialMedia[x]['Social Media']);
        socialMedia[index]['Link'] = userBusiness.socialMedia[x]['Link'];
        socialMedia[index]['Active'] = true;
      }
    }

    if (userBusiness.businessSchedule.isNotEmpty) {
      businessSchedule = userBusiness.businessSchedule;
    }

    return PageView(
        controller: controller,
        physics: NeverScrollableScrollPhysics(),
        children: [
          //Business Info
          Container(
            width: double.infinity,
            child: Stack(
              children: [
                ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(scrollbars: false),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          //Fixed Data
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: <BoxShadow>[
                                  new BoxShadow(
                                    color: Colors.grey[350],
                                    offset: new Offset(0, 0),
                                    blurRadius: 10.0,
                                  )
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  //Pic
                                  Container(
                                      height: 70,
                                      width: 70,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                          color: Colors.grey,
                                          image: DecorationImage(
                                              image: (changedImage)
                                                  ? Image.memory(
                                                      webImage,
                                                      fit: BoxFit.cover,
                                                    ).image
                                                  : NetworkImage(userBusiness
                                                      .businessImage),
                                              fit: BoxFit.cover))),
                                  SizedBox(height: 5),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                        foregroundColor: Colors.black),
                                    onPressed: getImage,
                                    child: Container(
                                      height: 35,
                                      width: 60,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 2.0, horizontal: 2),
                                      child: Center(
                                        child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Icon(
                                                Icons.edit,
                                                color: Colors.black,
                                                size: 12,
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                'Editar',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                            ]),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    width: double.infinity,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        //ID
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'ID del Negocio',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                            Text(
                                              '${userBusiness.businessID}',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                        //Rubro
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Rubro del negocio',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                            Text(
                                              '${userBusiness.businessField}',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                        //Mi Rol
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Mi rol en el negocio',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                            Text(
                                              '${widget.rol}',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //Basic Info
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: <BoxShadow>[
                                  new BoxShadow(
                                    color: Colors.grey[350],
                                    offset: new Offset(0, 0),
                                    blurRadius: 10.0,
                                  )
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Información básica',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  //Nombre
                                  TextFormField(
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 14),
                                    validator: (val) =>
                                        val.isEmpty ? "Agrega un nombre" : null,
                                    autofocus: true,
                                    readOnly:
                                        (widget.rol == 'Dueñ@') ? false : true,
                                    cursorColor: Colors.grey,
                                    cursorHeight: 25,
                                    focusNode: _businessNameNode,
                                    initialValue: userBusiness.businessName,
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      label: Text('Nombre del negocio'),
                                      labelStyle: TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                      prefixIcon: Icon(
                                        Icons.store,
                                        color: Colors.grey,
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
                                      _businessNameNode.unfocus();
                                      FocusScope.of(context)
                                          .requestFocus(_businessLocationNode);
                                    },
                                    onChanged: (val) {
                                      setState(() => businessName = val);
                                    },
                                  ),
                                  //Ubicacion
                                  SizedBox(height: 25),
                                  TextFormField(
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 14),
                                    validator: (val) => val.isEmpty
                                        ? "Agrega una ubicación válida"
                                        : null,
                                    readOnly:
                                        (widget.rol == 'Dueñ@') ? false : true,
                                    cursorColor: Colors.grey,
                                    cursorHeight: 25,
                                    focusNode: _businessLocationNode,
                                    initialValue: userBusiness.businessLocation,
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      label: Text('Ubicación'),
                                      labelStyle: TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                      prefixIcon: Icon(
                                        Icons.location_pin,
                                        color: Colors.grey,
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
                                      _businessLocationNode.unfocus();
                                      FocusScope.of(context)
                                          .requestFocus(_businessSizeNode);
                                    },
                                    onChanged: (val) {
                                      setState(() => businessLocation = val);
                                    },
                                  ),
                                  //Size
                                  SizedBox(height: 25),
                                  TextFormField(
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 14),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    validator: (val) => val.isEmpty
                                        ? "Agrega un número válido"
                                        : null,
                                    readOnly:
                                        (widget.rol == 'Dueñ@') ? false : true,
                                    cursorColor: Colors.grey,
                                    cursorHeight: 25,
                                    focusNode: _businessSizeNode,
                                    initialValue:
                                        userBusiness.businessSize.toString(),
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      label: Text(
                                          'Número de personas trabajando en el negocio'),
                                      labelStyle: TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                      prefixIcon: Icon(
                                        Icons.person_outline,
                                        color: Colors.grey,
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
                                      _businessSizeNode.unfocus();
                                    },
                                    onChanged: (val) {
                                      setState(
                                          () => businessSize = int.parse(val));
                                    },
                                  ),
                                  SizedBox(height: 25),
                                ],
                              ),
                            ),
                          ),
                          //Tienda
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: <BoxShadow>[
                                  new BoxShadow(
                                    color: Colors.grey[350],
                                    offset: new Offset(0, 0),
                                    blurRadius: 10.0,
                                  )
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Mi Tienda',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Spacer(),
                                      IconButton(
                                          tooltip:
                                              'Configuraciones de mi tienda',
                                          iconSize: 14,
                                          splashRadius: 15,
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => StoreConfig(
                                                  userBusiness.businessID,
                                                  'http://mi-denario.web.app/?id=${userBusiness.businessID}',
                                                  userBusiness
                                                      .businessBackgroundImage,
                                                  userBusiness
                                                      .visibleStoreCategories,
                                                  businessCategories
                                                      .categoryList),
                                            );
                                          },
                                          icon: Icon(Icons.edit)),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Text(
                                        'http://mi-denario.web.app/?id=${userBusiness.businessID}',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      SizedBox(width: 8),
                                      IconButton(
                                          tooltip: 'Copiar',
                                          iconSize: 14,
                                          splashRadius: 15,
                                          onPressed: () async {
                                            Clipboard.setData(ClipboardData(
                                                    text:
                                                        'http://mi-denario.web.app/?id=${userBusiness.businessID}'))
                                                .then((_) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      content: Text(
                                                          "Link copiado al clipboard")));
                                            });
                                          },
                                          icon: Icon(Icons.copy)),
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      QrImage(
                                        data:
                                            'http://mi-denario.web.app/?id=${userBusiness.businessID}',
                                        version: QrVersions.auto,
                                        size: 100.0,
                                      ),
                                      SizedBox(width: 10),
                                      IconButton(
                                          tooltip: 'Descargar QR',
                                          iconSize: 21,
                                          splashRadius: 15,
                                          onPressed: () async {
                                            final qrCode = QrPainter(
                                              data:
                                                  'http://mi-denario.web.app/?id=${userBusiness.businessID}',
                                              version: QrVersions.auto,
                                            );
                                            final painter = qrCode;
                                            final image = await painter.toImage(
                                                200); // specify the size of the image
                                            final byteData =
                                                await image.toByteData(
                                                    format:
                                                        ImageByteFormat.png);
                                            final bytes =
                                                byteData.buffer.asUint8List();

                                            final blob = html.Blob([bytes]);
                                            final url = html.Url
                                                .createObjectUrlFromBlob(blob);
                                            final anchor = html.document
                                                    .createElement('a')
                                                as html.AnchorElement
                                              ..href = url
                                              ..download =
                                                  '${userBusiness.businessName} QR.png';
                                            anchor.click();
                                            html.document.body.children
                                                .remove(anchor);
                                            html.Url.revokeObjectUrl(url);
                                          },
                                          icon: Icon(Icons.download)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //Tables
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: <BoxShadow>[
                                  new BoxShadow(
                                    color: Colors.grey[350],
                                    offset: new Offset(0, 0),
                                    blurRadius: 10.0,
                                  )
                                ],
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'Configuración del salón',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Spacer(),
                                  IconButton(
                                      tooltip: 'Editar',
                                      iconSize: 14,
                                      splashRadius: 15,
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    StreamProvider<
                                                            List<Tables>>.value(
                                                        initialData: [],
                                                        value: DatabaseService()
                                                            .tableList(
                                                                userBusiness
                                                                    .businessID),
                                                        child: FloorPlanConfig(
                                                            userBusiness
                                                                .businessID))));
                                      },
                                      icon: Icon(Icons.edit)),
                                ],
                              ),
                            ),
                          ),
                          //Social Media
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: <BoxShadow>[
                                  new BoxShadow(
                                    color: Colors.grey[350],
                                    offset: new Offset(0, 0),
                                    blurRadius: 10.0,
                                  )
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Redes Sociales',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  SocialMediaSettings(widget.rol, userBusiness,
                                      changeLink, activeRRSS),
                                ],
                              ),
                            ),
                          ),
                          //Schedule
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: <BoxShadow>[
                                  new BoxShadow(
                                    color: Colors.grey[350],
                                    offset: new Offset(0, 0),
                                    blurRadius: 10.0,
                                  )
                                ],
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Horarios',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(height: 15),
                                  BusinessScheduleSettings(
                                      widget.rol,
                                      businessOpens,
                                      changeCloseTime,
                                      changeOpenTime,
                                      userBusiness),
                                ],
                              ),
                            ),
                          ),
                          //Button
                          SizedBox(height: 45),
                        ],
                      ),
                    ),
                  ),
                ),
                //Button
                (widget.rol == 'Dueñ@')
                    ? Align(
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.grey,
                                  backgroundColor: Colors.black),
                              onPressed: () {
                                if (businessName == '') {
                                  businessName = userBusiness.businessName;
                                }
                                if (businessLocation == '') {
                                  businessLocation =
                                      userBusiness.businessLocation;
                                }
                                if (businessImage == '') {
                                  businessImage = userBusiness.businessName;
                                }
                                if (changedImage) {
                                  uploadPic(userBusiness.businessID).then(
                                      (value) =>
                                          DatabaseService().updateUserBusiness(
                                              userBusiness.businessID,
                                              businessName,
                                              businessLocation,
                                              businessSize,
                                              downloadUrl,
                                              // catalogBackgroundImage,
                                              socialMedia,
                                              businessSchedule));
                                } else {
                                  DatabaseService().updateUserBusiness(
                                      userBusiness.businessID,
                                      businessName,
                                      businessLocation,
                                      businessSize,
                                      userBusiness.businessImage,
                                      // catalogBackgroundImage,
                                      socialMedia,
                                      businessSchedule);
                                }

                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            Wrapper()));
                              },
                              child: Container(
                                width: 100,
                                height: 40,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 2.0, horizontal: 10),
                                child: Center(
                                  child: Text(
                                    'Guardar',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 15),
                            OutlinedButton(
                              style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.grey,
                                  backgroundColor: Colors.white),
                              onPressed: () {
                                controller.nextPage(
                                    duration: Duration(milliseconds: 200),
                                    curve: Curves.easeIn);
                                //Crear usuario (auth + users db)
                                //Eliminar usuario (remover el negocio de su lista), quitar el UID del negocio
                                //Cambiar de rol del usuario
                                // showDialog(
                                //     context: context,
                                //     builder: (context) {
                                //       return ManageUsersDialog(
                                //           userBusiness.businessUsers);
                                //     });
                              },
                              child: Container(
                                width: 150,
                                height: 40,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 2.0, horizontal: 10),
                                child: Center(
                                  child: Text(
                                    'Gestionar Usuarios',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
          //Manage users
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: <BoxShadow>[
                  new BoxShadow(
                    color: Colors.grey[350],
                    offset: new Offset(0, 0),
                    blurRadius: 10.0,
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Intro
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //Back
                      Container(
                        width: 150,
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                            onPressed: () {
                              controller.previousPage(
                                  duration: Duration(milliseconds: 200),
                                  curve: Curves.easeIn);
                            },
                            icon: Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                              size: 18,
                            )),
                      ),
                      Spacer(),
                      Text(
                        'Usuarios',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                      Spacer(),
                      //Button to Add User
                      OutlinedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.transparent,
                        ),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AddUserDialog(userBusiness.businessID,
                                    userBusiness.businessName);
                              });
                        },
                        child: Container(
                          height: 40,
                          width: 150,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              //Icon
                              Icon(Icons.person_add,
                                  size: 16, color: Colors.black),
                              SizedBox(width: 10),
                              //Name
                              Text(
                                'Agregar usuario',
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  //Titles
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      //Pic
                      Container(
                        width: 100,
                        child: Center(
                            child: Text(
                          'Imagen',
                          style: TextStyle(color: Colors.grey),
                        )),
                      ),
                      //Name
                      Container(
                        width: 100,
                        child: Center(
                            child: Text(
                          'Nombre',
                          style: TextStyle(color: Colors.grey),
                        )),
                      ),
                      //EMAIL
                      Container(
                        width: 100,
                        child: Center(
                            child: Text('Teléfono',
                                style: TextStyle(color: Colors.grey))),
                      ),
                      //Rol
                      Container(
                        width: 100,
                        child: Center(
                            child: Text('Rol del usuario',
                                style: TextStyle(color: Colors.grey))),
                      ),
                    ],
                  ),
                  //List
                  Expanded(
                    child: Container(
                      height: 400,
                      width: double.infinity,
                      child: ListView.builder(
                          itemCount: userBusiness.businessUsers.length,
                          itemBuilder: (context, i) {
                            return StreamProvider<UserData>.value(
                                initialData: null,
                                value: DatabaseService()
                                    .userProfile(userBusiness.businessUsers[i]),
                                child: UserCard(userBusiness.businessID));
                          }),
                    ),
                  )
                ],
              ),
            ),
          )
        ]);
  }
}

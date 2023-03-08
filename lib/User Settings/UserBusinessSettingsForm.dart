import 'dart:ui';

import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Models/User.dart';
import 'package:denario/User%20Settings/AddUserDialog.dart';
import 'package:denario/User%20Settings/BusinessScheduleSettings.dart';
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

    if (userBusiness == null) {
      return Container();
    }

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
          Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Fixed Data
                Container(
                  constraints: BoxConstraints(
                      maxHeight: 600,
                      maxWidth: 200,
                      minHeight: 400,
                      minWidth: 200),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      //Pic
                      Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade300),
                              color: Colors.grey,
                              image: DecorationImage(
                                  image: (changedImage)
                                      ? Image.memory(
                                          webImage,
                                          fit: BoxFit.cover,
                                        ).image
                                      : NetworkImage(
                                          userBusiness.businessImage),
                                  fit: BoxFit.cover))),
                      SizedBox(height: 5),
                      TextButton(
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.black),
                        onPressed: getImage,
                        child: Container(
                          height: 35,
                          width: 60,
                          padding: const EdgeInsets.symmetric(
                              vertical: 2.0, horizontal: 2),
                          child: Center(
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
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
                                        fontWeight: FontWeight.w400),
                                  ),
                                ]),
                          ),
                        ),
                      ),
                      //ID
                      SizedBox(height: 15),
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
                      //Rubro
                      SizedBox(height: 25),
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
                      //Mi Rol
                      SizedBox(height: 25),
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
                ),
                //Form
                Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context)
                        .copyWith(scrollbars: false),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height: 5),
                            //Nombre
                            TextFormField(
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14),
                              validator: (val) =>
                                  val.isEmpty ? "Agrega un nombre" : null,
                              autofocus: true,
                              readOnly: (widget.rol == 'Dueñ@') ? false : true,
                              cursorColor: Colors.grey,
                              cursorHeight: 25,
                              focusNode: _businessNameNode,
                              initialValue: userBusiness.businessName,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                label: Text('Nombre del negocio'),
                                labelStyle:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                                prefixIcon: Icon(
                                  Icons.store,
                                  color: Colors.grey,
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
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14),
                              validator: (val) => val.isEmpty
                                  ? "Agrega una ubicación válida"
                                  : null,
                              readOnly: (widget.rol == 'Dueñ@') ? false : true,
                              cursorColor: Colors.grey,
                              cursorHeight: 25,
                              focusNode: _businessLocationNode,
                              initialValue: userBusiness.businessLocation,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                label: Text('Ubicación'),
                                labelStyle:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                                prefixIcon: Icon(
                                  Icons.location_pin,
                                  color: Colors.grey,
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
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              validator: (val) => val.isEmpty
                                  ? "Agrega un número válido"
                                  : null,
                              readOnly: (widget.rol == 'Dueñ@') ? false : true,
                              cursorColor: Colors.grey,
                              cursorHeight: 25,
                              focusNode: _businessSizeNode,
                              initialValue:
                                  userBusiness.businessSize.toString(),
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                label: Text(
                                    'Número de personas trabajando en el negocio'),
                                labelStyle:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  color: Colors.grey,
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
                                _businessSizeNode.unfocus();
                              },
                              onChanged: (val) {
                                setState(() => businessSize = int.parse(val));
                              },
                            ),
                            SizedBox(height: 25),
                            //Tienda
                            Row(
                              children: [
                                Text(
                                  'Mi Tienda',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600),
                                ),
                                SizedBox(width: 8),
                                IconButton(
                                    tooltip: 'Configuraciones de mi tienda',
                                    iconSize: 14,
                                    splashRadius: 15,
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) => StoreConfig(
                                              'http://mi-denario.web.app/?id=${userBusiness.businessID}'));
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
                                      final byteData = await image.toByteData(
                                          format: ImageByteFormat.png);
                                      final bytes =
                                          byteData.buffer.asUint8List();

                                      final blob = html.Blob([bytes]);
                                      final url =
                                          html.Url.createObjectUrlFromBlob(
                                              blob);
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
                            //Imagen de fondo

                            //Categorias

                            //Social Media
                            SizedBox(height: 25),
                            Text(
                              'Redes Sociales',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 15),
                            SocialMediaSettings(widget.rol, userBusiness,
                                changeLink, activeRRSS),
                            //Schedule
                            SizedBox(height: 25),
                            Text(
                              'Horarios',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 15),
                            BusinessScheduleSettings(widget.rol, businessOpens,
                                changeCloseTime, changeOpenTime, userBusiness),
                            //Button
                            SizedBox(height: 35),
                            (widget.rol == 'Dueñ@')
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.grey,
                                            backgroundColor: Colors.black),
                                        onPressed: () {
                                          if (businessName == '') {
                                            businessName =
                                                userBusiness.businessName;
                                          }
                                          if (businessLocation == '') {
                                            businessLocation =
                                                userBusiness.businessLocation;
                                          }
                                          if (businessImage == '') {
                                            businessImage =
                                                userBusiness.businessName;
                                          }
                                          if (changedImage) {
                                            uploadPic(userBusiness.businessID)
                                                .then((value) => DatabaseService()
                                                    .updateUserBusiness(
                                                        userBusiness.businessID,
                                                        businessName,
                                                        businessLocation,
                                                        businessSize,
                                                        downloadUrl,
                                                        // catalogBackgroundImage,
                                                        socialMedia,
                                                        businessSchedule));
                                          } else {
                                            DatabaseService()
                                                .updateUserBusiness(
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
                                                  builder:
                                                      (BuildContext context) =>
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
                                            foregroundColor: Colors.grey),
                                        onPressed: () {
                                          controller.nextPage(
                                              duration:
                                                  Duration(milliseconds: 200),
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
                                  )
                                : Container(),
                            SizedBox(height: 25),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                //Manage users and save
              ]),
          //Manage users
          Container(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Titles
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    //Pic
                    IconButton(
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
                    SizedBox(width: 10),
                    //Name
                    Container(
                      width: 200,
                      child: Center(
                          child: Text(
                        'Nombre',
                        style: TextStyle(color: Colors.grey),
                      )),
                    ),
                    SizedBox(width: 10),
                    //EMAIL
                    Container(
                      width: 200,
                      child: Center(
                          child: Text('Teléfono',
                              style: TextStyle(color: Colors.grey))),
                    ),
                    SizedBox(width: 10),
                    //Rol
                    Container(
                      width: 200,
                      child: Center(
                          child: Text('Rol del usuario',
                              style: TextStyle(color: Colors.grey))),
                    ),
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
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            //Icon
                            Icon(Icons.person_add,
                                size: 16, color: Colors.black),
                            SizedBox(width: 10),
                            //Name
                            Text(
                              'Agregar nuevo usuario',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    )
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
          )
        ]);
  }
}

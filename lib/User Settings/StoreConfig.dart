import 'package:denario/Backend/DatabaseService.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class StoreConfig extends StatefulWidget {
  final String businessID;
  final String storeLink;
  final String backgroundImage;
  final List visibleStoreCategories;
  final List businessCategories;
  const StoreConfig(this.businessID, this.storeLink, this.backgroundImage,
      this.visibleStoreCategories, this.businessCategories,
      {Key? key})
      : super(key: key);

  @override
  State<StoreConfig> createState() => _StoreConfigState();
}

class _StoreConfigState extends State<StoreConfig> {
  late List initialCategories;
  List selectedCategories = [];

  Uint8List webImage = Uint8List(8);
  String? downloadUrl;
  bool changedImage = false;

  Future getImage() async {
    XFile? selectedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    Uint8List uploadFile = await selectedImage!.readAsBytes();
    setState(() {
      webImage = uploadFile;
      changedImage = true;
    });
  }

  Future uploadPic(businessID) async {
    ////Upload to Clod Storage

    String fileName = 'Business Images/' + businessID + ' Store Background.png';
    var ref = FirebaseStorage.instance.ref().child(fileName);

    TaskSnapshot uploadTask = await ref.putData(webImage);

    ///Save to Firestore
    if (uploadTask.state == TaskState.success) {
      downloadUrl = await uploadTask.ref.getDownloadURL();
    }
  }

  bool isHovered = false;

  @override
  void initState() {
    initialCategories = List.from(widget.visibleStoreCategories);

    if (widget.visibleStoreCategories.contains('All')) {
      selectedCategories = List.from(widget.businessCategories);
    } else {
      selectedCategories = List.from(widget.visibleStoreCategories);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Container(
        height: 500,
        width: (MediaQuery.of(context).size.width > 900)
            ? MediaQuery.of(context).size.width * 0.5
            : MediaQuery.of(context).size.width * 0.8,
        padding: EdgeInsets.all(20),
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                //Title and close
                Container(
                  width: double.infinity,
                  child: Row(
                    children: [
                      //Title
                      Container(
                        width: 200,
                        child: Text(
                          'Mi tienda',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      Spacer(),
                      //Close
                      Container(
                        width: 50,
                        child: IconButton(
                            splashRadius: 15,
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close),
                            iconSize: 20.0),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                //Link
                Row(
                  children: [
                    Text(
                      widget.storeLink,
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
                          Clipboard.setData(
                                  ClipboardData(text: widget.storeLink))
                              .then((_) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("Link copiado al clipboard")));
                          });
                        },
                        icon: Icon(Icons.copy)),
                  ],
                ),
                SizedBox(height: 20),
                //Image
                Row(
                  children: [
                    Text(
                      'Imagen de fondo',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w600),
                    ),
                    Spacer(),
                  ],
                ),
                SizedBox(height: 12),
                MouseRegion(
                  onEnter: (event) => setState(() => isHovered = true),
                  onExit: (event) => setState(() => isHovered = false),
                  child: InkWell(
                    onTap: getImage,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                            height: 250,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                image: DecorationImage(
                                    colorFilter: isHovered
                                        ? ColorFilter.mode(
                                            Colors.black.withOpacity(0.5),
                                            BlendMode.dstATop,
                                          )
                                        : null,
                                    image: (changedImage)
                                        ? Image.memory(
                                            webImage,
                                            fit: BoxFit.cover,
                                          ).image
                                        : NetworkImage(widget.backgroundImage),
                                    fit: BoxFit.cover))),
                        if (isHovered)
                          Icon(
                            Icons.edit,
                            color: Colors.black,
                            size: 35, // Adjust the size of the icon as needed
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                //Categories
                Text(
                  'Categorías visibles',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(width: 12),
                ListView.builder(
                    itemCount: widget.businessCategories.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: ((context, i) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  if (selectedCategories
                                      .contains(widget.businessCategories[i])) {
                                    setState(() {
                                      selectedCategories
                                          .remove(widget.businessCategories[i]);
                                    });
                                  } else {
                                    setState(() {
                                      selectedCategories
                                          .add(widget.businessCategories[i]);
                                    });
                                  }
                                },
                                icon: (selectedCategories
                                        .contains(widget.businessCategories[i]))
                                    ? Icon(
                                        Icons.check_box,
                                        color: Colors.greenAccent[400],
                                      )
                                    : const Icon(
                                        Icons.check_box_outline_blank)),
                            const SizedBox(width: 10),
                            Text(
                              widget.businessCategories[i],
                              style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14,
                                  color: Colors.black),
                            )
                          ],
                        ),
                      );
                    })),
                SizedBox(height: 20),
                //Buttom
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      backgroundColor: Colors.black),
                  onPressed: () {
                    if (changedImage) {
                      uploadPic(widget.businessID).then((value) =>
                          DatabaseService().updateBusinessStoreConfig(
                            widget.businessID,
                            downloadUrl!,
                            selectedCategories,
                          ));
                    } else {
                      DatabaseService().updateBusinessStoreConfig(
                          widget.businessID,
                          widget.backgroundImage,
                          selectedCategories);
                    }

                    Navigator.of(context).pop();
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

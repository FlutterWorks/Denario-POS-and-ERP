import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StoreConfig extends StatefulWidget {
  final String storeLink;
  const StoreConfig(this.storeLink, {Key key}) : super(key: key);

  @override
  State<StoreConfig> createState() => _StoreConfigState();
}

class _StoreConfigState extends State<StoreConfig> {
  List categories = ['Pan', 'Cafe', 'Póstres', 'Bebidas'];
  List selectedCategories = [];
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Container(
        height: 500,
        width: MediaQuery.of(context).size.width * 0.5,
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
                Text(
                  'Imagen de fondo',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 12),
                Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.blue,
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
                    itemCount: categories.length,
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
                                      .contains(categories[i])) {
                                    setState(() {
                                      selectedCategories.remove(categories[i]);
                                    });
                                  } else {
                                    setState(() {
                                      selectedCategories.add(categories[i]);
                                    });
                                  }
                                },
                                icon:
                                    (selectedCategories.contains(categories[i]))
                                        ? Icon(
                                            Icons.check_box,
                                            color: Colors.greenAccent[400],
                                          )
                                        : const Icon(
                                            Icons.check_box_outline_blank)),
                            const SizedBox(width: 10),
                            Text(
                              categories[i],
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
                  onPressed: () {},
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

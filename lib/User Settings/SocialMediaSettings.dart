import 'package:denario/Models/User.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';

class SocialMediaSettings extends StatefulWidget {
  final String rol;
  final BusinessProfile userBusiness;
  final changeLink;
  final activeRRSS;
  const SocialMediaSettings(
      this.rol, this.userBusiness, this.changeLink, this.activeRRSS,
      {Key? key})
      : super(key: key);

  @override
  State<SocialMediaSettings> createState() => _SocialMediaSettingsState();
}

class _SocialMediaSettingsState extends State<SocialMediaSettings> {
  List socialMedia = [
    {'Social Media': 'Whatsapp', 'Link': '', 'Active': false},
    {'Social Media': 'Instagram', 'Link': '', 'Active': false},
    {'Social Media': 'Google', 'Link': '', 'Active': false},
    {'Social Media': 'Facebook', 'Link': '', 'Active': false},
    {'Social Media': 'Twitter', 'Link': '', 'Active': false}
  ];

  final countryPicker = FlCountryCodePicker(
    searchBarDecoration: InputDecoration(
      hintText: 'Busca por país o código',
      suffixIcon: Icon(
        Icons.search,
        color: Colors.grey,
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
    title: Padding(
      padding: EdgeInsets.all(20.0),
      child: Text(
        'Elige tu país',
        style: TextStyle(
            color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
      ),
    ),
  );

  CountryCode countryCode =
      CountryCode(name: 'Argentina', code: 'AR', dialCode: '+54');
  bool editPhoneNumber = true;

  @override
  void initState() {
    for (var x = 0; x < widget.userBusiness.socialMedia!.length; x++) {
      if (widget.userBusiness.socialMedia![x]['Link'] != '') {
        int index = socialMedia.indexWhere((element) =>
            element['Social Media'] ==
            widget.userBusiness.socialMedia![x]['Social Media']);
        socialMedia[index]['Link'] =
            widget.userBusiness.socialMedia![x]['Link'];
        socialMedia[index]['Active'] = true;
      }
    }

    //If whatsapp is used, editPhoneNumber = false
    try {
      var whatsappIndex = widget.userBusiness.socialMedia!
          .indexWhere((element) => element['Social Media'] == 'Whatsapp');

      if (widget.userBusiness.socialMedia![whatsappIndex]['Link'] != null &&
          widget.userBusiness.socialMedia![whatsappIndex]['Link'] != '') {
        editPhoneNumber = false;
      }
    } catch (e) {
      //
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: socialMedia.length,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, i) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Name/Active
              Row(
                children: [
                  Container(
                    width: 75,
                    child: Text(
                      socialMedia[i]['Social Media'],
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ),
                  SizedBox(width: 10),
                  Switch(
                    value: socialMedia[i]['Active'],
                    onChanged: (value) {
                      if (value == false) {
                        setState(() {
                          widget.activeRRSS(value, i);
                          widget.changeLink('', i);
                          socialMedia[i]['Active'] = value;
                          socialMedia[i]['Link'] = '';
                        });
                      } else {
                        setState(() {
                          widget.activeRRSS(value, i);
                          socialMedia[i]['Active'] = value;
                        });
                      }
                    },
                    activeTrackColor: Colors.lightGreenAccent,
                    activeColor: Colors.green,
                  ),
                ],
              ),
              SizedBox(height: 5),
              //Link (if active)
              (socialMedia[i]['Active'])
                  ? (socialMedia[i]['Social Media'] == 'Whatsapp')
                      ? (socialMedia[i]['Link'] != '' &&
                              editPhoneNumber == false)
                          ? TextButton(
                              onPressed: () {
                                setState(() {
                                  widget.changeLink('', i);
                                  socialMedia[i]['Link'] = '';
                                  editPhoneNumber = true;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    //Phone
                                    Text(
                                      socialMedia[i]['Link'],
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16),
                                    ),
                                    SizedBox(width: 10),
                                    //Edit Icon
                                    Icon(
                                      Icons.edit,
                                      color: Colors.black,
                                      size: 16,
                                    )
                                  ],
                                ),
                              ),
                            )
                          : TextFormField(
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14),
                              validator: (val) => val!.isEmpty
                                  ? "Agrega un link válido"
                                  : val.length < 6
                                      ? 'El número debe tener al menos 6 caracteres'
                                      : null,
                              autofocus: true,
                              readOnly: (widget.rol == 'Dueñ@') ? false : true,
                              cursorColor: Colors.grey,
                              cursorHeight: 25,
                              initialValue: socialMedia[i]['Link'],
                              keyboardType: TextInputType.number,
                              maxLength: 12,
                              maxLines: 1,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: GestureDetector(
                                    onTap: () async {
                                      // Show the country code picker when tapped.
                                      final code =
                                          await countryPicker.showPicker(
                                              initialSelectedLocale: 'AR',
                                              context: context);
                                      setState(() {
                                        countryCode = code!;
                                      });
                                      // Null check
                                      if (code != null) print(code.code);
                                    },
                                    child: Container(
                                      width: 50,
                                      child: Row(
                                        children: [
                                          // //Flag
                                          // Container(
                                          //     child: countryCode !=
                                          //             null
                                          //         ? countryCode
                                          //             .flagImage(
                                          //                 fit:
                                          //                     BoxFit.cover)
                                          //         : null),
                                          // SizedBox(width: 10),
                                          //Code
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0, vertical: 4.0),
                                            decoration: const BoxDecoration(
                                                color: Colors.black,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8.0))),
                                            child: Text(countryCode.dialCode,
                                                style: const TextStyle(
                                                    color: Colors.white)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
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
                              onChanged: (val) {
                                setState(() {
                                  widget.changeLink(
                                      countryCode.dialCode + val.trim(), i);
                                  socialMedia[i]['Link'] =
                                      countryCode.dialCode + val.trim();
                                });
                              },
                            )
                      : TextFormField(
                          style: TextStyle(color: Colors.black, fontSize: 14),
                          validator: (val) =>
                              val!.isEmpty ? "Agrega un link válido" : null,
                          autofocus: true,
                          readOnly: (widget.rol == 'Dueñ@') ? false : true,
                          cursorColor: Colors.grey,
                          cursorHeight: 25,
                          initialValue: socialMedia[i]['Link'],
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            label: Text('Link'),
                            labelStyle:
                                TextStyle(color: Colors.grey, fontSize: 12),
                            prefixIcon: Icon(
                              Icons.link,
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
                          onChanged: (val) {
                            setState(() {
                              socialMedia[i]['Link'] = val;
                              widget.changeLink(val, i);
                            });
                          },
                        )
                  : SizedBox(),
              SizedBox(height: 10),
            ],
          );
        });
  }
}

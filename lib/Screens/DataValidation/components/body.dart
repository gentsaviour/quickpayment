import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mandate_storeapp/Screens/Signup/components/background.dart';
import 'package:mandate_storeapp/components/rounded_button.dart';
import 'package:mandate_storeapp/components/text_field_container.dart';
import 'package:mandate_storeapp/constants.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mandate_storeapp/mainpage.dart';
import 'package:mandate_storeapp/utils.dart';
import 'package:path/path.dart';

class Body extends StatefulWidget {
  int userId;
  int investorId;

  Body({@required this.userId, @required this.investorId});

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final controllerPhoneNo = TextEditingController();
  final controllerAddress = TextEditingController();

  File _identificationImage;
  File _passportImage;
  final identificationPicker = ImagePicker();
  final passsportPicker = ImagePicker();
  final sharedPref = SharedPref();

  Future choiceIdentificationImage() async {
    var pickedImage =
        await identificationPicker.getImage(source: ImageSource.gallery);
    setState(() {
      _identificationImage = File(pickedImage.path);
    });
  }

  Future choicePassportImage() async {
    var pickedImage =
        await passsportPicker.getImage(source: ImageSource.gallery);
    setState(() {
      _passportImage = File(pickedImage.path);
    });
  }

  Future<void> validateData(BuildContext context) async {
    final url = Uri.http(
        "www.mandatestore.ng", '/api/investorupdate/${widget.investorId}');
    final request = http.MultipartRequest('PATCH', url);
    var token = await sharedPref.getString('token');
    print(token);
    Map<String, String> headers = {
      "Content-type": "multipart/form-data",
      HttpHeaders.authorizationHeader: 'Token $token',
    };
    request.files.add(
      http.MultipartFile(
        'Indentification',
        _identificationImage.readAsBytes().asStream(),
        _identificationImage.lengthSync(),
        filename: basename(_identificationImage.path),
        contentType: MediaType('image', 'jpeg'),
      ),
    );
    request.files.add(
      http.MultipartFile(
        'passport',
        _passportImage.readAsBytes().asStream(),
        _passportImage.lengthSync(),
        filename: basename(_passportImage.path),
        contentType: MediaType('image', 'jpeg'),
      ),
    );
    request.headers.addAll(headers);
    request.fields.addAll({
      'phonenumber': controllerPhoneNo.text,
      'address': controllerAddress.text,
    });
    print('request' + request.toString());
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    print('response' + response.reasonPhrase);
    print('statuscode${response.statusCode}');
    print('response' + response.body.toString());
    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: "Validation Successfull",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      controllerPhoneNo.clear();
      controllerAddress.clear();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MainPage(),
        ),
      );
    } else {
      Fluttertoast.showToast(
          msg: "Invalid Username or Password",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(top: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "DATA VERIFICATION",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            // SizedBox(height: size.height * 0.03),
            Icon(Icons.check_circle, color: Colors.green, size: 96),
            // SvgPicture.asset(
            //   "assets/icons/signup.svg",
            //   height: size.height * 0.35,
            // ),
            TextFieldContainer(
              child: TextField(
                obscureText: false,
                cursorColor: kPrimaryColor,
                controller: controllerPhoneNo,
                decoration: InputDecoration(
                  hintText: "Phone Number",
                  icon: Icon(
                    Icons.phone,
                    color: kPrimaryColor,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            TextFieldContainer(
              child: TextField(
                obscureText: false,
                cursorColor: kPrimaryColor,
                controller: controllerAddress,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Address",
                  icon: Icon(
                    Icons.location_on,
                    color: kPrimaryColor,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          "Upload Means of Identification",
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8.0),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              choiceIdentificationImage();
                            },
                            child: _identificationImage == null
                                ? Icon(Icons.image,
                                    size: 64, color: Colors.grey)
                                : Image.file(
                                    _identificationImage,
                                    height: 100,
                                    width: 100,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text("Upload Passport"),
                        SizedBox(height: 8.0),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              choicePassportImage();
                            },
                            child: _passportImage == null
                                ? Icon(Icons.image,
                                    size: 64, color: Colors.grey)
                                : Image.file(
                                    _passportImage,
                                    height: 100,
                                    width: 100,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 16.0),
            RoundedButton(
              text: "VALIDATE",
              press: () {
                if (controllerPhoneNo.text.isEmpty) {
                  Fluttertoast.showToast(
                    msg: "Phone Number is Required",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                } else if (controllerAddress.text.isEmpty) {
                  Fluttertoast.showToast(
                    msg: "Address is Required",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                } else if (_passportImage == null) {
                  Fluttertoast.showToast(
                      msg: "Passport Image is Required",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                } else if (_identificationImage == null) {
                  Fluttertoast.showToast(
                      msg: "Identification Image is Required",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                } else {
                  validateData(context);
                }
              },
            ),
            SizedBox(height: size.height * 0.03),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mandate_storeapp/Screens/DataValidation/data_validation_screen.dart';
import 'package:mandate_storeapp/Screens/Login/login_screen.dart';
import 'package:mandate_storeapp/Screens/DataValidation/components/background.dart';
import 'package:mandate_storeapp/Screens/DataValidation/components/or_divider.dart';
import 'package:mandate_storeapp/Screens/DataValidation/components/social_icon.dart';
import 'package:mandate_storeapp/components/already_have_an_account_acheck.dart';
import 'package:mandate_storeapp/components/rounded_button.dart';
import 'package:mandate_storeapp/components/text_field_container.dart';
import 'package:mandate_storeapp/constants.dart';
import 'package:http/http.dart' as http;
import 'package:mandate_storeapp/utils.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final controllerFirstName = TextEditingController();
  final controllerLastName = TextEditingController();
  final controllerEmail = TextEditingController();
  final controllerUserName = TextEditingController();
  final controllerPassword = TextEditingController();
  final controllerCPassword = TextEditingController();
final sharedPref = SharedPref();

  Future<void> Register() async {
    final url = Uri.http("www.mandatestore.ng", '/api/investorregister/');
    final response = await http.post(
      url,
      body: jsonEncode(
        {
          "username": controllerUserName.text,
          "password": controllerPassword.text,
          "email": controllerEmail.text,
          "first_name": controllerFirstName.text,
          "last_name": controllerLastName.text,
        },
      ),
      headers: Utils.configHeader(),
    );
    var datauser = json.decode(response.body.toString());
    print(datauser);
    print(response.statusCode);
    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: "Registration Successful",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      controllerFirstName.clear();
      controllerLastName.clear();
      controllerEmail.clear();
      controllerUserName.clear();
      controllerPassword.clear();
      controllerCPassword.clear();
      await sharedPref.setString('token', datauser['token']);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DataValidationScreen(
            userId: datauser['user']['id'],
            investorId: datauser['investor_id'],
          ),
        ),
      );
    } else {
      Fluttertoast.showToast(
          msg: "Invalid data supplied",
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "SIGNUP",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: size.height * 0.03),
            SvgPicture.asset(
              "assets/icons/signup.svg",
              height: size.height * 0.35,
            ),
            TextFieldContainer(
              child: TextField(
                obscureText: false,
                cursorColor: kPrimaryColor,
                controller: controllerFirstName,
                decoration: InputDecoration(
                  hintText: "FirstName",
                  icon: Icon(
                    Icons.person,
                    color: kPrimaryColor,
                  ),
                  // suffixIcon: Icon(
                  //   Icons.visibility,
                  //   color: kPrimaryColor,
                  // ),
                  border: InputBorder.none,
                ),
              ),
            ),
            TextFieldContainer(
              child: TextField(
                obscureText: false,
                cursorColor: kPrimaryColor,
                controller: controllerLastName,
                decoration: InputDecoration(
                  hintText: "LastName",
                  icon: Icon(
                    Icons.person,
                    color: kPrimaryColor,
                  ),
                  // suffixIcon: Icon(
                  //   Icons.visibility,
                  //   color: kPrimaryColor,
                  // ),
                  border: InputBorder.none,
                ),
              ),
            ),
            TextFieldContainer(
              child: TextField(
                obscureText: false,
                cursorColor: kPrimaryColor,
                controller: controllerEmail,
                decoration: InputDecoration(
                  hintText: "Email",
                  icon: Icon(
                    Icons.person,
                    color: kPrimaryColor,
                  ),
                  // suffixIcon: Icon(
                  //   Icons.visibility,
                  //   color: kPrimaryColor,
                  // ),
                  border: InputBorder.none,
                ),
              ),
            ),
            TextFieldContainer(
              child: TextField(
                obscureText: false,
                cursorColor: kPrimaryColor,
                controller: controllerUserName,
                decoration: InputDecoration(
                  hintText: "UserName",
                  icon: Icon(
                    Icons.person,
                    color: kPrimaryColor,
                  ),
                  // suffixIcon: Icon(
                  //   Icons.visibility,
                  //   color: kPrimaryColor,
                  // ),
                  border: InputBorder.none,
                ),
              ),
            ),
            TextFieldContainer(
              child: TextField(
                obscureText: true,
                cursorColor: kPrimaryColor,
                controller: controllerPassword,
                decoration: InputDecoration(
                  hintText: "Password",
                  icon: Icon(
                    Icons.lock,
                    color: kPrimaryColor,
                  ),
                  suffixIcon: Icon(
                    Icons.visibility,
                    color: kPrimaryColor,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            TextFieldContainer(
              child: TextField(
                obscureText: true,
                cursorColor: kPrimaryColor,
                controller: controllerCPassword,
                decoration: InputDecoration(
                  hintText: "Confirm Password",
                  icon: Icon(
                    Icons.lock,
                    color: kPrimaryColor,
                  ),
                  suffixIcon: Icon(
                    Icons.visibility,
                    color: kPrimaryColor,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            RoundedButton(
              text: "SIGNUP",
              press: () {
                if (controllerFirstName.text.isEmpty) {
                  Fluttertoast.showToast(
                      msg: "FullName is Required",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                } else if (controllerLastName.text.isEmpty) {
                  Fluttertoast.showToast(
                      msg: "Last Name is Required",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                } else if (controllerEmail.text.isEmpty) {
                  Fluttertoast.showToast(
                      msg: "Email Address is Required",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                } else if (controllerPassword.text.isEmpty) {
                  Fluttertoast.showToast(
                      msg: "Password is Required",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                } else if (controllerCPassword.text.isEmpty) {
                  Fluttertoast.showToast(
                      msg: "Confirm Password is Required",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                } else if (controllerCPassword.text !=
                    controllerPassword.text) {
                  Fluttertoast.showToast(
                      msg: "Password Not Match",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                } else {
                  Register();
                }
              },
            ),
            SizedBox(height: size.height * 0.03),
            AlreadyHaveAnAccountCheck(
              login: false,
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return LoginScreen();
                    },
                  ),
                );
              },
            ),
            OrDivider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SocalIcon(
                  iconSrc: "assets/icons/facebook.svg",
                  press: () {},
                ),
                SocalIcon(
                  iconSrc: "assets/icons/twitter.svg",
                  press: () {},
                ),
                SocalIcon(
                  iconSrc: "assets/icons/google-plus.svg",
                  press: () {},
                ),
              ],
            ),
            SizedBox(
              height: 50.0,
            ),
          ],
        ),
      ),
    );
  }
}

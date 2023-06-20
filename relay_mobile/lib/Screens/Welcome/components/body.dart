import 'package:flutter/material.dart';
import 'package:relay_mobile/Screens/Login/login_screen.dart';
import 'package:relay_mobile/components/background.dart';
import 'package:relay_mobile/constants.dart';

import '../../../components/rounded_button.dart';
// import '../../Signup/components/agent_signup_form.dart';
import '../../Signup/signup_screen.dart';
// import 'background.dart';

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
           
            SizedBox(
              height: size.height * 0.03,
            ),
             const Text(
              "WELCOME TO THE RELAY ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: size.height * 0.05,
            ),
            RoundedButton(
              text: "LOGIN",
              press: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const LoginScreen();
                }));
              },
            ),
            // RoundedButton(
            //   text: "Sign Up as Client",
            //   color: kPrimaryLightColor,
            //   textColor: Colors.black,
            //   press: () {
            //     Navigator.push(context, MaterialPageRoute(builder: (context) {
            //       return const SignUpScreen();
            //     }));
            //   },
            // ),
            RoundedButton(
              text: "Sign Up as Agent",
              color: kPrimaryColor,
              textColor: Colors.white,
              press: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const SignUpScreen();
                }));
              },
            ),
          ],
        ),
      ),
    );
  }
}

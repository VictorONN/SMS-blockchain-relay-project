import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:relay_mobile/Screens/Dashboard/dashboard_screen.dart';
import 'package:relay_mobile/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import '../../../components/already_have_an_account_acheck.dart';
import '../../../components/rounded_button.dart';
import '../../../constants.dart';
import '../../../services/apis.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            onSaved: (phone) {},
            validator: (value) {
            
              String pattern =
                  r'^254\d{9}$';
              RegExp regex = RegExp(pattern);
              if (value == null || value.isEmpty || !regex.hasMatch(value)) {
                return 'Phone Number should start with 254';
              } else {
                return null;
              }
            },
            controller: _phoneController,
            decoration: const InputDecoration(
              hintText: "Enter Phone Number",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.phone),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: TextFormField(
              textInputAction: TextInputAction.done,
              obscureText: true,
              cursorColor: kPrimaryColor,
              validator: (value) {
                if (value!.isEmpty) {
                  return "* Required";
                } else if (value.length < 6) {
                  return "Password should be atleast 6 characters";
                } else {
                  return null;
                }
              },
              controller: _passwordController,
              decoration: const InputDecoration(
                hintText: "Enter Password",
                prefixIcon: Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.lock),
                ),
              ),
            ),
          ),
          const SizedBox(height: 15.0),
          Container(
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 20),
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Work in progress')));
                // Navigator.push(
                //   context,
                //   SwipeablePageRoute(builder: (context) => const Dashboard()),
                // );
              },
              child: const Text(
                "Forgot your password?",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          Hero(
            tag: "login_btn",
            child: ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(kPrimaryColor)),
              // style: ThemeHelper().buttonStyle(),
              // onPressed: _loginPressed,
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _loginPressed();
                } else {
                  print("Not Validated");
                }
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                child: Text(
                  'Log In'.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          AlreadyHaveAnAccountCheck(
            press: () {
             
            },
          ),
        ],
      ),
    );
  }

  Future<void> _loginPressed() async {
    //Here we will write the code to validate user login credentials
    //If the credentials are valid then we will navigate to profile page
    //If the credentials are invalid then we will show error message
    context.loaderOverlay.show();

    var phone = _phoneController.text.toLowerCase().trim();
    var password = _passwordController.text;

    // save details in shared preference
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await ApiService().login(phone, password).then((value) {
      if (value != null) {
        prefs.setString('access', value.data.token);
        prefs.setInt('user_id', value.data.id);
        prefs.setString('phone_number', value.data.phoneNumber);
        prefs.setString('wallet_account', value.data.walletAccount);
        prefs.setInt('deposit_rate', value.data.depositRate);
        prefs.setInt('withdraw_rate', value.data.withdrawRate);
        

        Flushbar(
          titleColor: Colors.white,
          flushbarPosition: FlushbarPosition.TOP,
          flushbarStyle: FlushbarStyle.FLOATING,
          reverseAnimationCurve: Curves.decelerate,
          forwardAnimationCurve: Curves.elasticOut,
          backgroundColor: const Color.fromARGB(255, 43, 160, 47),
          isDismissible: false,
          duration: const Duration(seconds: 4),
          icon: const Icon(
            Icons.check,
            color: Colors.white,
          ),
          showProgressIndicator: true,
          progressIndicatorBackgroundColor: Colors.blueGrey,
          titleText: const Text(
            "Success",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: Colors.white,
                fontFamily: "ShadowsIntoLightTwo"),
          ),
          messageText: const Text(
            "Login succesful!",
            style: TextStyle(
                fontSize: 18.0,
                color: Colors.white,
                fontFamily: "ShadowsIntoLightTwo"),
          ),
        ).show(context);
        context.loaderOverlay.hide();

        context.loaderOverlay.hide();

        Future.delayed(const Duration(milliseconds: 1000), () {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const Dashboard()),
              (Route route) => false);
        });
      } else {
        Flushbar(
          titleColor: Colors.white,
          flushbarPosition: FlushbarPosition.TOP,
          flushbarStyle: FlushbarStyle.FLOATING,
          reverseAnimationCurve: Curves.decelerate,
          forwardAnimationCurve: Curves.elasticOut,
          backgroundColor: const Color.fromARGB(255, 219, 54, 42),
          isDismissible: false,
          duration: const Duration(seconds: 4),
          icon: const Icon(
            Icons.cancel_outlined,
            color: Colors.white,
          ),
          showProgressIndicator: true,
          progressIndicatorBackgroundColor: Colors.blueGrey,
          titleText: const Text(
            "Failed",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: Colors.white,
                fontFamily: "ShadowsIntoLightTwo"),
          ),
          messageText: const Text(
            "Invalid credentials",
            style: TextStyle(
                fontSize: 18.0,
                color: Colors.white,
                fontFamily: "ShadowsIntoLightTwo"),
          ),
        ).show(context);

        context.loaderOverlay.hide();

        Future.delayed(const Duration(milliseconds: 1000), () {
          Navigator.pop(context);
        });
      }
    });
  }
}

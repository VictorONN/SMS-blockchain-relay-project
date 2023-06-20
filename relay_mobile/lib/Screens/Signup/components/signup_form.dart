import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import '../../../components/already_have_an_account_acheck.dart';
import '../../../components/rounded_button.dart';
import '../../../constants.dart';
import '../../../services/apis.dart';
import '../../Login/login_screen.dart';

// class SignUpForm extends StatelessWidget {
//   const SignUpForm({
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       child: Column(
//         children: [
//           TextFormField(
//             keyboardType: TextInputType.emailAddress,
//             textInputAction: TextInputAction.next,
//             cursorColor: kPrimaryColor,
//             onSaved: (email) {},
//             decoration: InputDecoration(
//               hintText: "Your email",
//               prefixIcon: Padding(
//                 padding: const EdgeInsets.all(defaultPadding),
//                 child: Icon(Icons.person),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: defaultPadding),
//             child: TextFormField(
//               textInputAction: TextInputAction.done,
//               obscureText: true,
//               cursorColor: kPrimaryColor,
//               decoration: InputDecoration(
//                 hintText: "Your password",
//                 prefixIcon: Padding(
//                   padding: const EdgeInsets.all(defaultPadding),
//                   child: Icon(Icons.lock),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: defaultPadding / 2),
//           RoundedButton(
//             text: "SIGN UP",
//             color: kPrimaryLightColor,
//             textColor: Colors.black,
//             press: () {},
//           ),
//           const SizedBox(height: defaultPadding),
//           AlreadyHaveAnAccountCheck(
//             login: false,
//             press: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) {
//                     return LoginScreen();
//                   },
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final TextEditingController _tillNumberController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool checkedValue = false;
  bool checkboxValue = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _phoneController,
            validator: (value) {
            
              String pattern =
                  r'^\+254\d{9}$';
              RegExp regex = RegExp(pattern);
              if (value == null || value.isEmpty || !regex.hasMatch(value)) {
                return 'Phone Number should start with +254';
              } else {
                return null;
              }
            },
            decoration: InputDecoration(
              hintText: "Enter Phone Number",
              prefixIcon: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Icon(Icons.phone),
              ),
            ),
          ),
          TextFormField(
            controller: _tillNumberController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Enter Till Number';
              } else {
                return null;
              }
            },
            decoration: InputDecoration(
              hintText: "Enter Till Number",
              prefixIcon: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Icon(Icons.support_agent),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: TextFormField(
              textInputAction: TextInputAction.done,
              obscureText: true,
              cursorColor: kPrimaryColor,
              controller: _passwordController,
              validator: (value) {
                if (value!.isEmpty) {
                  return "* Required";
                } else if (value.length < 6) {
                  return "Password should be atleast 6 characters";
                } else {
                  return null;
                }
              },
              decoration: InputDecoration(
                hintText: "Your password",
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.lock),
                ),
              ),
            ),
          ),
          const SizedBox(height: 15.0),
          const Text(
            'By signing up, you agree to our Terms & Conditions and Privacy Policy.',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
          ),
          const SizedBox(height: defaultPadding / 2),
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(kPrimaryLightColor)),
            // style: ThemeHelper().buttonStyle(),
            // onPressed: _loginPressed,
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _registrationPressed();
              } else {
                print("Not Validated");
              }
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
              child: Text(
                'Sign up'.toUpperCase(),
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
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
        ],
      ),
    );
  }

  void _registrationPressed() async {
    context.loaderOverlay.show();

    var till_number = _tillNumberController.text;
    var password = _passwordController.text;
    var phone = _phoneController.text;

    await ApiService()
        .register(phone,till_number, password)
        .then((value) {
      if (value != null) {
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
            "Registration succesful!",
            style: TextStyle(
                fontSize: 18.0,
                color: Colors.white,
                fontFamily: "ShadowsIntoLightTwo"),
          ),
        ).show(context);

        context.loaderOverlay.hide();

        Future.delayed(const Duration(milliseconds: 2000), () {
          Navigator.push(context,
              SwipeablePageRoute(builder: (context) => const LoginScreen()));
        });
      } else {
        Flushbar(
          titleColor: Colors.white,
          flushbarPosition: FlushbarPosition.TOP,
          flushbarStyle: FlushbarStyle.FLOATING,
          reverseAnimationCurve: Curves.decelerate,
          forwardAnimationCurve: Curves.elasticOut,
          backgroundColor: Color.fromARGB(255, 219, 54, 42),
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
            "Invalid values",
            style: TextStyle(
                fontSize: 18.0,
                color: Colors.white,
                fontFamily: "ShadowsIntoLightTwo"),
          ),
        ).show(context);

        context.loaderOverlay.hide();
      }
    });
  }
}

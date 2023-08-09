import 'package:flutter/material.dart';
import 'package:relay_mobile/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Screens/Login/login_screen.dart';

void main() {
  runApp(const MyApp());
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: HomePage(),
//     );
//   }
// }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var isLogin;


  checkUserLoginState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //  SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.clear();
    var token = prefs.getString('access');
    setState(() {
      isLogin = token == null || token == "" ? false : true;
    });
  }

  @override
  void initState() {
    checkUserLoginState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Relay',
        theme: ThemeData(
            primaryColor: Colors.blue[800], scaffoldBackgroundColor: Colors.white),
        home: isLogin != null
            ? isLogin
                ? const HomePage()
                : const LoginScreen()
            : const LoginScreen());
  }
}

import 'package:account_connect/ui/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starknet/starknet.dart';
import 'package:starknet_flutter/starknet_flutter.dart';

import 'ui/screens/account_balance/home.dart';

import 'services/contract_service.dart';
Future<void> main() async {
  const nodeUri = 'https://starknet-goerli.infura.io/v3/872474efe7554d4d8891b17444ceb31a';
  await StarknetFlutter.init(
    nodeUri: (nodeUri.isNotEmpty) ? Uri.parse(nodeUri) : infuraGoerliTestnetUri,
  );

  runApp(const StarknetWalletApp());
}
class StarknetWalletApp extends StatefulWidget {
  const StarknetWalletApp({super.key});

  @override
  State<StarknetWalletApp> createState() => _StarknetWalletAppState();
}

class _StarknetWalletAppState extends State<StarknetWalletApp> {
  var isLogin;


  checkUserLoginState() async {
    // print("getting banalce");
    // print(await getBalance());
    // SharedPreferences prefs = await SharedPreferences.getInstance();
     SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.clear();
    var token = prefs.getString('access');
    setState(() {
      isLogin = token == null || token == "" ? false : true;
      // isLogin = true;
    });
    print(isLogin);
  }
  

  @override
  void initState() {
    checkUserLoginState();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Relayer Beacon",
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.blue,
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      debugShowCheckedModeBanner: false,
      home: isLogin != null
            ? isLogin
                ? const HomePage()
                : const LoginScreen()
            : const LoginScreen()
    );
  }
}

// class StarknetWalletApp extends StatelessWidget {
//   const StarknetWalletApp({super.key});

//   @override
//   Widget build(BuildContext context) {

//     return MaterialApp(
//       title: "StarkNet Wallet in Flutter",
//       theme: ThemeData(
//         scaffoldBackgroundColor: Colors.white,
//         primarySwatch: Colors.blue,
//         fontFamily: GoogleFonts.poppins().fontFamily,
//       ),
//       debugShowCheckedModeBanner: false,
//       home: const HomePage(),
//     );
//   }
// }

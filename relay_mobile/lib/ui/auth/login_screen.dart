import 'package:account_connect/responsive.dart';
import 'package:account_connect/ui/auth/components/backgrounds.dart';
import 'package:account_connect/ui/auth/components/login_form.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

// import '../../responsive.dart';
// import 'components/login_form.dart';
// import 'components/login_screen_top_image.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return const LoaderOverlay(
      child: Background(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Responsive(
              mobile: MobileLoginScreen(),
              desktop: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 450,
                          child: LoginForm(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// class LoginScreen extends StatelessWidget {
//   const LoginScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return LoaderOverlay(
//       child: Background(
//         child: SafeArea(
//           child: SingleChildScrollView(
//             child: Responsive(
//               mobile: const MobileLoginScreen(),
//               desktop: Row(
//                 children: [
//                   const Expanded(
//                     child: LoginScreenTopImage(),
//                   ),
//                   Expanded(
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: const [
//                         SizedBox(
//                           width: 450,
//                           child: LoginForm(),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class MobileLoginScreen extends StatelessWidget {
//   const MobileLoginScreen({
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: <Widget>[
//         const LoginScreenTopImage(),
//         Row(
//           children: const [
//             Spacer(),
//             Expanded(
//               flex: 8,
//               child: LoginForm(),
//             ),
//             Spacer(),
//           ],
//         )
//       ],
//     );
//   }
// }

class MobileLoginScreen extends StatefulWidget {
  const MobileLoginScreen({super.key});

  @override
  State<MobileLoginScreen> createState() => _MobileLoginScreenState();
}

class _MobileLoginScreenState extends State<MobileLoginScreen> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          children: [
            Spacer(),
            Expanded(
              flex: 8,
              child: LoginForm(),
            ),
            Spacer(),
          ],
        )
      ],
    );
  }
}

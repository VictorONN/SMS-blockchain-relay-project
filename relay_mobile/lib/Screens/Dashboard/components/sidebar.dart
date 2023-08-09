import 'dart:async';

import 'package:another_flushbar/flushbar.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:relay_mobile/Screens/Login/login_screen.dart';
import 'package:relay_mobile/constants.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/apis.dart';
import '../navigation_bloc/navigation_bloc.dart';
import 'menu_item.dart';

class SideBar extends StatefulWidget {
  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar>
    with SingleTickerProviderStateMixin<SideBar> {
  late AnimationController _animationController;
  late StreamController<bool> isSidebarOpenedStreamController;
  late Stream<bool> isSidebarOpenedStream;
  late StreamSink<bool> isSidebarOpenedSink;
  final _animationDuration = const Duration(milliseconds: 500);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FocusNode searchFocusNode = FocusNode();
  FocusNode textFieldFocusNode = FocusNode();
  late SingleValueDropDownController _cnt;
  double _depositRate = 0.0;
  double _withdrawRate = 0.0;

  String phone_number = "";
  int? user_id;

  Future<void> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      phone_number = prefs.getString("phone_number")!;
      user_id = prefs.getInt("user_id");
    });
  }

  @override
  void initState() {
    super.initState();
    getSharedPrefs();
    _cnt = SingleValueDropDownController();
    _animationController =
        AnimationController(vsync: this, duration: _animationDuration);
    isSidebarOpenedStreamController = PublishSubject<bool>();
    isSidebarOpenedStream = isSidebarOpenedStreamController.stream;
    isSidebarOpenedSink = isSidebarOpenedStreamController.sink;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cnt.dispose();
    isSidebarOpenedStreamController.close();
    isSidebarOpenedSink.close();
    super.dispose();
  }

  void onIconPressed() {
    final animationStatus = _animationController.status;
    final isAnimationCompleted = animationStatus == AnimationStatus.completed;

    if (isAnimationCompleted) {
      isSidebarOpenedSink.add(false);
      _animationController.reverse();
    } else {
      isSidebarOpenedSink.add(true);
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return StreamBuilder<bool>(
      initialData: false,
      stream: isSidebarOpenedStream,
      builder: (context, isSideBarOpenedAsync) {
        return AnimatedPositioned(
          duration: _animationDuration,
          top: 0,
          bottom: 0,
          left: isSideBarOpenedAsync.data! ? 0 : -screenWidth,
          right: isSideBarOpenedAsync.data! ? 0 : screenWidth - 45,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.grey[200],
                  child: Column(
                    children: <Widget>[
                      const SizedBox(
                        height: 70,
                      ),
                      ListTile(
                        title: Text(
                          phone_number,
                          style: TextStyle(
                              color: const Color.fromARGB(255, 0, 0, 0),
                              fontSize: 20,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                      Divider(
                        height: 44,
                        thickness: 0.5,
                        color:
                            const Color.fromARGB(255, 6, 6, 6).withOpacity(0.3),
                        indent: 12,
                        endIndent: 32,
                      ),
                      MenuItem(
                        icon: Icons.dashboard,
                        title: "Dashboard",
                        onTap: () {
                          print("Dashboard clicked");
                          onIconPressed();
                          BlocProvider.of<NavigationBloc>(context)
                              .add(NavigationEvents.DashboardClickedEvent);
                        },
                      ),
                      MenuItem(
                        icon: Icons.rate_review,
                        title: "Set Rate",
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                scrollable: true,
                                title: const Text("Set Deposit and Withdraw Rates"),
                                content: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Form(
                                        key: _formKey,
                                        child:  Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              TextField(
                                                decoration: InputDecoration(
                                                    labelText: 'Deposit Rate'),
                                                keyboardType:
                                                    TextInputType.number,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _depositRate = double.parse(value);
                                                  });
                                                },
                                              ),
                                              TextField(
                                                decoration: InputDecoration(
                                                    labelText: 'Withdraw Rate'),
                                                keyboardType:
                                                    TextInputType.number,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _withdrawRate = double.parse(value);
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                          // actions: [
                                          //   ElevatedButton(
                                          //     onPressed: () {
                                          //       // widget.onSubmit(DepositWithdrawModalData(depositRate: _depositRate, withdrawRate: _withdrawRate));
                                          //       Navigator.of(context).pop();
                                          //     },
                                          //     child: Text('Submit'),
                                          //   ),
                                          // ],
                                        )

                                    // child: Form(
                                    //   child: Column(
                                    //     children: [
                                    //       TextFormField(
                                    //         decoration: const InputDecoration(
                                    //           labelText: "",
                                    //           icon: Icon(Icons.account_box),
                                    //         ),
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                    ),
                                actions: [
                                  ElevatedButton(
                                    child: const Text("submit"),
                                    onPressed: () async {
                                       context.loaderOverlay.show();
                                      await ApiService()
                                          .updateUser(user_id, _depositRate,
                                              _withdrawRate)
                                          .then((value) {
                                        if (value != null) {
                                          Navigator.of(context).pop(); 
                                          Flushbar(
                                            titleColor: Colors.white,
                                            flushbarPosition:
                                                FlushbarPosition.TOP,
                                            flushbarStyle:
                                                FlushbarStyle.FLOATING,
                                            reverseAnimationCurve:
                                                Curves.decelerate,
                                            forwardAnimationCurve:
                                                Curves.elasticOut,
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 43, 160, 47),
                                            isDismissible: false,
                                            duration:
                                                const Duration(seconds: 4),
                                            icon: const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                            ),
                                            showProgressIndicator: true,
                                            progressIndicatorBackgroundColor:
                                                Colors.blueGrey,
                                            titleText: const Text(
                                              "Success",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20.0,
                                                  color: Colors.white,
                                                  fontFamily:
                                                      "ShadowsIntoLightTwo"),
                                            ),
                                            messageText: const Text(
                                              "Rate Set succesful!",
                                              style: TextStyle(
                                                  fontSize: 18.0,
                                                  color: Colors.white,
                                                  fontFamily:
                                                      "ShadowsIntoLightTwo"),
                                            ),
                                          ).show(context);
                                          context.loaderOverlay.hide();

                                          context.loaderOverlay.hide();
                                        } else {
                                          Flushbar(
                                            titleColor: Colors.white,
                                            flushbarPosition:
                                                FlushbarPosition.TOP,
                                            flushbarStyle:
                                                FlushbarStyle.FLOATING,
                                            reverseAnimationCurve:
                                                Curves.decelerate,
                                            forwardAnimationCurve:
                                                Curves.elasticOut,
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 219, 54, 42),
                                            isDismissible: false,
                                            duration:
                                                const Duration(seconds: 4),
                                            icon: const Icon(
                                              Icons.cancel_outlined,
                                              color: Colors.white,
                                            ),
                                            showProgressIndicator: true,
                                            progressIndicatorBackgroundColor:
                                                Colors.blueGrey,
                                            titleText: const Text(
                                              "Failed",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20.0,
                                                  color: Colors.white,
                                                  fontFamily:
                                                      "ShadowsIntoLightTwo"),
                                            ),
                                            messageText: const Text(
                                              "Failed Updating",
                                              style: TextStyle(
                                                  fontSize: 18.0,
                                                  color: Colors.white,
                                                  fontFamily:
                                                      "ShadowsIntoLightTwo"),
                                            ),
                                          ).show(context);

                                          context.loaderOverlay.hide();
                                        }
                                      });
                                      // your code
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                          // onIconPressed();
                          // BlocProvider.of<NavigationBloc>(context)
                          //     .add(NavigationEvents.MyAccountClickedEvent);
                        },
                      ),
                      Divider(
                        height: 44,
                        thickness: 0.5,
                        color: Colors.white.withOpacity(0.3),
                        indent: 12,
                        endIndent: 32,
                      ),
                      MenuItem(
                        icon: Icons.exit_to_app,
                        title: "Logout",
                        onTap: _logout,
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: const Alignment(0, -0.90),
                child: GestureDetector(
                  onTap: () {
                    onIconPressed();
                  },
                  child: ClipPath(
                    clipper: CustomMenuClipper(),
                    child: Container(
                      width: 35,
                      height: 110,
                      color: Colors.grey[200],
                      alignment: Alignment.centerLeft,
                      child: AnimatedIcon(
                        progress: _animationController.view,
                        icon: AnimatedIcons.menu_close,
                        color: Colors.black,
                        size: 25,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();

    // ignore: use_build_context_synchronously
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route route) => false);
  }
}

class CustomMenuClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Paint paint = Paint();
    paint.color = Colors.white;

    final width = size.width;
    final height = size.height;

    Path path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(0, 8, 10, 16);
    path.quadraticBezierTo(width - 1, height / 2 - 20, width, height / 2);
    path.quadraticBezierTo(width + 1, height / 2 + 20, 10, height - 16);
    path.quadraticBezierTo(0, height - 8, 0, height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

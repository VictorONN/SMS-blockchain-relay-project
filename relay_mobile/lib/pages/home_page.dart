import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:relay_mobile/Screens/Dashboard/navigation_bloc/navigation_bloc.dart';
import 'package:relay_mobile/constants.dart';
import 'package:relay_mobile/models/all_transactions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telephony/telephony.dart';
import 'package:intl/intl.dart';

import '../components/detailed_card.dart';
import '../services/apis.dart';

//Handle background message

onBackgroundMessage(SmsMessage message) {
  debugPrint("onBackgroundMessage called");
}

class HomePage extends StatefulWidget implements NavigationStates {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<SmsMessage> messages = [];

  List<Transactions> trans = [];

  final telephony = Telephony.instance;
  int _new_message = 0;
  String phone_number = "";
  int wallet_amount = 0;
  String till_number = "";

  @override
  void initState() {
    super.initState();
    getUserDetails();
    initPlatformState();
  }

  onMessage(SmsMessage message) async {
    print("Incoming message");

      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Example: Extracting a specific keyword
      if (message.body!.startsWith('#sendrelay')) {
              String? sender = message.address;
              String? body = message.body;
              int? agent_id = prefs.getInt("user_id");
        // Extract additional information or perform actions based on the keyword
        // Example: Extract a value after the keyword
        // print(body.indexOf('#receiver'));
        String? receiver = body
            ?.substring(body.indexOf('#receiver') + '#receiver'.length)
            .trim();
        String? amount =
            body?.substring(body.indexOf('#amount') + '#amount'.length).trim();

        // Print or use the extracted information as needed
        print('Received message from $sender');
        print('Receiver value: $receiver');
        print('amount value: $amount');
        print('agent id: $agent_id');

        await ApiService()
            .sendRelay(sender!, receiver!.split('\n')[0].trim(), amount!, agent_id!)
            .then((value) {
          if (value != null) {
              var snackBar = SnackBar(
                                content: Text(value.message),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            context.loaderOverlay.hide();
          } else {
            context.loaderOverlay.hide();

            Future.delayed(const Duration(milliseconds: 1000), () {
              Navigator.pop(context);
            });
          }
        });
      }else if (message.body!.startsWith('#withdrawrelay')) {
        String? sender = message.address;
              String? body = message.body;
              int? agent_id = prefs.getInt("user_id");
        // Extract additional information or perform actions based on the keyword
        // Example: Extract a value after the keyword
        // print(body.indexOf('#receiver'));
        String? receiver = body
            ?.substring(body.indexOf('#receiver') + '#receiver'.length)
            .trim();
        String? amount =
            body?.substring(body.indexOf('#amount') + '#amount'.length).trim();

        // Print or use the extracted information as needed
        print('Received message from $sender');
        print('Receiver value: $receiver');
        print('amount value: $amount');
        print('agent id: $agent_id');

        await ApiService()
            .withdrawRelay(sender!, receiver!.split('\n')[0].trim(), amount!, agent_id!)
            .then((value) {
          if (value != null) {
            var snackBar = SnackBar(
                                content: Text(value.message),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            context.loaderOverlay.hide();
          } else {
            context.loaderOverlay.hide();

            Future.delayed(const Duration(milliseconds: 1000), () {
              Navigator.pop(context);
            });
          }
        });
  
    }else if (message.body!.startsWith('#registerrelay')) {
        String? sender = message.address;


        // Print or use the extracted information as needed
        print('Received message from $sender');

        await ApiService()
            .registerRelay(sender!.split('\n')[0].trim())
            .then((value) {
          if (value != null) {
            var snackBar = SnackBar(
                                content: Text(value.message),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            context.loaderOverlay.hide();
          } else {
            context.loaderOverlay.hide();

            Future.delayed(const Duration(milliseconds: 1000), () {
              Navigator.pop(context);
            });
          }
        });
  
    }
  }

  getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.clear();
    context.loaderOverlay.show();
    await ApiService().getUserDetails(prefs.getInt("user_id")).then((value) {
      if (value != null) {
        setState(() {
          wallet_amount = value.amount;
          till_number = value.tillNumber;
        });

        context.loaderOverlay.hide();
      } else {
        context.loaderOverlay.hide();

        Future.delayed(const Duration(milliseconds: 1000), () {
          Navigator.pop(context);
        });
      }
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.

    final bool? result = await telephony.requestPhoneAndSmsPermissions;

    if (result != null && result) {
      telephony.listenIncomingSms(
          onNewMessage: onMessage, onBackgroundMessage: onBackgroundMessage);
    }

    if (!mounted) return;
  }

  // Future<void> allMessages() async {
  //   messages = await telephony.getInboxSms(
  //       columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
  //       filter: SmsFilter.where(SmsColumn.BODY).like('#relay%'),
  //       sortOrder: [
  //         OrderBy(SmsColumn.ADDRESS, sort: Sort.ASC),
  //         OrderBy(SmsColumn.BODY)
  //       ]);
  //   print(messages);
  // }

  @override
  Widget build(BuildContext context) {
    int _currentIndex = 0; // Track the currently selected item index

    return Scaffold(
      backgroundColor: Colors.blue[800],
      appBar: AppBar(
        automaticallyImplyLeading: false,

        // title: Text("Relay Mobile"),

        //backgroundColor: Colors.purple,
        flexibleSpace: Container(
          decoration: const BoxDecoration(color: kPrimaryColor
              // gradient: LinearGradient(
              //   colors: [Colors.purple, Colors.red],
              //   begin: Alignment.bottomRight,
              //   end: Alignment.topLeft,
              // ),
              ),
        ),

        elevation: 0,
        titleSpacing: 50,
      ),
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              children: [
                // greetings bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //Hi user
                    // ignore: prefer_const_constructors
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // const SizedBox(
                        //   height: 0,
                        // ),
                        // const Text(
                        //   "Welcome Back !",
                        //   // ignore: prefer_const_constructors
                        //   style: TextStyle(
                        //       color: Colors.white,
                        //       fontSize: 24,
                        //       fontWeight: FontWeight.bold),
                        // ),
                        // const SizedBox(
                        //   height: 8,
                        // ),
                        // Text(
                        //   "${DateFormat('dd-MMMM-yyyy').format(new DateTime.now())}",
                        //   style: TextStyle(color: Colors.blue[200]),
                        // )
                      ],
                    ),

                    //Notification
                    // ignore: avoid_unnecessary_containers
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.blue[600],
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.all(12),

                      // ignore: prefer_const_constructors
                      child: Row(
                        children: [
                          const SizedBox(
                            height: 0,
                          ),
                          const Text(
                            "Welcome Back !",
                            // ignore: prefer_const_constructors
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          // Text(
                          //   "${DateFormat('dd-MMMM-yyyy').format(new DateTime.now())}",
                          //   style: TextStyle(color: Colors.blue[200]),
                          // )
                          //        GestureDetector(
                          //   onTap: () {
                          //     setState(() {
                          //       _new_message = 0; // Update the selected item index
                          //     });
                          //     const snackBar = SnackBar(
                          //       content: Text('Transactions Updated'),
                          //     );
                          //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          //   },
                          //   child: const Icon(
                          //     Icons.refresh,
                          //     color: Colors.white,
                          //   ),
                          // ),
                          // Icon(
                          //   Icons.notifications,
                          //   color: Colors.white,
                          // ),
                          // Text(
                          //   "${_new_message}",
                          //   style: TextStyle(color: Colors.white, fontSize: 25),
                          // ),
                        ],
                      ),
                    ),

                    //
                  ],
                ),

                // const SizedBox(
                //   height: 25,
                // ),

                //Search Bar
                // Container(
                //   padding: const EdgeInsets.all(12),
                //   decoration: BoxDecoration(
                //       color: Colors.blue[600],
                //       borderRadius: BorderRadius.circular(12)),
                //   child: const Row(
                //     children: [
                //       Icon(
                //         Icons.search,
                //         color: Colors.white,
                //       ),
                //       SizedBox(
                //         width: 5,
                //       ),
                //       Text(
                //         "Search Message",
                //         style: TextStyle(color: Colors.white),
                //       ),
                //     ],
                //   ),
                // ),

                const SizedBox(
                  height: 25,
                ),

                // how do you feel
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "My Wallet Balance ",
                      // ignore: prefer_const_constructors
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "My Till Number ",
                      // ignore: prefer_const_constructors
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ksh ${wallet_amount}',
                      // ignore: prefer_const_constructors
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${till_number}",
                      // ignore: prefer_const_constructors
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: [
                //     Column(
                //       children: [
                //         Container(
                //           decoration: BoxDecoration(
                //               color: Colors.blue[600],
                //               borderRadius: BorderRadius.circular(12)),
                //           padding: const EdgeInsets.all(16),

                //           // ignore: prefer_const_constructors
                //           child:
                //               Text("20", style: TextStyle(color: Colors.white)),
                //         ),
                //         const SizedBox(
                //           height: 12,
                //         ),
                //         const Text("Incoming",
                //             style: TextStyle(color: Colors.white)),
                //       ],
                //     ),
                //     Column(
                //       children: [
                //         Container(
                //           decoration: BoxDecoration(
                //               color: Colors.blue[600],
                //               borderRadius: BorderRadius.circular(12)),
                //           padding: const EdgeInsets.all(16),

                //           // ignore: prefer_const_constructors
                //           child:
                //               Text("10", style: TextStyle(color: Colors.white)),
                //         ),
                //         const SizedBox(
                //           height: 12,
                //         ),
                //         const Text(
                //           "Pending",
                //           style: TextStyle(color: Colors.white),
                //         ),
                //       ],
                //     ),
                //     Column(
                //       children: [
                //         Container(
                //           decoration: BoxDecoration(
                //               color: Colors.blue[600],
                //               borderRadius: BorderRadius.circular(12)),
                //           padding: const EdgeInsets.all(16),

                //           // ignore: prefer_const_constructors
                //           child:
                //               Text("30", style: TextStyle(color: Colors.white)),
                //         ),
                //         const SizedBox(
                //           height: 12,
                //         ),
                //         const Text(
                //           "Processed",
                //           style: TextStyle(color: Colors.white),
                //         ),
                //       ],
                //     )
                //   ],
                // ),
              ],
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          //details
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(50.0),
                bottom: Radius.zero, // Set bottomRadius to zero
              ),
              child: Container(
                padding: const EdgeInsets.all(25),
                color: Colors.grey[200],
                child: Center(
                    child: Column(children: [
                  //exercie heading
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("All transactions",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20)),
                      // Icon(Icons.more_horiz)
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: FutureBuilder(
                        future: _fetchListItems(),
                        builder: (context, AsyncSnapshot snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else {
                            return ListView.builder(
                                shrinkWrap: true,
                                itemCount: trans.length,
                                // scrollDirection: Axis.horizontal,
                                itemBuilder: (BuildContext context, int index) {
                                  return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(16)),
                                        child: DetailedCard(
                                            title: "${trans[index].purpose}",
                                            subtitle: "Via - Relay",
                                            description: "Initator : ${trans[index].sender}\n\nReceiver :${trans[index].receiver}\n\nAmount : Ksh ${trans[index].amount}",
                                          )

                                        // ListTile(
                                        //   // onTap: () => initPlatformState(),
                                        //   // leading: Icon(Icons.message),
                                        //   title: Text(
                                        //     "${trans[index].sender} - Ksh ${trans[index].amount}",
                                        //     style: const TextStyle(
                                        //         fontSize: 17,
                                        //         fontWeight: FontWeight.bold),
                                        //   ),
                                        //   subtitle: Text(
                                        //       "Via - ${trans[index].purpose}"),
                                        //   // trailing: Text('${trans[index].amount}'),
                                        //   // trailing: Text(
                                        //   //   DateFormat('MM/dd/yyyy, hh:mm a')
                                        //   //       .format(DateTime
                                        //   //           .fromMillisecondsSinceEpoch(
                                        //   //               messages[index].date!)),
                                        //   // ),
                                        // ),
                                      ));
                                });
                          }
                        }),
                  ),
                ])),
              ),
            ),
          )
        ]),
      ),
    );
  }

  _fetchListItems() async {
    // messages = await telephony.getInboxSms(
    //     columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
    //     filter: SmsFilter.where(SmsColumn.BODY).like('#relay%'),
    //     sortOrder: [
    //       OrderBy(SmsColumn.DATE, sort: Sort.DESC),
    //       // OrderBy(SmsColumn.BODY)
    //     ]);
    trans = await ApiService().getTransactionsAll();

    return trans;
  }
}

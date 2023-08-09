import 'dart:async';
import 'dart:ffi';

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

  bool paymentSuccessful = false;
  late StreamSubscription _subscription; // For canceling the polling

  final telephony = Telephony.instance;
  String phone_number = "";
  int wallet_amount = 0;
  int block_amount = 0;

  @override
  void initState() {
    super.initState();
    getUserDetails();
    print("init");
    initPlatformState();
  }

  double? extractValue(String pattern, String input) {
    RegExp regex = RegExp(pattern);
    Match? match = regex.firstMatch(input);

    if (match != null && match.groupCount >= 1) {
      String extractedValue = match.group(1)!;
      return double.tryParse(extractedValue);
    } else {
      return null;
    }
  }

  final SmsSendStatusListener listener = (SendStatus status) {
    print(status);
    // Handle the status
  };

  Future<void> pollPaymentStatus(
      reference, sender, divisionDepositResult, depositValue) async {
    _subscription = Stream.periodic(Duration(seconds: 5)).listen((_) async {
      print("Polling payment status...");

      final value = await ApiService()
          .getTransactionsByRef(reference); // Replace with your API call

      if (value != null) {
        if (value[0].status == "complete") {
          setState(() {
            paymentSuccessful = true;
          });

          telephony.sendSms(
              to: sender,
              isMultipart: true,
              statusListener: listener,
              message:
                  "\$$divisionDepositResult ($depositValue kshs) has been deposited. Your on-chain balance is \$2.74(290 kshs)");
          _subscription
              .cancel(); // Cancel the polling since payment is successful
              getUserDetails();
          print("Payment successful!");
        }
      }
    });
  }

  onMessage(SmsMessage message) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sender = message.address;
    int? agent_id = prefs.getInt("user_id");

    double? depositValue = extractValue(r'#d#(\d+)', message.body!);
    if (depositValue != null) {
      print("Deposit value: $depositValue");

      int? depositRate = prefs.getInt("deposit_rate")!;
      double divisionDepositResult =
          depositValue / depositRate; // send to block chain the divided result

      await ApiService()
          .sendRelay(sender!.substring(1), depositValue, agent_id!)
          .then((value) {
        if (value != null) {
          var snackBar = SnackBar(
            content: Text(value.message),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          print("here");
          print(value.data.transactionReference);

          pollPaymentStatus(value.data.transactionReference, sender,
              divisionDepositResult, depositValue);

          context.loaderOverlay.hide();
        } else {
          context.loaderOverlay.hide();

          Future.delayed(const Duration(milliseconds: 1000), () {
            Navigator.pop(context);
          });
        }
      });
    } else {
      double? withdrawValue = extractValue(r'#w#(\d+)', message.body!);
      if (withdrawValue != null) {
        print("Withdraw value: $withdrawValue");

        int? withdrawRate = prefs.getInt("withdraw_rate")!;
        // double divisionWithdrawResult = withdrawValue / withdrawRate; // from block chain divide the result wiht the rate

        //perform withdraw
        await ApiService()
            .withdrawRelay(sender!.substring(1), withdrawValue, agent_id!)
            .then((value) {
          if (value != null) {
            var snackBar = SnackBar(
              content: Text(value.message),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            telephony.sendSms(
                to: sender,
                isMultipart: true,
                statusListener: listener,
                message:
                    "\$2 ($withdrawValue kshs) has been withdrawn. Your on-chain balance is \$0.74(90 kshs)");
            context.loaderOverlay.hide();
          } else {
            context.loaderOverlay.hide();

            Future.delayed(const Duration(milliseconds: 1000), () {
              Navigator.pop(context);
            });
          }
        });
      } else {
        if (message.body!.startsWith("#balance")) {
          //show balance from blockchain
          telephony.sendSms(
              to: sender!,
              isMultipart: true,
              statusListener: listener,
              message: 'Your on-chain balance is \$0.74(90 kshs)');
        }
        if (message.body!.startsWith("#help")) {
          telephony.sendSms(
              to: sender!,
              statusListener: listener,
              isMultipart: true,
              message:
                  "Welcome to SMS RELAY, your one route to blockchain technology.\n\n"
                  "These are the available commands:\n\n"
                  "To Deposit:\n"
                  "#d#amount\n\n"
                  "Eg.\n"
                  "#d#300\n\n"
                  "To Withdraw:\n"
                  "#w#amount\n\n"
                  "Eg.\n"
                  "#w#200\n\n"
                  "To check balance:\n"
                  "#balance\n\n"
                  "Eg.\n"
                  "#balance\n\n"
                  "To send usd on-chain:\n"
                  "#s#country_code#receiver_number#amount\n"
                  "Eg:\n"
                  "#s#254#0700855496#0.5");
        }
      }
    }
  }

  getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    context.loaderOverlay.show();
    await ApiService().getUserBalances(prefs.getInt("user_id")).then((value) {
      if (value != null) {
        setState(() {
          wallet_amount = value.data.walletBalance;
          block_amount = value.data.blockchainBalance;
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

  @override
  Widget build(BuildContext context) {
    int _currentIndex = 0; // Track the currently selected item index

    return Scaffold(
      backgroundColor: Colors.blue[800],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(color: kPrimaryColor),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                        ],
                      ),
                    ),

                    //
                  ],
                ),
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
                      "My Block balance ",
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
                      'Ksh $wallet_amount',
                      // ignore: prefer_const_constructors
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "USD $block_amount",
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
                            print(snapshot.error);
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (trans.length <= 0) {
                            return Text("No Available transactions");
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
                                            description:
                                                "Initator : ${trans[index].sender}\n\nAmount : Ksh ${trans[index].amount}",
                                          )
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
    trans = await ApiService().getTransactionsAll();

    return trans;
  }
}

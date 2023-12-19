import 'dart:async';

import 'package:account_connect/services/apis.dart';
import 'package:account_connect/services/contract_service.dart';
import 'package:account_connect/ui/auth/login_screen.dart';
import 'package:account_connect/ui/screens/account_balance/widgets/account_indicator.dart';
import 'package:account_connect/ui/screens/account_balance/widgets/detailed_card.dart';
import 'package:account_connect/ui/widgets/bouncing_button.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:bouncing_button/bouncing_button.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starknet_flutter/starknet_flutter.dart';
import 'package:telephony/telephony.dart';
import '../../widgets/loading.dart';
import 'home_presenter.dart';
import 'home_viewmodel.dart';
import 'widgets/account_address.dart';
import 'widgets/account_not_deployed.dart';
import 'widgets/action_button.dart';
import 'widgets/crypto_balance_cell.dart';
import 'widgets/empty_wallet.dart';
import 'widgets/no_account_selected.dart';

onBackgroundMessage(SmsMessage message) {
  debugPrint("onBackgroundMessage called");
}

abstract class HomeView {
  void refresh();

  Future createPasswordDialog(PasswordStore passwordStore);

  Future showMoreDialog();

  Future<String?> unlockWithPassword();

  Future createPassword();

  Future<SelectedAccount?> showInitialisationDialog();

  Future<bool?> showTransactionModal(TransactionArguments args);
  Future showReceiveModal();
}

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> implements HomeView {
  late HomePresenter presenter;
  late HomeViewModel model;

  List<SmsMessage> messages = [];

  List trans = [];

  bool paymentSuccessful = false;

  late StreamSubscription _subscription; // For canceling the polling

  final telephony = Telephony.instance;
  String phone_number = "";
  int wallet_amount = 0;
  int relayer_amount = 0;

  double _depositRate = 0.0;
  double _withdrawRate = 0.0;

  int? user_id;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    presenter.dispose();
    super.dispose();
    initPlatformState();
  }

  @override
  void initState() {
    super.initState();
    presenter = HomePresenter(
      HomeViewModel(),
      this,
    ).init();
    model = presenter.viewModel;
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
    double? withdrawValue = extractValue(r'#w#(\d+)', message.body!);
    if (depositValue != null) {
      print("Deposit value: $depositValue");

      int? depositRate = prefs.getInt("deposit_rate")!;
      double divisionDepositResult =
          depositValue / depositRate; // send to block chain the divided result

      await sendUserTokens(divisionDepositResult.toString());

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
    }

    if (withdrawValue != null) {
      print("Withdraw value: $withdrawValue");

      int? withdrawRate = prefs.getInt("withdraw_rate")!;
      double divisionWithdrawResult = withdrawValue / withdrawRate; // from block chain divide the result wiht the rate
      await withdrawUserTokens(divisionWithdrawResult.toString());
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
    }
    if (message.body!.startsWith("#balance")) {
      //show balance from blockchain
      var balance = await getUserBalance(sender);
      telephony.sendSms(
          to: sender!,
          isMultipart: true,
          statusListener: listener,
          message: 'Your on-chain balance is ${balance}');
    }

    if (message.body!.startsWith("#help")) {
      telephony.sendSms(
          to: sender!,
          statusListener: listener,
          isMultipart: true,
          message:
              "Welcome to SMS RELAY, your one route to blockchain technology.\n\n"
              "These are the available commands:\n\n"
              "To Register:\n"
              "#register\n\n"
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

    if (message.body!.startsWith("#register")) {
      //Register new user via SMS
      await ApiService()
          .registerUser(sender!.substring(1))
          .then((value) {
        if (value != null) {
          var snackBar = SnackBar(
            content: Text(value.message),
          );
          // prefs.setString("address",value.data[0].address);
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          telephony.sendSms(
              to: sender,
              isMultipart: true,
              statusListener: listener,
              message:
                  "Welcome to the relay Network");
          context.loaderOverlay.hide();
        } else {
          context.loaderOverlay.hide();

          Future.delayed(const Duration(milliseconds: 1000), () {
            Navigator.pop(context);
          });
        }
      });

    //   telephony.sendSms(
    //       to: sender!,
    //       statusListener: listener,
    //       isMultipart: true,
    //       message:
    //           "Welcome to SMS RELAY, your one route to blockchain technology.\n\n"
    //           "These are the available commands:\n\n"
    //           "To Deposit:\n"
    //           "#d#amount\n\n"
    //           "Eg.\n"
    //           "#d#300\n\n"
    //           "To Withdraw:\n"
    //           "#w#amount\n\n"
    //           "Eg.\n"
    //           "#w#200\n\n"
    //           "To check balance:\n"
    //           "#balance\n\n"
    //           "Eg.\n"
    //           "#balance\n\n"
    //           "To send usd on-chain:\n"
    //           "#s#country_code#receiver_number#amount\n"
    //           "Eg:\n"
    //           "#s#254#0700855496#0.5");
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      phone_number = prefs.getString("phone_number")!;
      user_id = prefs.getInt("user_id");
    });

    final bool? result = await telephony.requestPhoneAndSmsPermissions;

    if (result != null && result) {
      telephony.listenIncomingSms(
          onNewMessage: onMessage, onBackgroundMessage: onBackgroundMessage);
    }

    if (!mounted) return;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 25,
            right: 25,
            top: 15,
            bottom: 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AccountIndicatorWidget(
                    avatarUrl: 'https://i.pravatar.cc/150?img=1',
                    selectedWallet: model.selectedWallet,
                    selectedAccount: model.selectedAccount,
                    onPressed: presenter.onAccountSwitchTap,
                  ),
                  const Spacer(),
                  BouncingWidget(
                    child: const Icon(Icons.more_horiz),
                    onTap: () {
                      showMoreDialog();
                    },
                  ),
                ],
              ),
              if (model.selectedAccount?.accountAddress != null)
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: AccountAddressWidget(
                    address: model.selectedAccount!.accountAddress,
                  ),
                ),
              SizedBox(
                height: 20,
              ),
              // Padding(
              //   padding: const EdgeInsets.only(top: 12, bottom: 15),
              //   child: AnimatedSize(
              //     duration: const Duration(milliseconds: 500),
              //     curve: Curves.fastLinearToSlowEaseIn,
              //     child: model.hasSomeEth
              //         ? SizedBox(
              //             key: const Key('total_balance'),
              //             width: double.infinity,
              //             child: Text(
              //               '\$${model.totalFiatBalance.truncateBalance(precision: 2).format()}',
              //               style: const TextStyle(
              //                 fontWeight: FontWeight.bold,
              //                 fontSize: 30,
              //               ),
              //             ),
              //           )
              //         : const SizedBox(
              //             key: Key('total_balance_placeholder'),
              //             width: double.infinity,
              //           ),
              //   ),
              // ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildContent(),
                  ),
                ),
              ),
              if (model.hasSelectedWallet && model.hasSelectedAccount)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ActionButtonWidget(
                        icon: Icons.send_outlined,
                        text: 'Send',
                        // onPressed: presenter.onSendTap,
                        onPressed: () {
                          showSendDialog();
                        }),
                    const SizedBox(width: 20),
                    ActionButtonWidget(
                        icon: Icons.qr_code_2_rounded,
                        text: 'Withdraw',
                        onPressed: () {
                          showWithdrawDialog();
                        }),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    // check if a wallet & account is selected
    if (!model.hasSelectedAccount || !model.hasSelectedWallet) {
      return NoAccountSelectedWidget(
        key: const Key('no_account_selected'),
        onAccountSwitchTap: presenter.onAccountSwitchTap,
      );
    }

    if (model.deployStatus == DeployStatus.unknown ||
        model.isLoadingBalance == true) {
      return const Center(
        key: Key('loading'),
        child: LoadingWidget(),
      );
    }

    if (model.deployStatus != DeployStatus.valid) {
      return AccountNotDeployed(
        key: const Key('account_not_deployed'),
        onRefresh: presenter.refreshAccount,
        publicAccount: model.selectedAccount!,
        balance: model.ethBalance!,
        fiatPrice: model.ethFiatPrice.truncateBalance(precision: 2),
        onDeploy: () => presenter.onDeploy(unlockWithPassword),
        deployStatus: model.deployStatus,
        error: model.deployError,
        onAddCrypto: () {
          StarknessDeposit.showDepositModal(
            context,
          );
        },
      );
    }

    if (model.hasSomeEth) {
      return RefreshIndicator(
          onRefresh: presenter.loadEthBalance,
          child: Column(
            children: [
              CryptoBalanceCellWidget(
                name: 'Ethereum',
                offrampbalance: wallet_amount,
                relayerbalance: relayer_amount,
                symbolIconUrl:
                    'https://cdn4.iconfinder.com/data/icons/logos-brands-5/24/ethereum-1024.png',
                balance: model.ethBalance!,
                fiatPrice: model.ethFiatPrice.truncateBalance(precision: 2),
              ),
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  color: Colors.grey[200],
                  child: Center(
                      child: Column(children: [
                    //exercie heading
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("SMS transactions",
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
                                  itemBuilder:
                                      (BuildContext context, int index) {
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
                                            )));
                                  });
                            }
                          }),
                    ),
                  ])),
                ),
              )
            ],
          ));
    } else {
      return EmptyWalletWidget(
        onAddCrypto: () {
          StarknessDeposit.showDepositModal(
            context,
          );
        },
      );
    }
  }

  _fetchListItems() async {
    trans = await ApiService().getTransactionsAll();

    return trans;
  }

  @override
  void refresh() {
    getUserDetails();
    if (mounted) setState(() {});
  }

  @override
  Future<String?> unlockWithPassword() {
    return PasscodeInputView.showPinCode(context);
  }

  @override
  Future createPassword() {
    return PasscodeInputView.showPinCode(
      context,
      actionConfig: const PasscodeActionConfig.create(
        createTitle: "Create your pin code",
        confirmTitle: "Confirm",
      ),
    );
  }

  @override
  Future showMoreDialog() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Menu"),
        actions: [
          TextButton.icon(
            onPressed: () async {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    scrollable: true,
                    title: const Text("Set Deposit and Withdraw Rates"),
                    content: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                decoration:
                                    InputDecoration(labelText: 'Deposit Rate'),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {
                                    _depositRate = double.parse(value);
                                  });
                                },
                              ),
                              TextField(
                                decoration:
                                    InputDecoration(labelText: 'Withdraw Rate'),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {
                                    _withdrawRate = double.parse(value);
                                  });
                                },
                              ),
                            ],
                          ),
                        )),
                    actions: [
                      ElevatedButton(
                        child: const Text("submit"),
                        onPressed: () async {
                          context.loaderOverlay.show();
                          await ApiService()
                              .updateUser(user_id, _depositRate, _withdrawRate)
                              .then((value) {
                            if (value != null) {
                              Navigator.of(context).pop();
                              Flushbar(
                                titleColor: Colors.white,
                                flushbarPosition: FlushbarPosition.TOP,
                                flushbarStyle: FlushbarStyle.FLOATING,
                                reverseAnimationCurve: Curves.decelerate,
                                forwardAnimationCurve: Curves.elasticOut,
                                backgroundColor:
                                    const Color.fromARGB(255, 43, 160, 47),
                                isDismissible: false,
                                duration: const Duration(seconds: 4),
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
                                      fontFamily: "ShadowsIntoLightTwo"),
                                ),
                                messageText: const Text(
                                  "Rate Set succesful!",
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.white,
                                      fontFamily: "ShadowsIntoLightTwo"),
                                ),
                              ).show(context);
                              context.loaderOverlay.hide();

                              context.loaderOverlay.hide();
                            } else {
                              Flushbar(
                                titleColor: Colors.white,
                                flushbarPosition: FlushbarPosition.TOP,
                                flushbarStyle: FlushbarStyle.FLOATING,
                                reverseAnimationCurve: Curves.decelerate,
                                forwardAnimationCurve: Curves.elasticOut,
                                backgroundColor:
                                    const Color.fromARGB(255, 219, 54, 42),
                                isDismissible: false,
                                duration: const Duration(seconds: 4),
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
                                      fontFamily: "ShadowsIntoLightTwo"),
                                ),
                                messageText: const Text(
                                  "Failed Updating",
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.white,
                                      fontFamily: "ShadowsIntoLightTwo"),
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
            },
            icon: const Icon(Icons.rate_review),
            label: const Text("Set Rate"),
          ),
          TextButton.icon(
            onPressed: () async {
              final publicStore = StarknetStore.public();
              final wallets = publicStore.getWallets();
              for (var w in wallets) {
                await StarknetStore.deleteWallet(w);
              }
              model.selectedWallet = null;
              model.selectedAccount = null;
              refresh();
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text("Remove wallets"),
          ),
          // TextButton.icon(
          //   onPressed: () async {
          //     // TODO We use the same passwordPrompt for unlocking and creating a password
          //     // In a real app, text would be different like "Enter your previous
          //     // password" and "Create a new password" for example
          //     final previousPassword = await unlockWithPassword();
          //     if (mounted) {
          //       final newPassword = await createPassword();
          //       if (previousPassword != null && newPassword != null) {
          //         await PasswordStore().replacePassword(
          //           previousPassword,
          //           newPassword,
          //         );
          //       }
          //     }
          //   },
          //   icon: const Icon(Icons.key),
          //   label: const Text("Replace password"),
          // ),

          TextButton.icon(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.clear();

              // ignore: use_build_context_synchronously
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (Route route) => false);
            },
            icon: const Icon(Icons.logout),
            label: const Text("Log Out"),
          ),
        ],
      ),
    );
  }

  @override
  Future showSendDialog() {
    final TextEditingController _amountController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Deposit Funds to Your Relay Address"),
        actions: [
          TextFormField(
            // initialValue: ,
            controller: _amountController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter amount';
              }
              // if (!kHexaRegex.hasMatch(value)) {
              //   return 'Please enter a valid account address';
              // }
              return null;
            },
            // onChanged: (_) {
            //   _checkIfFormValid();
            // },
            autocorrect: false,
            decoration: InputDecoration(
              hintText: 'Enter amount to send',
              hintStyle: const TextStyle(fontSize: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  width: 0,
                  style: BorderStyle.none,
                ),
              ),
              filled: true,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          BouncingButton(
            child: Container(
              height: 45,
              width: 270,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100.0),
                color: Colors.blue,
              ),
              child: const Center(
                child: Text(
                  'Send',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            onPressed: () async{
              print(_amountController.text);
              print(await regesteringRelayer(_amountController.text));
              debugPrint("pressed!");
            },
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  @override
  Future showWithdrawDialog() {
    final TextEditingController _withdrawamountController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Withdraw Funds from Your Relay Address"),
        actions: [
          TextFormField(
            // initialValue: ,
            controller: _withdrawamountController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter amount';
              }
              // if (!kHexaRegex.hasMatch(value)) {
              //   return 'Please enter a valid account address';
              // }
              return null;
            },
            // onChanged: (_) {
            //   _checkIfFormValid();
            // },
            autocorrect: false,
            decoration: InputDecoration(
              hintText: 'Enter amount to withdraw',
              hintStyle: const TextStyle(fontSize: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  width: 0,
                  style: BorderStyle.none,
                ),
              ),
              filled: true,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          BouncingButton(
            child: Container(
              height: 45,
              width: 270,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100.0),
                color: Colors.blue,
              ),
              child: const Center(
                child: Text(
                  'Withdraw',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            onPressed: () async{
               print(_withdrawamountController.text);
              print(await depositRelayerTokens(_withdrawamountController.text));
              debugPrint("pressed!");
            },
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  @override
  Future createPasswordDialog(PasswordStore passwordStore) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text("Set a password to protect your wallets"),
        actions: [
          TextButton(
            onPressed: () async {
              final password = await createPassword();
              if (password != null) {
                await passwordStore.initiatePassword(password);
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text("Continue"),
          )
        ],
      ),
    );
  }

  @override
  Future<SelectedAccount?> showInitialisationDialog() {
    return StarknetWalletList.showModal(
      context,
      unlockWithPassword,
    );
  }

  @override
  Future<bool?> showTransactionModal(TransactionArguments args) {
    return StarknetTransaction.showModal(
      context,
      args: args,
    );
  }

  @override
  Future showReceiveModal() {
    return StarknetReceive.showQRCodeModal(
      context,
      address: model.selectedAccount!.accountAddress,
    );
  }

  getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    context.loaderOverlay.show();
    print("getting user details");
    relayer_amount = await getRelayerBalance();
    await ApiService().getUserBalances(prefs.getInt("user_id")).then((value) {
      if (value != null) {
        setState(() {
          wallet_amount = value.data.walletBalance;
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
}

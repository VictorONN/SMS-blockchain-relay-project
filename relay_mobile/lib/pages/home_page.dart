import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import 'package:intl/intl.dart';
//Handle background message

onBackgroundMessage(SmsMessage message) {
  debugPrint("onBackgroundMessage called");
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<SmsMessage> messages = [];
  final telephony = Telephony.instance;
  int _new_message = 0;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  onMessage(SmsMessage message) async {
    print("on message");
    if (message.body!.startsWith("#relay")) {
      setState(() {
        _new_message += 1; // Update the selected item index
      });
    }
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
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (int index) {
            setState(() {
              _currentIndex = index; // Update the selected item index
            });

            // Perform actions based on the tapped item
            if (index == 1) {
              // Handle other items

              setState(() {
                _new_message = 0; // Update the selected item index
              });
              const snackBar = SnackBar(
                content: Text('Transactions Updated'),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          },
          backgroundColor: Colors.grey[200],
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
            // BottomNavigationBarItem(icon: Icon(Icons.), label: 'message'),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.refresh,
                ),
                label: 'Sync')
          ]),
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
                        SizedBox(
                          height: 20,
                        ),
                        const Text(
                          "Hi there!",
                          // ignore: prefer_const_constructors
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          "${DateFormat('dd-MMMM-yyyy').format(new DateTime.now())}",
                          style: TextStyle(color: Colors.blue[200]),
                        )
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
                          Icon(
                            Icons.notifications,
                            color: Colors.white,
                          ),
                          Text(
                            "${_new_message}",
                            style: TextStyle(color: Colors.white, fontSize: 25),
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

                //Search Bar
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.blue[600],
                      borderRadius: BorderRadius.circular(12)),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Search Message",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),

                // how do you feel
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Transaction Summary",
                      // ignore: prefer_const_constructors
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    Icon(
                      Icons.more_horiz,
                      color: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.blue[600],
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.all(16),

                          // ignore: prefer_const_constructors
                          child:
                              Text("20", style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        const Text("Incoming",
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.blue[600],
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.all(16),

                          // ignore: prefer_const_constructors
                          child:
                              Text("10", style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        const Text(
                          "Pending",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.blue[600],
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.all(16),

                          // ignore: prefer_const_constructors
                          child:
                              Text("30", style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        const Text(
                          "Processed",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 5,
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
                      Icon(Icons.more_horiz)
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
                            return Center(child: CircularProgressIndicator());
                          } else {
                            return ListView.builder(
                                shrinkWrap: true,
                                itemCount: messages.length,
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
                                        child: ListTile(
                                          // onTap: () => initPlatformState(),
                                          // leading: Icon(Icons.message),
                                          title: Text(
                                            "${messages[index].address}",
                                            style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          subtitle:
                                              Text("${messages[index].body}"),
                                          trailing: Text(
                                            DateFormat('MM/dd/yyyy, hh:mm a')
                                                .format(DateTime
                                                    .fromMillisecondsSinceEpoch(
                                                        messages[index].date!)),
                                          ),
                                        ),
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
    messages = await telephony.getInboxSms(
        columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
        filter: SmsFilter.where(SmsColumn.BODY).like('#relay%'),
        sortOrder: [
          OrderBy(SmsColumn.DATE, sort: Sort.DESC),
          // OrderBy(SmsColumn.BODY)
        ]);

    return messages;
  }
}

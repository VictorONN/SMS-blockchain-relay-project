import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';

onBackgroundMessage(SmsMessage message) {
  debugPrint("onBackgroundMessage called");
}

class MessageTiles extends StatefulWidget {
  final List<SmsMessage> messages;
  const MessageTiles({super.key, required this.messages});

  @override
  State<MessageTiles> createState() => _MessageTilesState();
}

class _MessageTilesState extends State<MessageTiles> {
  // String _message = "";
  // List<SmsMessage> messages = [];
  final telephony = Telephony.instance;

  // @override
  // void initState() {
  //   super.initState();
  //   initPlatformState();
  // }

  // onMessage(SmsMessage message) async {
  //   setState(() {
  //     _message = message.body ?? "Error reading message body.";
  //   });
  // }

//   // Platform messages are asynchronous, so we initialize in an async method.
//   Future<void> initPlatformState() async {
//     // Platform messages may fail, so we use a try/catch PlatformException.
//     // If the widget was removed from the tree while the asynchronous platform
//     // message was in flight, we want to discard the reply rather than calling
//     // setState to update our non-existent appearance.

//     final bool? result = await telephony.requestPhoneAndSmsPermissions;

//     // if (result != null && result) {
//     //   telephony.listenIncomingSms(
//     //       onNewMessage: onMessage, onBackgroundMessage: onBackgroundMessage);
//     // }

//     messages = await telephony.getInboxSms(
//         columns: [SmsColumn.ADDRESS, SmsColumn.BODY],
//         filter: SmsFilter.where(SmsColumn.ADDRESS).equals("+254702391654"),
//         sortOrder: [
//           OrderBy(SmsColumn.ADDRESS, sort: Sort.ASC),
//           OrderBy(SmsColumn.BODY)
//         ]);
// // Accessing the values
//     // for (var message in messages) {
//     //   String? address = message.address;
//     //   String? body = message.body;

//     //   // Do something with the address and body values
//     //   print('Address: $address');
//     //   print('Body: $body');
//     // }
//     // if (!mounted) return;
//     return;
//   }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(8),
        itemCount: widget.messages.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                // onTap: () => initPlatformState(),
                leading: Icon(Icons.message),
                title: Text(
                  "${widget.messages[index].address}",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                subtitle: Text("${widget.messages[index].body}"),
                trailing: Icon(Icons.more_horiz),
              ),
            ),
          );
        });
  }
}

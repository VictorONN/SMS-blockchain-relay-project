// To parse this JSON data, do
//
//     final transactions = transactionsFromJson(jsonString);

import 'dart:convert';

List<Transactions> transactionsFromJson(String str) => List<Transactions>.from(json.decode(str).map((x) => Transactions.fromJson(x)));

String transactionsToJson(List<Transactions> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Transactions {
    int id;
    String sender;
    int amount;
    String receiver;
    String purpose;
    String status;
    String transactionRef;

    Transactions({
        required this.id,
        required this.sender,
        required this.amount,
        required this.receiver,
        required this.purpose,
        required this.status,
        required this.transactionRef,
    });

    factory Transactions.fromJson(Map<String, dynamic> json) => Transactions(
        id: json["id"],
        sender: json["sender"],
        amount: json["amount"],
        receiver: json["receiver"],
        purpose: json["purpose"],
        status: json["status"],
        transactionRef: json["transaction_ref"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "sender": sender,
        "amount": amount,
        "receiver": receiver,
        "purpose": purpose,
        "status": status,
        "transaction_ref": transactionRef,
    };
}

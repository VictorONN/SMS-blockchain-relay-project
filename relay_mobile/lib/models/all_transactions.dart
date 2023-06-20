// To parse this JSON data, do
//
//     final transactions = transactionsFromJson(jsonString);

import 'dart:convert';

List<Transactions> transactionsFromJson(String str) => List<Transactions>.from(json.decode(str).map((x) => Transactions.fromJson(x)));

String transactionsToJson(List<Transactions> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Transactions {
    int id;
    String purpose;
    int amount;
    String sender;
    dynamic receiver;

    Transactions({
        required this.id,
        required this.purpose,
        required this.amount,
        required this.sender,
        this.receiver,
    });

    factory Transactions.fromJson(Map<String, dynamic> json) => Transactions(
        id: json["id"],
        purpose: json["purpose"],
        amount: json["amount"],
        sender: json["sender"],
        receiver: json["receiver"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "purpose": purpose,
        "amount": amount,
        "sender": sender,
        "receiver": receiver,
    };
}

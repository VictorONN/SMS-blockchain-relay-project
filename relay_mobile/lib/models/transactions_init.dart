// To parse this JSON data, do
//
//     final transactionInit = transactionInitFromJson(jsonString);

import 'dart:convert';

TransactionInit transactionInitFromJson(String str) => TransactionInit.fromJson(json.decode(str));

String transactionInitToJson(TransactionInit data) => json.encode(data.toJson());

class TransactionInit {
    bool error;
    String message;
    List<dynamic> data;

    TransactionInit({
        required this.error,
        required this.message,
        required this.data,
    });

    factory TransactionInit.fromJson(Map<String, dynamic> json) => TransactionInit(
        error: json["error"],
        message: json["message"],
        data: List<dynamic>.from(json["data"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "error": error,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x)),
    };
}

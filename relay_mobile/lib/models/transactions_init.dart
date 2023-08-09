// To parse this JSON data, do
//
//     final transactionInit = transactionInitFromJson(jsonString);

import 'dart:convert';

TransactionInit transactionInitFromJson(String str) => TransactionInit.fromJson(json.decode(str));

String transactionInitToJson(TransactionInit data) => json.encode(data.toJson());

class TransactionInit {
    bool error;
    String message;
    Data data;

    TransactionInit({
        required this.error,
        required this.message,
        required this.data,
    });

    factory TransactionInit.fromJson(Map<String, dynamic> json) => TransactionInit(
        error: json["error"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "error": error,
        "message": message,
        "data": data.toJson(),
    };
}

class Data {
    String message;
    String customMessage;

    Data({
        required this.message,
        required this.customMessage,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        message: json["message"],
        customMessage: json["custom_message"],
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "custom_message": customMessage,
    };
}

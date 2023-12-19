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
    String statusCode;
    String message;
    String paymentGateway;
    String merchantReference;
    String transactionReference;
    String checkoutRequestId;
    String customerMessage;

    Data({
        required this.statusCode,
        required this.message,
        required this.paymentGateway,
        required this.merchantReference,
        required this.transactionReference,
        required this.checkoutRequestId,
        required this.customerMessage,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        statusCode: json["statusCode"],
        message: json["message"],
        paymentGateway: json["PaymentGateway"],
        merchantReference: json["MerchantReference"],
        transactionReference: json["TransactionReference"],
        checkoutRequestId: json["CheckoutRequestID"],
        customerMessage: json["CustomerMessage"],
    );

    Map<String, dynamic> toJson() => {
        "statusCode": statusCode,
        "message": message,
        "PaymentGateway": paymentGateway,
        "MerchantReference": merchantReference,
        "TransactionReference": transactionReference,
        "CheckoutRequestID": checkoutRequestId,
        "CustomerMessage": customerMessage,
    };
}

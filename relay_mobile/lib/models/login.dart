// To parse this JSON data, do
//
//     final login = loginFromJson(jsonString);

import 'dart:convert';

Login loginFromJson(String str) => Login.fromJson(json.decode(str));

String loginToJson(Login data) => json.encode(data.toJson());

class Login {
    bool error;
    String message;
    Data data;

    Login({
        required this.error,
        required this.message,
        required this.data,
    });

    factory Login.fromJson(Map<String, dynamic> json) => Login(
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
    String token;
    String phoneNumber;
    int id;
    String walletAccount;
    int depositRate;
    int withdrawRate;

    Data({
        required this.token,
        required this.phoneNumber,
        required this.id,
        required this.walletAccount,
        required this.depositRate,
        required this.withdrawRate,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        token: json["token"],
        phoneNumber: json["phone_number"],
        id: json["id"],
        walletAccount: json["wallet_account"],
        depositRate: json["deposit_rate"],
        withdrawRate: json["withdraw_rate"],
    );

    Map<String, dynamic> toJson() => {
        "token": token,
        "phone_number": phoneNumber,
        "id": id,
        "wallet_account": walletAccount,
        "deposit_rate": depositRate,
        "withdraw_rate": withdrawRate,
    };
}

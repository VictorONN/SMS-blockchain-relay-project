// To parse this JSON data, do
//
//     final userBalance = userBalanceFromJson(jsonString);

import 'dart:convert';

UserBalance userBalanceFromJson(String str) => UserBalance.fromJson(json.decode(str));

String userBalanceToJson(UserBalance data) => json.encode(data.toJson());

class UserBalance {
    bool error;
    String message;
    Data data;

    UserBalance({
        required this.error,
        required this.message,
        required this.data,
    });

    factory UserBalance.fromJson(Map<String, dynamic> json) => UserBalance(
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
    int blockchainBalance;
    int walletBalance;

    Data({
        required this.blockchainBalance,
        required this.walletBalance,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        blockchainBalance: json["blockchain_balance"],
        walletBalance: json["wallet_balance"],
    );

    Map<String, dynamic> toJson() => {
        "blockchain_balance": blockchainBalance,
        "wallet_balance": walletBalance,
    };
}

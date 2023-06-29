// To parse this JSON data, do
//
//     final userBalance = userBalanceFromJson(jsonString);

import 'dart:convert';

UserBalance userBalanceFromJson(String str) => UserBalance.fromJson(json.decode(str));

String userBalanceToJson(UserBalance data) => json.encode(data.toJson());

class UserBalance {
    int amount;
    int blockAmount;

    UserBalance({
        required this.amount,
        required this.blockAmount,
    });

    factory UserBalance.fromJson(Map<String, dynamic> json) => UserBalance(
        amount: json["amount"],
        blockAmount: json["block_amount"],
    );

    Map<String, dynamic> toJson() => {
        "amount": amount,
        "block_amount": blockAmount,
    };
}

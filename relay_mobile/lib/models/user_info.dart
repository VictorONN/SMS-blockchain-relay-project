// To parse this JSON data, do
//
//     final userInfo = userInfoFromJson(jsonString);

import 'dart:convert';

UserInfo userInfoFromJson(String str) => UserInfo.fromJson(json.decode(str));

String userInfoToJson(UserInfo data) => json.encode(data.toJson());

class UserInfo {
    int id;
    String phoneNumber;
    dynamic walletAccount;
    dynamic depositRate;
    dynamic withdrawRate;
    String privateKey;
    String address;

    UserInfo({
        required this.id,
        required this.phoneNumber,
        required this.walletAccount,
        required this.depositRate,
        required this.withdrawRate,
        required this.privateKey,
        required this.address,
    });

    factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
        id: json["id"],
        phoneNumber: json["phone_number"],
        walletAccount: json["wallet_account"],
        depositRate: json["deposit_rate"],
        withdrawRate: json["withdraw_rate"],
        privateKey: json["privateKey"],
        address: json["address"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "phone_number": phoneNumber,
        "wallet_account": walletAccount,
        "deposit_rate": depositRate,
        "withdraw_rate": withdrawRate,
        "privateKey": privateKey,
        "address": address,
    };
}

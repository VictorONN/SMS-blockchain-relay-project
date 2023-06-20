// To parse this JSON data, do
//
//     final userDetails = userDetailsFromJson(jsonString);

import 'dart:convert';

UserDetails userDetailsFromJson(String str) => UserDetails.fromJson(json.decode(str));

String userDetailsToJson(UserDetails data) => json.encode(data.toJson());

class UserDetails {
    int id;
    String phoneNumber;
    dynamic tillNumber;
    int userId;
    int amount;

    UserDetails({
        required this.id,
        required this.phoneNumber,
        this.tillNumber,
        required this.userId,
        required this.amount,
    });

    factory UserDetails.fromJson(Map<String, dynamic> json) => UserDetails(
        id: json["id"],
        phoneNumber: json["phone_number"],
        tillNumber: json["till_number"],
        userId: json["user_id"],
        amount: json["amount"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "phone_number": phoneNumber,
        "till_number": tillNumber,
        "user_id": userId,
        "amount": amount,
    };
}

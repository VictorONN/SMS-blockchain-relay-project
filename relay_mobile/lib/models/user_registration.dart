// To parse this JSON data, do
//
//     final userRegistration = userRegistrationFromJson(jsonString);

import 'dart:convert';

UserRegistration userRegistrationFromJson(String str) => UserRegistration.fromJson(json.decode(str));

String userRegistrationToJson(UserRegistration data) => json.encode(data.toJson());

class UserRegistration {
    bool error;
    String message;
    List<Datum> data;

    UserRegistration({
        required this.error,
        required this.message,
        required this.data,
    });

    factory UserRegistration.fromJson(Map<String, dynamic> json) => UserRegistration(
        error: json["error"],
        message: json["message"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "error": error,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Datum {
    int id;
    String phoneNumber;
    String address;
    String privateKey;

    Datum({
        required this.id,
        required this.phoneNumber,
        required this.address,
        required this.privateKey,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        phoneNumber: json["phone_number"],
        address: json["address"],
        privateKey: json["privateKey"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "phone_number": phoneNumber,
        "address": address,
        "privateKey": privateKey,
    };
}

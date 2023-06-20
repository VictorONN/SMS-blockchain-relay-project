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
    dynamic tillNumber;

    Data({
        required this.token,
        required this.phoneNumber,
        required this.id,
        this.tillNumber,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        token: json["token"],
        phoneNumber: json["phone_number"],
        id: json["id"],
        tillNumber: json["till_number"],
    );

    Map<String, dynamic> toJson() => {
        "token": token,
        "phone_number": phoneNumber,
        "id": id,
        "till_number": tillNumber,
    };
}

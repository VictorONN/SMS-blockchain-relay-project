// To parse this JSON data, do
//
//     final registration = registrationFromJson(jsonString);

import 'dart:convert';

Registration registrationFromJson(String str) => Registration.fromJson(json.decode(str));

String registrationToJson(Registration data) => json.encode(data.toJson());

class Registration {
    bool error;
    String message;
    List<dynamic> data;

    Registration({
        required this.error,
        required this.message,
        required this.data,
    });

    factory Registration.fromJson(Map<String, dynamic> json) => Registration(
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

// To parse this JSON data, do
//
//     final updateUser = updateUserFromJson(jsonString);

import 'dart:convert';

UpdateUser updateUserFromJson(String str) => UpdateUser.fromJson(json.decode(str));

String updateUserToJson(UpdateUser data) => json.encode(data.toJson());

class UpdateUser {
    bool error;
    String message;
    List<dynamic> data;

    UpdateUser({
        required this.error,
        required this.message,
        required this.data,
    });

    factory UpdateUser.fromJson(Map<String, dynamic> json) => UpdateUser(
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

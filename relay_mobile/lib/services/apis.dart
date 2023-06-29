import 'dart:convert';
import 'dart:ffi';

import 'package:relay_mobile/models/all_transactions.dart';
import 'package:relay_mobile/models/registration.dart';
import 'package:relay_mobile/models/update_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/login.dart';
import '../models/transactions_init.dart';
import '../models/userBalance.dart';
import '../models/user_details.dart';

class ApiService {
  Future<Login?> login(String phone, String password) async {
    final Map<String, dynamic> loginData = {
      'phone_number': phone,
      'password': password
    };
    var client = http.Client();

    final response = await client
        .post(Uri.parse('${api_url}auth/login/'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode(loginData))
        .catchError(
      (error) {
        print(error);
      },
    );

    if (response.statusCode == 200) {
      return loginFromJson(response.body);
    } else {
      return null;
    }
  }

  Future<Registration?> register(
      String phone, String till_number, String password) async {
    final Map<String, dynamic> registerData = {
      "till_number": till_number,
      "password": password,
      "phone_number": phone,
    };
    var client = http.Client();

    print(json.encode(registerData));
    final response = await client
        .post(Uri.parse('${api_url}agent/create/'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode(registerData))
        .catchError(
      (error) {
        print(error);
      },
    );

    if (response.statusCode == 200) {
      return registrationFromJson(response.body);
    } else {
      return null;
    }
  }

  Future<UserDetails?> getUserDetails(userid) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? token = prefs.getString('access');
    var client = http.Client();

    final response = await client
        .get(Uri.parse('${api_url}user/by_id/${userid}/'), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    }).catchError(
      (error) {
        print(error);
      },
    );

    if (response.statusCode == 200) {
      return userDetailsFromJson(response.body);
    } else {
      throw Exception('Failed to load user details');
    }
  }

  Future<List<Transactions>> getTransactionsAll() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? token = prefs.getString('access');
    var client = http.Client();

    final response =
        await client.get(Uri.parse('${api_url}transactions/all/'), headers: {
      'Content-Type': 'application/json',
      // 'Authorization': 'Bearer $token'
    }).catchError(
      (error) {
        print(error);
      },
    );

    if (response.statusCode == 200) {
      // print(response.body);
      return transactionsFromJson(response.body);
    } else {
      throw Exception('Failed to load transaction');
    }
  }

  Future<TransactionInit?> sendRelay(
      String sender, String receiver, String amount, int agent_id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final Map<String, dynamic> registerData = {
      "sender": sender,
      "receiver": receiver,
      "amount": amount,
      "agent_id": agent_id
    };
    final String? token = prefs.getString('access');
    var client = http.Client();

    final response = await client
        .post(Uri.parse('${api_url}transaction/send/'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token'
            },
            body: json.encode(registerData))
        .catchError(
      (error) {
        print(error);
      },
    );

    if (response.statusCode == 200) {
      return transactionInitFromJson(response.body);
    } else {
      return null;
    }
  }

  Future<TransactionInit?> withdrawRelay(
      String sender, String receiver, String amount, int agent_id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final Map<String, dynamic> registerData = {
      "sender": sender,
      "receiver": receiver,
      "amount": amount,
      "agent_id": agent_id
    };
    final String? token = prefs.getString('access');
    var client = http.Client();

    final response = await client
        .post(Uri.parse('${api_url}transaction/withdraw/'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token'
            },
            body: json.encode(registerData))
        .catchError(
      (error) {
        print(error);
      },
    );

    if (response.statusCode == 200) {
      return transactionInitFromJson(response.body);
    } else {
      return null;
    }
  }

  Future<TransactionInit?> registerRelay(String sender) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final Map<String, dynamic> registerData = {
      "phone_number": sender,
    };
    final String? token = prefs.getString('access');
    var client = http.Client();

    final response = await client
        .post(Uri.parse('${api_url}user/create/'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token'
            },
            body: json.encode(registerData))
        .catchError(
      (error) {
        print(error);
      },
    );

    if (response.statusCode == 200) {
      return transactionInitFromJson(response.body);
    } else {
      return null;
    }
  }

  Future<UpdateUser?> updateUser(userid, currency_rate) async {
    final Map<String, dynamic> updateData = {'currency_rate': currency_rate};
    var client = http.Client();

    final response = await client
        .patch(Uri.parse('${api_url}user/by_id/${userid}'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode(updateData))
        .catchError(
      (error) {
        print(error);
      },
    );

    if (response.statusCode == 200) {
      return updateUserFromJson(response.body);
    } else {
      return null;
    }
  }

  Future<UserBalance?> userBalance(String sender) async {
    var client = http.Client();

    final response = await client
        .get(Uri.parse('${api_url}balance/by_phone/${sender}'),
            headers: {
              'Content-Type': 'application/json',
            },)
        .catchError(
      (error) {
        print(error);
      },
    );

    if (response.statusCode == 200) {
      return userBalanceFromJson(response.body);
    } else {
      return null;
    }
  }
}

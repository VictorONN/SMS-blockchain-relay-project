import 'dart:convert';
import 'dart:ffi';

import 'package:relay_mobile/models/all_transactions.dart';
import 'package:relay_mobile/models/update_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/login.dart';
import '../models/transactions_init.dart';
// import '../models/userBalance.dart';
import '../models/user_balance.dart';

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
        final responseBody = json.decode(response.body); // Assuming you're working with JSON

        if (responseBody['error'] == true) {
          // Handle the error here as needed
          return null;
        } else {
          return loginFromJson(response.body);
        }
      } else {
        return null;
      }

  }

  Future<UserBalance?> getUserBalances(userid) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? token = prefs.getString('access');
    var client = http.Client();
    
    final Map<String, dynamic> userData = {
        "phone_number":prefs.getString('phone_number'),
        "wallet_account":prefs.getString('wallet_account')
      };

    final response = await client
        .post(Uri.parse('${api_url}get_agent_balance'), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    },body: json.encode(userData))
    .catchError(
      (error) {
        print(error);
      },
    );

    if (response.statusCode == 200) {
      print(response.body);
      return userBalanceFromJson(response.body);
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
      print(response.body);
      return transactionsFromJson(response.body);
    } else {
      throw Exception('Failed to load transaction');
    }
  }

  Future<List<Transactions>> getTransactionsByRef(reference) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? token = prefs.getString('access');
    var client = http.Client();

    final response =
        await client.get(Uri.parse('${api_url}transaction/status/${reference}'), headers: {
      'Content-Type': 'application/json',
      // 'Authorization': 'Bearer $token'
    }).catchError(
      (error) {
        print(error);
      },
    );

    if (response.statusCode == 200) {
      print("get status.....");
      print(response.body);
      return transactionsFromJson(response.body);
    } else {
      throw Exception('Failed to load transaction');
    }
  }

  Future<TransactionInit?> sendRelay(
      String sender, double amount, int agent_id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final Map<String, dynamic> registerData = {
      "sender": sender,
      "amount": amount,
      "agent_id": agent_id
    };
    print(registerData);
    final String? token = prefs.getString('access');
    var client = http.Client();

    final response = await client
        .post(Uri.parse('${api_url}transaction/deposit_to_wallet/'),
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
      print(response.body);
      return transactionInitFromJson(response.body);
    } else {
      return null;
    }
  }

  Future<TransactionInit?> withdrawRelay(
    String receiver, double amount, int agent_id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final Map<String, dynamic> registerData = {
      "receiver": receiver,
      "amount": amount,
      "agent_id": agent_id
    };
    final String? token = prefs.getString('access');
    var client = http.Client();

    final response = await client
        .post(Uri.parse('${api_url}transaction/withdraw_from_wallet/'),
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

  Future<UpdateUser?> updateUser(userid, deposit_rate,withdraw_rate) async {
    final Map<String, dynamic> updateData = {
      "deposit_rate":deposit_rate,
      "withdraw_rate":withdraw_rate
    };
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

}

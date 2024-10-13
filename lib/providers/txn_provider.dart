import 'package:cloud_firestore/cloud_firestore.dart' as cf;
import 'package:expense/utils/firebase_utils.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../utils/app_routes.dart';
import '../utils/contextServise.dart';
import '../models/transaction.dart';
import '../utils/utils.dart';
import '../utils/webservice.dart';
import 'dart:convert';

class TxnProvider with ChangeNotifier {
  BuildContext? context = NavigationService.navigatorKey.currentContext;

  List<Transaction> usertransaction = [];
  List<Transaction> fixedTransactions = [];

  void clearList() {
    usertransaction.clear();
    notifyListeners();
  }

  //session expire and go to login
  sessionExpired(BuildContext context) {
    Webservice.pref!.clear();
    Navigator.of(context).pushReplacementNamed(Approutes.login);
  }

  Future<void> notifyList() async {
    await Future.delayed(const Duration(milliseconds: 500));
    notifyListeners();
  }

  List<Transaction> get recentTransacation {
    return usertransaction.where((tx) {
      return tx.date!.isAfter(DateTime.now().subtract(
        const Duration(days: 7),
      ));
    }).toList();
  }

  //add balance
  Future addBalance(BuildContext context) async {
    if (Webservice.newBalance == '') {
      return;
    }
    if (!Webservice.isExecute) {
      final User user =
          Webservice.user.copy(balance: Webservice.newBalance.toString());

      final fUser = FirebaseUtils.usersCollection.doc(user.id);
      await fUser.set(user.toJson());
      final fUserData = await fUser.get();
      print(fUserData.data());
      final User newUser = User.fromJson(fUserData.data()!);
      await Webservice.pref!.clear();
      await Webservice.setUser(newUser);
      await Webservice.initUser();
    } else {
      print("Webservice.newBalance!");
      print(Webservice.newBalance!);
      String addingBal = double.parse(Webservice.newBalance!).toString();
      // (double.parse(Webservice.newBalance!) + Webservice.balance).toString();
      final url = Webservice.buildAddBalance(addingBal);
      print(url);
      final response = await http.post(url);
      print(response.body);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final status = responseData['status'];
        final msg = responseData['msg'].toString();
        if (status == 0) {
          Utils.buildshowTopSnackBar(context, Icons.close, msg, 'error');
          return;
        } else if (status == 2) {
          Utils.buildSnackbar(context!, msg);
          sessionExpired(context);
          return msg;
        } else if (status == 3) {
          Utils.showUpdateDialog(context);
          Utils.buildSnackbar(context!, msg);
          return msg;
        } else if (status == 1) {
          final user = Webservice.getUser();
          final newUser = user.copy(
              balance: responseData['data']['profile']['total_balance']);
          await Webservice.pref!.remove('user');
          Webservice.setUser(newUser);
          Webservice.initUser();
          notifyListeners();
          return true;
        }
      } else {
        return false;
      }
    }
  }

  //add new transaction
  void addNewTransaction(BuildContext context, String ttitle, double tamount,
      String txn_note, String choosenDate, bool isExpense, String from) async {
    try {
      var checkExpense = isExpense == true ? 'expense' : 'income';
      final totalBalance = isExpense
          ? (Webservice.balance - tamount)
          : (Webservice.balance + tamount);

      if (isExpense && double.parse(Webservice.user.balance) < tamount) {
        await Utils.buildshowTopSnackBar(
            context, Icons.monetization_on, 'No Sufficient Balance!', 'error');
        return;
      }
      // if (!Webservice.isExecute) {
      final txn = FirebaseUtils.transactionsCollection.doc();

      final Transaction newTxn = Transaction(
          id: txn.id,
          uid: Webservice.user.id,
          title: ttitle,
          amount: tamount,
          date: DateTime.parse(choosenDate),
          type: isExpense ? 1 : 2,
          note: txn_note);

      txn.set(newTxn.toJson());

      getTransactions(context);
      // } else {
      //   final url = Uri.parse(
      //       "${Webservice.baseurl}?action=AddTransaction&txn_title=$ttitle&from=$from&txn_amount=$tamount&txn_note=$txn_note&txn_date=$choosenDate&txn_type=$checkExpense&total_balance=$totalBalance&uid=${Webservice.uid}&login_token=${Webservice.logintoken}&app_token=${Webservice.apptoken}&app_version=${Webservice.appversion}&device_type=${Webservice.devicetype}");
      //   final response = await http.post(url);
      //   print(response.body);
      //   if (response.statusCode == 200) {
      //     final responseData = json.decode(response.body);
      //     final status = responseData['status'];
      //     final msg = responseData['msg'].toString();
      //     if (status == 0) {
      //       await Utils.buildshowTopSnackBar(
      //           context, Icons.close, msg, 'error');
      //       return;
      //     } else if (status == 2) {
      //       Utils.buildSnackbar(context!, msg);
      //       sessionExpired(context);
      //     } else if (status == 3) {
      //       Utils.showUpdateDialog(context);
      //       Utils.buildSnackbar(context!, msg);
      //     } else if (status == 1) {
      //       await Utils.buildshowTopSnackBar(
      //           NavigationService.navigatorKey.currentContext!,
      //           Icons.done,
      //           msg,
      //           'success');
      //       final newTX = Transaction(
      //           id: '',
      //           title: ttitle,
      //           amount: tamount,
      //           note: txn_note,
      //           date: DateTime.parse(choosenDate),
      //           type: isExpense ? 'expense' : 'income');
      //
      //       if (from == "home") {
      //         getTransactions(context);
      //       } else {
      //         getFixedTransactions(context);
      //       }
      //       final user = Webservice.getUser();
      //       final newUser =
      //           user.copy(balance: responseData['data']['total_balance']);
      //       await Webservice.pref!.remove('user');
      //       Webservice.setUser(newUser);
      //       Webservice.initUser();
      //       notifyListeners();
      //     } else {}
      //   } else {
      //     Utils.buildshowTopSnackBar(
      //         context, Icons.done, 'Something went wrong', 'success');
      //   }
      // }
    } catch (e) {
      Utils.buildshowTopSnackBar(context, Icons.close, e.toString(), 'error');
    }
  }

  //GetTransactionList
  Future getTransactions(BuildContext context) async {
    cf.QuerySnapshot<Map<String, dynamic>> txns = await FirebaseUtils
        .transactionsCollection
        .where('uid', isEqualTo: Webservice.user.id)
        .get();

    clearList();

    // usertransaction.addAll()

    if (txns.docs.isNotEmpty) {
      // print(txns.docs[0].data().toString());
      txns.docs
          .map((e) => usertransaction.add(Transaction.fromJson(e.data())))
          .toList();
    }
    notifyListeners();
  }

  Future<bool> deleteTransaction(BuildContext context, int type,
      Transaction transaction, String from) async {
    await FirebaseUtils.transactionsCollection.doc(transaction.id).delete();
    getTransactions(context);
    // try {
    // print(transaction.type);
    // final totalBalance = transaction.type == 'expense'
    //     ? (Webservice.balance + transaction.amount!)
    //     : (Webservice.balance - transaction.amount!);
    // Uri url;
    // if (from == "home") {
    //   url = Webservice.buildDeleteTransactionUrl(
    //       "home", transaction.id, totalBalance);
    // } else {
    //   url = Webservice.buildDeleteTransactionUrl(
    //       "fixed", transaction.id, totalBalance);
    // }
    // final response = await http.post(url);
    // print(response.body);
    // if (response.statusCode == 200) {
    //   final responseData = json.decode(response.body);
    //   final status = responseData['status'];
    //   final msg = responseData['msg'].toString();
    //   if (status == 0) {
    //     await Utils.buildshowTopSnackBar(context, Icons.close, msg, 'error');
    //     return false;
    //   } else if (status == 1) {
    //     await Utils.buildshowTopSnackBar(context, Icons.done, msg, 'success');
    //     if (from == 'home') {
    //       usertransaction.remove(transaction);
    //     } else {
    //       fixedTransactions.remove(transaction);
    //     }
    //
    //     final user = Webservice.getUser();
    //     final newUser = user.copy(
    //         balance: responseData['data']['balance']['total_balance']);
    //     Webservice.pref!.remove('user');
    //     Webservice.setUser(newUser);
    //     Webservice.initUser();
    //     notifyListeners();
    //     return true;
    //   } else if (status == 2) {
    //     Utils.buildshowTopSnackBar(context, Icons.close, msg, 'error');
    //     Utils.sessionExpired(context);
    //   }
    //   } else {}
    // } catch (e) {
    //   await Utils.buildshowTopSnackBar(
    //       context, Icons.close, e.toString(), 'error');
    // }
    return false;
  }

  //GetFixedTransactionList
  Future getFixedTransactions(BuildContext context) async {
    final url = Webservice.buildUrl('GetFixedTransactionList');
    final response = await http.post(url);

    // if (response.statusCode == 200) {
    //   print(response.body);
    //   final responseData = json.decode(response.body);
    //   final status = responseData['status'];
    //   final msg = responseData['msg'];
    //   if (status == 0) {
    //     // print(msg);
    //     final balance = responseData['data']['balance']['total_balance'];
    //     fixedTransactions.clear();
    //     notifyListeners();
    //   } else if (status == 1) {
    //     try {
    //       if (responseData['data']['fixed_transaction_list'] != []) {
    //         final txn = responseData['data']['fixed_transaction_list'];
    //
    //         fixedTransactions.clear();
    //         for (var value in txn) {
    //           final newTxn = Transaction(
    //               id: value['txn_id'],
    //               title: value['txn_title'],
    //               note: value['txn_note'],
    //               amount: double.parse(value['txn_amount']),
    //               date: DateTime.now(),
    //               type: 'expense');
    //           fixedTransactions.add(newTxn);
    //         }
    //       } else {
    //         return msg;
    //       }
    //       notifyListeners();
    //     } catch (e) {
    //       Utils.showErrorDialog(context, e.toString());
    //     }
    //   } else if (status == 2) {
    //     Utils.buildSnackbar(context!, msg);
    //     sessionExpired(context);
    //     return msg;
    //   } else if (status == 3) {
    //     Utils.showUpdateDialog(context);
    //     Utils.buildSnackbar(context!, msg);
    //     return msg;
    //   }
    // } else {
    //   Utils.showErrorDialog(context, response.statusCode.toString());
    // }
  }

  Future<bool> doneTransaction(
      BuildContext context, Transaction transaction, String from) async {
    // try {
    //   final url = Webservice.buildDoneUrl(transaction.id);
    //
    //   final response = await http.post(url);
    //   print(response.body);
    //   if (response.statusCode == 200) {
    //     final responseData = json.decode(response.body);
    //     final status = responseData['status'];
    //     final msg = responseData['msg'].toString();
    //     if (status == 0) {
    //       await Utils.buildshowTopSnackBar(context, Icons.close, msg, 'error');
    //       return false;
    //     } else if (status == 1) {
    //       await Utils.buildshowTopSnackBar(context, Icons.done, msg, 'success');
    //
    //       fixedTransactions.remove(transaction);
    //       notifyListeners();
    //       return true;
    //     } else if (status == 2) {
    //       Utils.buildSnackbar(context!, msg);
    //       sessionExpired(context);
    //     } else if (status == 3) {
    //       Utils.showUpdateDialog(context);
    //       Utils.buildSnackbar(context!, msg);
    //     }
    //   } else {}
    // } catch (e) {
    //   await Utils.buildshowTopSnackBar(
    //       context, Icons.close, e.toString(), 'error');
    // }
    return false;
  }
}

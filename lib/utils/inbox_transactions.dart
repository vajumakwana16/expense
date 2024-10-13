import 'package:expense/utils/utils.dart';
import 'package:expense/utils/webservice.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

import '../models/transaction.dart';
import 'contextServise.dart';

class InboxTransactions {
  //get inbox transactions
  static getInboxTransaction() async {
    List<Transaction> tList = [];
    SmsQuery query = SmsQuery();
    await query.querySms(
      kinds: [SmsQueryKind.inbox],
    ).then((List<SmsMessage> messages) async {
      for (SmsMessage message in messages) {
        if (isBankMessage(message.body.toString())) {
          double amount = 0.0;
          int? isExpense;
          DateTime dateTime = DateTime.now();

          final msg = message.body.toString();

          if (msg.toLowerCase().contains("debited") ||
              msg.toLowerCase().contains("withdrawn")) {
            isExpense = 1;
          }

          if (msg.toLowerCase().contains("credited") ||
              msg.toLowerCase().contains("deposited")) {
            isExpense = 0;
          }

          //date
          // final date = DateTime.parse(fetchDateFromTransaction(msg));
          final credited = await fetchCreditedAmount(msg);
          final debited = await fetchTransferredAmount(msg);
          // amount = isExpense == 0 ? credited : debited;
          try {
            Transaction transaction = Transaction(
                title: "untitled",
                amount: isExpense == 0 ? credited : debited,
                uid: Webservice.user.id,
                date: dateTime,
                type: isExpense);

            if (credited > 0 || debited > 0) {
              tList.add(transaction);
            }
          } catch (e) {
            Utils.showErrorDialog(
                NavigationService.navigatorKey.currentContext!, e.toString());
          }
        }
      }
    });

    return tList;
  }

  //get inbox transactions
  static getInboxExpenses() async {
    List<Transaction> tList = [];
    SmsQuery query = SmsQuery();
    await query.querySms(
      kinds: [SmsQueryKind.inbox],
    ).then((List<SmsMessage> messages) async {
      for (SmsMessage message in messages) {
        if (containsMoneyTransactionInfo(message.body.toString())) {
          double amount = 0.0;
          int isExpense = 0;
          DateTime dateTime = DateTime.now();

          final msg = message.body.toString();

          if (msg.toLowerCase().contains("debited") ||
              msg.toLowerCase().contains("withdrawn")) {
            isExpense = 1;
          }

          final date = fetchDateFromTransaction(msg);
          final debited = await fetchTransferredAmount(msg);
          try {
            if (debited > 0) {
              final title = extractEntity(message.body.toString());
              Transaction transaction = Transaction(
                  title: title ?? "You",
                  amount: debited,
                  uid: Webservice.user.id,
                  date: date,
                  inboxMsg: message.body.toString(),
                  type: 1);

              tList.add(transaction);
            }
          } catch (e) {
            Utils.showErrorDialog(
                NavigationService.navigatorKey.currentContext!, e.toString());
          }
        }
      }
    });

    return tList;
  }

  //get inbox transactions
  static getInboxIncomes() async {
    List<Transaction> tList = [];
    SmsQuery query = SmsQuery();
    await query.querySms(
      kinds: [SmsQueryKind.inbox],
    ).then((List<SmsMessage> messages) async {
      for (SmsMessage message in messages) {
        if (containsMoneyTransactionInfo(message.body.toString())) {
          double amount = 0.0;
          int isExpense = 0;
          DateTime dateTime = DateTime.now();

          final msg = message.body.toString();

          if (msg.toLowerCase().contains("credited") ||
              msg.toLowerCase().contains("deposited")) {
            isExpense = 0;
          }

          //date
          // final date = DateTime.parse(fetchDateFromTransaction(msg));
          final date = fetchDateFromTransaction(msg);
          final credited = await fetchCreditedAmount(msg);
          try {
            if (credited > 0) {
              final title = extractEntity(message.body.toString());

              Transaction transaction = Transaction(
                  title: title ?? "untitled",
                  amount: credited,
                  uid: Webservice.user.id,
                  date: date,
                  inboxMsg: message.body.toString(),
                  type: 0);

              tList.add(transaction);
            }
          } catch (e) {
            Utils.showErrorDialog(
                NavigationService.navigatorKey.currentContext!, e.toString());
          }
        }
      }
    });

    return tList;
  }

  //fetch money string
  static double fetchTotalBal(String msg) {
    RegExp totalBalanceRegex = RegExp(r'Avlbl Amt:Rs\.(\d+(\.\d{1,2})?)');

    RegExpMatch? totalBalanceMatch = totalBalanceRegex.firstMatch(msg);
    double? totalBalance;
    if (totalBalanceMatch != null) {
      totalBalance = double.parse(totalBalanceMatch.group(1).toString());
      // print("Total Balance: Rs $totalBalance");
      return totalBalance;
    }
    return 0.0;
  }

  //fetch transferred string
  static double fetchTransferredAmount(String msg) {
    RegExp transferredAmountRegex =
        RegExp(r'Rs\.(\d+(\.\d{1,2})?) transferred from A/c');
    RegExpMatch? transferredAmountMatch =
        transferredAmountRegex.firstMatch(msg);
    double? transferredAmount;
    if (transferredAmountMatch != null) {
      transferredAmount =
          double.parse(transferredAmountMatch.group(1).toString());
      // print("Transferred Amount: Rs $transferredAmount");
      return transferredAmount;
    }
    return 0.0;
  }

  //fetch credited string
  static double fetchCreditedAmount(String msg) {
    RegExp transferredAmountRegex =
        RegExp(r'Rs\.(\d+(\.\d{1,2})?) Credited to A/c');
    RegExpMatch? transferredAmountMatch =
        transferredAmountRegex.firstMatch(msg);
    double? transferredAmount;
    if (transferredAmountMatch != null) {
      transferredAmount =
          double.parse(transferredAmountMatch.group(1).toString());
      // print("Transferred Amount: Rs $transferredAmount");
      return transferredAmount;
    }
    return 0.0;
  }

  //fetch date string
  static fetchDateFromTransaction(String msg) {
    RegExp dateRegex = RegExp(r'\((\d{2}-\d{2}-\d{4} \d{2}:\d{2}:\d{2})\)');
    RegExpMatch? dateMatch = dateRegex.firstMatch(msg);
    String? date;
    if (dateMatch != null) {
      date = dateMatch.group(1);

      // Split date and time
      List<String> parts = date!.split(' ');
      List<String> dateParts = parts[0].split('-');
      List<String> timeParts = parts[1].split(':');

      // Create a DateTime object
      return DateTime(
        int.parse(dateParts[2]), // Year
        int.parse(dateParts[1]), // Month
        int.parse(dateParts[0]), // Day
        int.parse(timeParts[0]), // Hour
        int.parse(timeParts[1]), // Minute
        int.parse(timeParts[2]), // Second
      );

      // return dateTime;
    }
    return "";
  }

  static bool isBankMessage(String message) {
    final bankKeywords = [
      'credited',
      'debited',
      'balance',
      'transferred',
    ];
    for (var keyword in bankKeywords) {
      if (message.toLowerCase().contains(keyword.toLowerCase())) {
        return true;
      }
    }
    return false;
  }

  static bool containsMoneyTransactionInfo(String messageBody) {
    return messageBody.contains("Bal:Rs");
    // return messageBody.contains("transaction") || messageBody.contains("money");
  }

  // Function to extract entity (sender) from a message string
  static String? extractEntity(String message) {
    // Define regular expression to capture the sender's name after "by"
    final RegExp entityPattern = RegExp(r"by\s+([A-Za-z\s]+)");

    // Try to find a match
    final match = entityPattern.firstMatch(message);

    if (match != null && match.groupCount >= 1) {
      return match.group(1)?.trim(); // Return the sender's name
    }

    return null; // Return null if no match found
  }
}

/*
class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String type;
  final String note;

  Transaction(
      {required this.id,
      required this.title,
      required this.amount,
      required this.date,
      required this.type,
      required this.note});
}
*/

class Transaction {
  String? id;
  String? uid;
  String? title;
  double? amount;
  DateTime? date;
  String? inboxMsg;
  int? type; //1=expense, 2=income, 3=transfer
  String? note;

  Transaction(
      {this.id,
      this.uid,
      this.title,
      this.amount,
      this.date,
      this.inboxMsg,
      this.type,
      this.note});

  Transaction.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uid = json['uid'];
    title = json['title'];
    amount = double.parse(json['amount'].toString());
    date = DateTime.now();
    // date = DateTime.parse(json['date'].toString());
    type = int.parse(json['type'].toString());
    note = json['note'].toString();
    inboxMsg = json['inboxMsg'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['uid'] = this.uid;
    data['title'] = this.title;
    data['amount'] = this.amount;
    data['date'] = this.date;
    data['type'] = this.type;
    data['note'] = this.note;
    data['inboxMsg'] = this.inboxMsg;
    return data;
  }

  static TxnType getTxnType(int type) {
    if (type == 1) {
      return TxnType.expense;
    } else if (type == 2) {
      return TxnType.income;
    } else if (type == 3) {
      return TxnType.transfer;
    } else {
      return TxnType.expense;
    }
  }

  static int setTxnType(TxnType type) {
    if (type == TxnType.expense) {
      return 1;
    } else if (type == TxnType.income) {
      return 2;
    } else if (type == TxnType.transfer) {
      return 3;
    } else {
      return 1;
    }
  }
}

enum TxnType { income, expense, transfer }

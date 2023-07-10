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

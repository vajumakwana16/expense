import '../models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/webservice.dart';
import './chart_bar.dart';

class Chart extends StatelessWidget {
  final List<Transaction> recentTransaction;
  const Chart(this.recentTransaction, {Key? key}) : super(key: key);

  List<Map<String, Object>> get groupedTransactionValues {
    return List.generate(7, (index) {
      final weekDay = DateTime.now().subtract(
        Duration(days: index),
      );
      double totalSum = 0.0;
      for (var i = 0; i < recentTransaction.length; i++) {
        if (recentTransaction[i].date.day == weekDay.day &&
            recentTransaction[i].date.month == weekDay.month &&
            recentTransaction[i].date.year == weekDay.year) {
          totalSum += recentTransaction[i].amount;
        }
      }

      return {
        'day': DateFormat.E().format(weekDay).substring(0, 1),
        'amount': totalSum,
      };
      // return {'day': 'T', 'amount': 9.99};
    }).reversed.toList();
  }

  double get totalSpending {
    return groupedTransactionValues.fold(0.0, (sum, item) {
      return sum + (item['amount'] as double);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkkmode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
          border: Border.all(width: 0.4, color: Colors.white),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(5, 5),
              blurRadius: 5,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.black12,
              offset: Offset(-5, -5),
              blurRadius: 5,
              spreadRadius: 1,
            )
          ],
          borderRadius: BorderRadius.circular(20),
          color: isDarkkmode
              ? Theme.of(context).primaryColor
              : Webservice.bgColor),
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: groupedTransactionValues.map((data) {
          return Flexible(
            fit: FlexFit.tight,
            child: ChartBar(
              data['day'] as String,
              data['amount'] as double,
              totalSpending == 0.0
                  ? 0.0
                  : (data['amount'] as double) / totalSpending,
            ),
          );
        }).toList(),
      ),
    );
  }
}

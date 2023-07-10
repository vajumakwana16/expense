import 'dart:core';

import '../utils/webservice.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_previder.dart';

class ChartBar extends StatelessWidget {
  final String label;
  final double spendingAmount;
  final double spendingPctOfTotal;

  const ChartBar(this.label, this.spendingAmount, this.spendingPctOfTotal,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formate = Webservice.formateNumber(spendingAmount);
    final themeProvider = Provider.of<ThemeProvider>(context);
    return LayoutBuilder(builder: (ctx, constraints) {
      return Column(
        children: <Widget>[
          SizedBox(height: constraints.maxHeight * 0.05),
          SizedBox(
            height: constraints.maxHeight * 0.1,
            child: FittedBox(
              // child: Text('\₹${spendingAmount.toStringAsFixed(0)}',
              child: Text(formate),
            ),
          ),
          SizedBox(height: constraints.maxHeight * 0.05),
          SizedBox(
            height: constraints.maxHeight * 0.6,
            width: 10,
            child: Stack(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1.0),
                    color: themeProvider.isDarkMode
                        ? Theme.of(context).canvasColor
                        : const Color.fromRGBO(220, 220, 220, 1),
                    // color: const Color.fromRGBO(220, 220, 220, 1),
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: spendingPctOfTotal,
                    child: Container(
                      margin: const EdgeInsets.only(top: 1),
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode
                            ? Theme.of(context).secondaryHeaderColor
                            : Theme.of(context).primaryColor,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: constraints.maxHeight * 0.05,
          ),
          SizedBox(
              height: constraints.maxHeight * 0.1,
              child: FittedBox(child: Text(label))),
        ],
      );
    });
  }
}

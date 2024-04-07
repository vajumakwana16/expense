import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_previder.dart';
import '../providers/txn_provider.dart';
import '../utils/utils.dart';
import '../utils/webservice.dart';
import '../widgets/transaction_list.dart';

class Fixed extends StatefulWidget {
  const Fixed({Key? key}) : super(key: key);

  @override
  State<Fixed> createState() => _FixedState();
}

class _FixedState extends State<Fixed> {
  ScrollController scrollController = ScrollController();
  bool isInit = false;
  bool isshowBody = false;
  @override
  void initState() {
    setState(() {
      isInit = true;
    });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  bool isTaped = false;
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final txnProvider = Provider.of<TxnProvider>(context);
    final height = MediaQuery.of(context).size.height;

    if (isInit) {
      txnProvider.getFixedTransactions(context).then((value) {
        if (value != null) {
          setState(() {
            isInit = false;
          });
        } else {
          setState(() {
            isInit = false;
            isshowBody = true;
          });
        }
      });
    }

    //transaction list widget
    final txList = SizedBox(
        child:
            TransactionList(from: "fixed", scrollController: scrollController));

    //body
    final pageBody = txList;

    return Scaffold(
        backgroundColor: themeProvider.isDarkMode
            ? Theme.of(context).primaryColor
            : Webservice.bgColor,
        appBar: Utils.buildAppbar(context, 'Fixed Transactions'),
        // body: Stack(children: [
        //   Align(
        //     alignment: Alignment.topRight,
        //     child: AnimatedContainer(
        //         alignment: Alignment.topCenter,
        //         duration: const Duration(seconds: 1),
        //         child: Padding(
        //           padding: EdgeInsets.only(top: height * 0.01),
        //           child: Text(
        //             'Monthly Transactions',
        //             style: TextStyle(
        //                 color: Theme.of(context).backgroundColor,
        //                 fontSize: 25,
        //                 fontWeight: FontWeight.bold),
        //           ),
        //         ),
        //         height: height * 0.08,
        //         decoration: BoxDecoration(
        //           color: themeProvider.isDarkMode
        //               ? Theme.of(context).accentColor
        //               : Theme.of(context).primaryColor,
        //           borderRadius: const BorderRadius.only(
        //               bottomLeft: Radius.circular(50),
        //               bottomRight: Radius.circular(50)),
        //         )),
        //   ),
        body: SizedBox(
          // margin: EdgeInsets.only(top: height * 0.1),
          height: height * 0.95,
          child: isInit ? Utils.showProgressIndicator(context) : pageBody,
        ));
    // ]));
  }
}

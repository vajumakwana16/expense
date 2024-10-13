import '../providers/theme_previder.dart';
import '../utils/utils.dart';
import '../providers/txn_provider.dart';
import '../utils/webservice.dart';
import 'package:flutter/material.dart';
import '../widgets/chart.dart';
import 'package:provider/provider.dart';

import '../widgets/transaction_list.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late final AnimationController _controller;
  ScrollController scrollController = ScrollController();
  bool _showChart = false;
  bool isAuthenticated = false;
  bool isInit = false;
  bool isshowBody = false;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    setState(() {
      isInit = true;
    });
    scrollController.addListener(() {
      // print(scrollController.offset);
      if (!_showChart) {
        setState(() {
          _showChart = scrollController.offset > 50;
        });
      } else if (scrollController.offset == -0) {
        setState(() {
          _showChart = false;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final txnProvider = Provider.of<TxnProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);

    if (isInit) {
      txnProvider.getTransactions(context).then((value) {
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

    //androidAppbar
    final PreferredSizeWidget appbar = Utils.buildAppbar(context, 'Expense');

    //transaction list widget
    final txList = SizedBox(
        height: _showChart
            ? (mediaQuery.size.height - mediaQuery.padding.top) * 1
            : (mediaQuery.size.height - mediaQuery.padding.top) * 0.7,
        child:
            TransactionList(from: "home", scrollController: scrollController));
    // child: TransactionList(txn.usertransaction, txn.deleteTransaction));

    //chart widget
    final txChart = AnimatedOpacity(
        opacity: _showChart ? 0 : 1,
        duration: const Duration(seconds: 1),
        child: AnimatedContainer(
            alignment: Alignment.topCenter,
            duration: _showChart
                ? const Duration(seconds: 1)
                : const Duration(milliseconds: 900),
            height: _showChart
                ? 0
                : (mediaQuery.size.height -
                        appbar.preferredSize.height -
                        mediaQuery.padding.top) *
                    0.3,
            child: Chart(txnProvider.recentTransacation)));

    //body
    final pageBody = SafeArea(
      child: RefreshIndicator(
        strokeWidth: 3,
        edgeOffset: 20,
        displacement: 0,
        // triggerMode: RefreshIndicatorTriggerMode.onEdge,
        onRefresh: () async => await txnProvider.getTransactions(context),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              txChart,
              txList,
            ],
          ),
        ),
      ),
    );

    return Scaffold(
        backgroundColor: theme.isDarkMode
            ? Theme.of(context).primaryColor
            : Webservice.bgColor,
        extendBodyBehindAppBar: true,
        appBar: !_showChart ? appbar : null,
        body: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: AnimatedContainer(
                  alignment: Alignment.topCenter,
                  duration: const Duration(seconds: 1),
                  height: _showChart
                      ? 0
                      : (mediaQuery.size.height -
                              appbar.preferredSize.height -
                              mediaQuery.padding.top) *
                          0.34,
                  decoration: BoxDecoration(
                    color: theme.isDarkMode
                        ? Theme.of(context).secondaryHeaderColor
                        : Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(50)),
                  )),
            ),
            isInit
                ? (isshowBody ? pageBody : Utils.showProgressIndicator(context))
                : pageBody
          ],
        ));
  }
}

/**
 background for slideble
 * 
 Widget slideBackground(bool isRight) {
      return Container(
        decoration: Utils.buildBoxDecoration(10, Colors.red),
        margin: const EdgeInsets.only(top: 20, bottom: 0, left: 20, right: 20),
        child: Align(
          child: Row(
            mainAxisAlignment:
                isRight ? MainAxisAlignment.start : MainAxisAlignment.end,
            children: const [
              SizedBox(
                width: 20,
              ),
              Icon(
                Icons.delete,
                color: Colors.white,
              ),
              SizedBox(
                width: 20,
              ),
            ],
          ),
          alignment: Alignment.centerRight,
        ),
      );
    }

 */

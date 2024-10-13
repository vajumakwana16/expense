import '../providers/txn_provider.dart';
import '../utils/utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../screen/detail_page.dart';
import '../utils/webservice.dart';

class TransactionList extends StatefulWidget {
  // final List<Transaction> transaction;
  // final Function deletTransaction;
  // const TransactionList(this.transaction, this.deletTransaction, {Key? key}): super(key: key);
  final String from;
  final ScrollController scrollController;
  const TransactionList(
      {required this.from, required this.scrollController, Key? key})
      : super(key: key);

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool isLoading = false;
  //check from where screen
  @override
  Widget build(BuildContext context) {
    bool fromHome = widget.from == "home" ? true : false;
    final txnProvider = Provider.of<TxnProvider>(context);
    final slidablekey = UniqueKey();
    List<Transaction> txnList =
        fromHome ? txnProvider.usertransaction : txnProvider.fixedTransactions;
    return txnList.isEmpty
        ? LayoutBuilder(builder: (ctx, constraints) {
            return RefreshIndicator(
              strokeWidth: 3,
              edgeOffset: 20,
              displacement: 0,
              triggerMode: RefreshIndicatorTriggerMode.onEdge,
              onRefresh: () {
                return fromHome
                    ? txnProvider.getTransactions(context)
                    : txnProvider.getFixedTransactions(context);
              },
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  const SizedBox(height: 30),
                  Center(
                    child: Text(
                      fromHome
                          ? "No transaction added yet!"
                          : "No Fixed transaction added yet!",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).appBarTheme.titleTextStyle,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: constraints.maxHeight * 0.6,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Lottie.asset('assets/raw/no_transaction.json',
                          controller: _controller, onLoaded: (composition) {
                        _controller
                          ..duration = composition.duration
                          ..forward();

                        _controller.repeat();
                      }),
                    ),
                  ),
                ],
              ),
            );
          })
        : isLoading
            ? Utils.showProgressIndicator(context)
            : RefreshIndicator(
                strokeWidth: 3,
                edgeOffset: 20,
                displacement: 0,
                triggerMode: RefreshIndicatorTriggerMode.onEdge,
                onRefresh: () {
                  return txnProvider.notifyList();
                },
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    controller:
                        txnList.length > 10 ? widget.scrollController : null,
                    itemBuilder: (ctx, index) {
                      return Container(
                        margin:
                            const EdgeInsets.only(top: 20, left: 20, right: 20),
                        child: Slidable(
                          dragStartBehavior: DragStartBehavior.down,
                          enabled: true,
                          closeOnScroll: true,
                          direction: Axis.horizontal,
                          endActionPane: ActionPane(
                            key: slidablekey,
                            extentRatio: fromHome ? 0.2 : 0.5,
                            dragDismissible: false,
                            motion: const DrawerMotion(),
                            dismissible: DismissiblePane(
                              onDismissed: () async {
                                // await txnProvider.deleteTransaction(
                                //     context,
                                //     txnList[index].type,
                                //     txnList[index],
                                //     fromHome ? "home" : "fixed");
                              },
                            ),
                            children: [
                              SlidableAction(
                                borderRadius: BorderRadius.circular(20),
                                padding: EdgeInsets.zero,
                                onPressed: (ctx) async {
                                  await txnProvider.deleteTransaction(
                                      context,
                                      txnList[index].type!,
                                      txnList[index],
                                      widget.from);
                                },
                                backgroundColor: const Color(0xFFFE4A49),
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Delete',
                              ),
                              if (!fromHome)
                                SlidableAction(
                                  borderRadius: BorderRadius.circular(20),
                                  padding: EdgeInsets.zero,
                                  onPressed: (ctx) async {
                                    await txnProvider.doneTransaction(
                                        context,
                                        txnList[index],
                                        fromHome ? "home" : "fixed");
                                  },
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  icon: Icons.done_all,
                                  label: 'Done',
                                ),
                            ],
                          ),
                          key: UniqueKey(),
                          child: Container(
                            decoration: Utils.buildBoxDecoration(
                                context, 20, Webservice.bgColor!),
                            child: ListTile(
                              onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (ctx) =>
                                          DetailPage(txn: txnList[index]))),
                              leading: FittedBox(
                                  child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    radius: 30,
                                    child: Text(
                                        Webservice.formateNumber(
                                            txnList[index].amount),
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontFamily: 'Quicksand',
                                          fontSize: 18,
                                          color: txnList[index].type == 1
                                              ? Colors.red
                                              : Colors.green,
                                        ))),
                              )),
                              title: Text(
                                txnList[index].title!,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              subtitle: Text(
                                DateFormat.yMMMEd()
                                    .format(txnList[index].date!),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              trailing: fromHome
                                  ? txnList[index].type == 1
                                      ? const Icon(
                                          Icons.arrow_upward,
                                          color: Colors.red,
                                        )
                                      : const Icon(
                                          Icons.arrow_downward,
                                          color: Colors.green,
                                        )
                                  : const SizedBox(),
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: txnList.length),
              );
  }
}

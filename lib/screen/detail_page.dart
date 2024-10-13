import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../utils/utils.dart';
import '../utils/webservice.dart';

class DetailPage extends StatefulWidget {
  final Transaction txn;
  const DetailPage({Key? key, required this.txn}) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  String name = Webservice.name;

  String phone = Webservice.phone;

  String email = Webservice.email;

  String profileImage = Webservice.profileimage;

  onImageTap() {}

  onChangeName(value) {
    name = value;
  }

  onChangeEmail(value) {
    email = value;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final height = mediaQuery.size.height;
    final width = mediaQuery.size.width;
    final isDarkmode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
        backgroundColor:
            isDarkmode ? Theme.of(context).primaryColor : Webservice.bgColor,
        appBar: Utils.buildAppbar(context, 'Transaction Detail'),
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: width * 0.05),
          children: [
            Utils.sizedBox(height * 0.1, 0.2),
            Container(
                padding: const EdgeInsets.all(8),
                decoration:
                    Utils.buildBoxDecoration(context, 10, Webservice.bgColor!),
                child: Utils.buildEditText(
                    context,
                    true,
                    widget.txn.title.toString(),
                    'Enter Title',
                    'Title',
                    onChangeName,
                    'Enter valid title')),
            Utils.sizedBox(height * 0.1, 0.2),
            Container(
                padding: const EdgeInsets.all(8),
                decoration:
                    Utils.buildBoxDecoration(context, 10, Webservice.bgColor!),
                child: Utils.buildEditText(
                    context,
                    false,
                    widget.txn.amount.toString(),
                    'Enter Amount',
                    'Amount',
                    (value) {},
                    'Enter valid amount')),
            Utils.sizedBox(height * 0.1, 0.2),
            Container(
                padding: const EdgeInsets.all(8),
                decoration:
                    Utils.buildBoxDecoration(context, 10, Webservice.bgColor!),
                child: Utils.buildEditText(
                    context,
                    true,
                    DateFormat.yMMMEd().format(widget.txn.date!),
                    'Enter Date',
                    'Date',
                    onChangeEmail,
                    'Enter valid Date')),
            if (widget.txn.note.toString() != "")
              Utils.sizedBox(height * 0.1, 0.2),
            if (widget.txn.note.toString() != "")
              Container(
                  padding: const EdgeInsets.all(8),
                  decoration: Utils.buildBoxDecoration(
                      context, 10, Webservice.bgColor!),
                  child: Utils.buildEditText(
                      context,
                      false,
                      widget.txn.note.toString(),
                      'Enter Note',
                      'Note',
                      (value) {},
                      '')),
            Utils.sizedBox(height * 0.1, 0.2),
            Container(
                padding: const EdgeInsets.all(8),
                decoration:
                    Utils.buildBoxDecoration(context, 10, Webservice.bgColor!),
                child: Utils.buildEditText(
                    context,
                    true,
                    widget.txn.type.toString(),
                    'Enter Type',
                    'Type',
                    onChangeEmail,
                    'Enter valid Type')),
            Utils.sizedBox(height * 0.1, 0.5),

            // Center(
            //   child: Utils.buildButton(() async {
            //     if (name.isNotEmpty && email.isNotEmpty) {
            //       // await updateProvider.updateProfile(context, name, email);
            //     }
            //   }, 'Save', true),
            // ),
          ],
        ));
  }
}

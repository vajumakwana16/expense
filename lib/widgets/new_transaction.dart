import '../utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewTransaction extends StatefulWidget {
  final Function addT;
  final String from;
  const NewTransaction({Key? key, required this.addT, required this.from})
      : super(key: key);
  //NewTransaction({required this.addT});

  @override
  State<NewTransaction> createState() => _NewTransactionState();
}

class _NewTransactionState extends State<NewTransaction> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _selectedDate = "";

  void _submitData() {
    FocusScope.of(context).unfocus();
    try {
      final enteredTitle = _titleController.text;
      final enteredAmount;
      if (_amountController.text != '') {
        enteredAmount = double.parse(_amountController.text);
      } else {
        enteredAmount = 0;
      }
      if (enteredTitle.isEmpty) {
        Utils.buildshowTopSnackBar(
            context, Icons.close, 'title cannot be empty', 'error');
      } else if (enteredAmount == 0 ||
          enteredAmount.isNegative ||
          enteredAmount.isInfinite ||
          enteredAmount.isNaN) {
        Utils.buildshowTopSnackBar(
            context, Icons.close, 'enter valid amount', 'error');
      } else if (_selectedDate.isEmpty) {
        Utils.buildshowTopSnackBar(
            context, Icons.close, 'select valid date', 'error');
      } else {
        widget.addT(context, enteredTitle, enteredAmount, _noteController.text,
            _selectedDate, isExpense, widget.from);
        Navigator.of(context).pop();
      }
    } catch (e) {
      Utils.buildshowTopSnackBar(context, Icons.close, e.toString(), 'error');
    }
  }

  void _presentDatePicker() {
    FocusScope.of(context).unfocus();
    showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2022),
            lastDate: DateTime.now())
        .then((pickedDate) {
      if (pickedDate == null) {
        return;
      } else {
        setState(() {
          _selectedDate = pickedDate.toString();
        });
      }
    });
  }

  bool isExpense = true;

  bool isGrocery = false;
  bool isPersonal = false;
  bool isInvestment = false;
  bool isTransportation = false;
  bool isOthers = false;
  Color color = Colors.red;
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final height = mediaQuery.size.height;
    // print(isExpense);
    color = isExpense ? Colors.red : Colors.green;

    return Card(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
              left: 10,
              right: 10,
              top: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 10),
          child: Column(
            children: [
              Center(
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(10)),
                      width: 50,
                      height: 5)),
              SizedBox(height: height * 0.01),
              Center(
                child: Text(
                  'New Transaction',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              SizedBox(height: height * 0.01),
              DefaultTabController(
                  animationDuration: const Duration(seconds: 1),
                  length: 2,
                  child: Builder(builder: (BuildContext context) {
                    final TabController tabController =
                        DefaultTabController.of(context);
                    tabController.addListener(() {
                      if (tabController.index != 0) {
                        setState(() {
                          isExpense = false;
                        });
                      } else {
                        setState(() {
                          isExpense = true;
                        });
                      }
                    });
                    return TabBar(
                        indicatorColor: isExpense ? Colors.red : Colors.green,
                        labelColor: isExpense ? Colors.red : Colors.green,
                        unselectedLabelColor: Theme.of(context).disabledColor,
                        controller: tabController,
                        tabs: const [
                          Tab(text: 'Expense'),
                          Tab(text: 'Income')
                        ]);
                  })),
              SizedBox(height: height * 0.02),
              TextField(
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                    labelText: 'Title', border: OutlineInputBorder()),
                controller: _titleController,
                onSubmitted: (_) => _submitData,
              ),
              SizedBox(height: height * 0.02),
              TextField(
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Amount', border: OutlineInputBorder()),
                controller: _amountController,
              ),
              SizedBox(height: height * 0.02),
              // if (isExpense)
              // buildChipList(),
              SizedBox(height: height * 0.005),
              TextField(
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: 'Note', border: OutlineInputBorder()),
                controller: _noteController,
              ),
              SizedBox(height: height * 0.005),
              SizedBox(
                height: height * 0.05,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        _selectedDate == ""
                            ? 'No Date Choosen!'
                            : 'Picked Date : ${DateFormat.yMd().format(DateTime.parse(_selectedDate))}',
                      ),
                    ),
                    TextButton(
                      onPressed: _presentDatePicker,
                      child: Text('Choose Date',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                          )),
                    )
                  ],
                ),
              ),
              SizedBox(height: height * 0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: color),
                    onPressed: _submitData,
                    child: const Text(
                      "Add Transcation",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  buildChipList() {
    return Wrap(
      spacing: 4.0,
      children: <Widget>[
        _buildChip(isGrocery, Icons.local_grocery_store, 'Grocery', color,
            (value) {
          setState(() {
            isGrocery = value;
            isPersonal = false;
            isInvestment = false;
            isTransportation = false;
            isOthers = false;
          });
        }),
        _buildChip(isPersonal, Icons.accessibility, 'Personal', color, (value) {
          setState(() {
            isGrocery = false;
            isPersonal = value;
            isInvestment = false;
            isTransportation = false;
            isOthers = false;
          });
        }),
        _buildChip(isInvestment, Icons.ac_unit, 'Investment', color, (value) {
          setState(() {
            isGrocery = false;
            isPersonal = false;
            isInvestment = value;
            isTransportation = false;
            isOthers = false;
          });
        }),
        _buildChip(isTransportation, Icons.emoji_transportation,
            'Transportation', color, (value) {
          setState(() {
            isGrocery = false;
            isPersonal = false;
            isInvestment = false;
            isTransportation = value;
            isOthers = false;
          });
        }),
        _buildChip(isOthers, Icons.analytics, 'others', color, (value) {
          setState(() {
            isGrocery = false;
            isPersonal = false;
            isInvestment = false;
            isTransportation = false;
            isOthers = value;
          });
        }),
      ],
    );
  }

  Widget _buildChip(
      isSelected, IconData icon, String label, Color color, onChange) {
    return ChoiceChip(
      avatar: CircleAvatar(
          radius: 10,
          backgroundColor: Colors.white70,
          child: Icon(icon, size: 15)),
      selected: isSelected,
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 8),
      ),
      selectedColor: color,
      labelPadding: const EdgeInsets.only(right: 8),
      padding: EdgeInsets.zero,
      // disabledColor: unselected,
      elevation: 6.0,
      onSelected: onChange,
    );
  }
}

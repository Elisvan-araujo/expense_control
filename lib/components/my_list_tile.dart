import 'package:controle_despesas/models/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyListTile extends StatelessWidget {
  final ExpenseModel expense;
  final void Function() onTap;
  final void Function() onLongPress;
  final void Function() onDoubleTap;

  const MyListTile({
    super.key,
    required this.expense,
    required this.onTap,
    required this.onLongPress,
    required this.onDoubleTap,
  });

  String formatNumber(String input) {
    double number = double.parse(input);

    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: '',
      decimalDigits: 2,
    );

    return formatter.format(number).trim();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 12,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: expense.isOpen ? Colors.red : Colors.green,
            width: 2.0,
          ),
        ),
        child: ListTile(
          leading: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  expense.isOpen ? Colors.red.shade700 : Colors.green.shade700,
                  expense.isOpen ? Colors.red.shade200 : Colors.green.shade200,
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              expense.isOpen ? Icons.close : Icons.check,
              color: Colors.white,
              size: 45,
            ),
          ),
          title: Text(
            expense.title,
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            expense.date,
            style: TextStyle(
              fontSize: 15,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          trailing: Text(
            "R\$ ${formatNumber(expense.value)}",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: expense.isOpen ? Colors.red : Colors.green,
            ),
          ),
        ),
      ),
    );
  }
}

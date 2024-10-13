import 'dart:async';
import 'dart:convert';
import 'package:controle_despesas/components/edit_expense_dialog.dart';
import 'package:controle_despesas/components/my_chart.dart';
import 'package:controle_despesas/components/my_list_tile.dart';
import 'package:controle_despesas/themes/dark_mode.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:controle_despesas/components/add_expense_dialog.dart';
import 'package:controle_despesas/models/expense_model.dart';

import 'themes/theme_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  List<ExpenseModel> expensesList = [];
  StreamController<double> progressController = StreamController<double>();
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    loadExpenses();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    progressController.close();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? expenses = prefs.getStringList('expenses');

    if (expenses != null) {
      setState(() {
        expensesList = expenses
            .map(
              (expenses) => ExpenseModel.fromMap(
                Map<String, dynamic>.from(
                  jsonDecode(expenses),
                ),
              ),
            )
            .toList();
      });

      updateProgress();
    }
  }

  Future<void> saveExpense() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> expenses =
        expensesList.map((expenses) => jsonEncode(expenses.toMap())).toList();
    prefs.setStringList('expenses', expenses);
  }

  void addExpense(ExpenseModel expense) {
    setState(() {
      expensesList.add(expense);
      saveExpense();

      titleController.clear();
      valueController.clear();
      dateController.clear();
    });
  }

  void editExpense(int index, ExpenseModel expense) {
    TextEditingController titleController =
        TextEditingController(text: expense.title);
    TextEditingController valueController =
        TextEditingController(text: formatDoubleToLocalCoin(expense.value));
    TextEditingController dateController =
        TextEditingController(text: expense.date);

    showDialog(
      context: context,
      builder: (context) {
        return EditExpenseDialog(
          titleController: titleController,
          valueController: valueController,
          dateController: dateController,
          onTap: () {
            setState(() {
              expense.title = titleController.text;
              expense.value =
                  convertInputStringToDoubleString(valueController.text);
              expense.date = dateController.text;
            });
            saveExpense();
            updateProgress();
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void deleteExpense(int index) {
    setState(() {
      expensesList.removeAt(index);
      saveExpense();
    });
    updateProgress();
  }

  void toggleIsOpen(int index) {
    setState(() {
      expensesList[index].isOpen = !expensesList[index].isOpen;
      saveExpense();
    });
  }

  double calculateTotalExpenses() {
    return expensesList.fold<double>(
        0.0, (sum, item) => sum + double.parse(item.value));
  }

  double calculateTotalClosedExpenses() {
    return expensesList
        .where((item) => !item.isOpen)
        .fold(0.0, (sum, item) => sum + double.parse(item.value));
  }

  double calculateTotalOpenExpenses() {
    return expensesList
        .where((item) => item.isOpen)
        .fold(0.0, (sum, item) => sum + double.parse(item.value));
  }

  void updateProgress() {
    double totalClosed = calculateTotalClosedExpenses();
    double totalValue = calculateTotalExpenses();
    double progress = totalValue > 0 ? totalClosed / totalValue : 0;
    progressController.add(progress);
    _animation = Tween<double>(begin: _animation.value, end: progress)
        .animate(_animationController);
    _animationController.forward(from: 0);
  }

  String convertInputStringToDoubleString(String value) {
    String sanitizedValue = value.replaceAll('.', '');

    sanitizedValue = sanitizedValue.replaceAll(',', '.');

    double number = double.parse(sanitizedValue);

    return number.toStringAsFixed(2);
  }

  String formatDoubleToLocalCoin(String input) {
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        toolbarHeight: 190,
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "CONTROLE DE DESPESAS",
                  style: TextStyle(
                    fontSize: 22,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.red.shade600,
                                Colors.red.shade200,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.01,
                        ),
                        Text(
                          "Total não pago:",
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.07,
                        ),
                        Text(
                          "R\$ ${formatDoubleToLocalCoin(
                            calculateTotalOpenExpenses().toString(),
                          )}",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.green.shade700,
                                Colors.green.shade200,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.01,
                        ),
                        Text(
                          "Total pago:",
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.07,
                        ),
                        Text(
                          "R\$ ${formatDoubleToLocalCoin(
                            calculateTotalClosedExpenses().toString(),
                          )}",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(width: MediaQuery.sizeOf(context).width * 0.04),
                SizedBox(
                  height: 90,
                  width: 90,
                  child: Stack(
                    children: [
                      Positioned(
                        height: 90,
                        width: 90,
                        child: StreamBuilder<double>(
                          stream: progressController.stream,
                          builder: (context, snapshot) {
                            return AnimatedBuilder(
                              animation: _animation,
                              builder: (context, child) {
                                return MyChart(
                                  valueOpen:
                                      (calculateTotalClosedExpenses() == 0.0 &&
                                              calculateTotalOpenExpenses() ==
                                                  0.0) ==
                                          true,
                                  value: _animation.value,
                                  label: '${(_animation.value * 100).round()}%',
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Column(
                  children: [
                    Text(
                      "Dark Mode",
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    CupertinoSwitch(
                      value: Provider.of<ThemeProvider>(context).currentTheme ==
                          darkMode,
                      onChanged: (value) {
                        Provider.of<ThemeProvider>(context, listen: false)
                            .toggleTheme();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: expensesList.length,
        itemBuilder: (context, index) {
          final ExpenseModel expense = expensesList[index];

          return MyListTile(
            expense: expense,
            onDoubleTap: () {
              editExpense(index, expense);
            },
            onLongPress: () {
              showDialog(
                context: context,
                builder: (context) {
                  return customDialog(
                    context,
                    index,
                    title: "Deseja apagar essa depesa?",
                    btn1: "Cancelar",
                    btn2: "Apagar",
                    onTap: () {
                      deleteExpense(index);
                      Navigator.pop(context);
                    },
                  );
                },
              );
            },
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return customDialog(
                    context,
                    index,
                    title: expense.isOpen
                        ? "Alterar status da despesa para PAGO?"
                        : "Alterar Status da despesa para NÃO PAGO?",
                    btn1: "Cancelar",
                    btn2: "Alterar",
                    onTap: () {
                      toggleIsOpen(index);
                      updateProgress();
                      Navigator.pop(context);
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AddExpenseDialog(
                titleController: titleController,
                valueController: valueController,
                dateController: dateController,
                onTap: () {
                  addExpense(
                    ExpenseModel(
                      title: titleController.text,
                      value: convertInputStringToDoubleString(
                          valueController.text),
                      date: dateController.text,
                    ),
                  );
                  updateProgress();
                  Navigator.pop(context);
                },
              );
            },
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.surface,
          size: 30,
        ),
      ),
    );
  }

  AlertDialog customDialog(
    BuildContext context,
    int index, {
    required String title,
    required String btn1,
    required String btn2,
    required void Function() onTap,
  }) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            child: Text(
              btn1,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: onTap,
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            child: Text(
              btn2,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

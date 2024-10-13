import 'package:flutter/material.dart';
import 'my_test_field.dart';

class AddExpenseDialog extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController valueController;
  final TextEditingController dateController;
  final void Function() onTap;

  const AddExpenseDialog({
    super.key,
    required this.titleController,
    required this.valueController,
    required this.dateController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: Text(
        "Adicionar Despesa",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      content: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.4,
        width: MediaQuery.sizeOf(context).height * 0.9,
        child: Column(
          children: [
            MyTextField(
              controller: titleController,
              hintText: "Informe a despesa",
            ),
            const SizedBox(height: 20),
            MyTextField(
              controller: valueController,
              hintText: "Qual o valor da despesa?",
            ),
            const SizedBox(height: 20),
            MyTextField(
              controller: dateController,
              hintText: "Qual o vencimento?",
            ),
            const SizedBox(height: 30),
            Row(
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
                    "Cancelar",
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.surface,
                      fontWeight: FontWeight.bold,
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
                    "Adicionar",
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.surface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../components/transaction_item.dart';
import '../components/categories.dart';


class TransactionsScreen extends StatelessWidget {
  final List<ExpenseTransaction> transactions;

  const TransactionsScreen({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(13, 17, 23, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(24, 31, 39, 1),
        title: const Text(
          "All Transactions",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return TransactionItem(
            icon: Categories.getCategoryIcon(transaction.category),
            category: transaction.category,
            amount: transaction.expenseOrIncome
                ? "-\£${transaction.amount.toStringAsFixed(2)}"
                : "+\£${transaction.amount.toStringAsFixed(2)}",
            date: DateTime.fromMillisecondsSinceEpoch(transaction.date)
                .toLocal()
                .toString()
                .split(' ')[0],
            color: Categories.getCategoryColor(transaction.category),
          );
        },
      ),
    );
  }
}

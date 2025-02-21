import 'package:flutter/foundation.dart';

class ExpenseTransaction {
  final int? id;
  final bool expenseOrIncome; // true for expense, false for income
  final int amount;
  final String category;
  final int date;

  ExpenseTransaction({
    this.id,
    required this.expenseOrIncome,
    required this.amount,
    required this.category,
    required this.date,
  }) {
    // Validate amount is positive
    assert(amount > 0, 'Amount must be positive');
    // Validate category is not empty
    assert(category.isNotEmpty, 'Category cannot be empty');
    // Validate date is valid timestamp
    assert(date > 0, 'Date must be a valid timestamp');
  }

  // Convert Transaction to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'expenseOrIncome': expenseOrIncome ? 1 : 0,
      'amount': amount,
      'category': category,
      'date': date,
    };
  }

  // Create Transaction from Map (database row)
  static ExpenseTransaction fromMap(Map<String, dynamic> map) {
    return ExpenseTransaction(
      id: map['id'] as int?,
      expenseOrIncome: map['expenseOrIncome'] == 1,
      amount: map['amount'] as int,
      category: map['category'] as String,
      date: map['date'] as int,
    );
  }

  // Copy with method for immutability
  ExpenseTransaction copyWith({
    int? id,
    bool? expenseOrIncome,
    int? amount,
    String? category,
    int? date,
  }) {
    return ExpenseTransaction(
      id: id ?? this.id,
      expenseOrIncome: expenseOrIncome ?? this.expenseOrIncome,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
    );
  }

  @override
  String toString() {
    return 'ExpenseTransaction(id: $id, expenseOrIncome: $expenseOrIncome, amount: $amount, category: $category, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is ExpenseTransaction &&
      other.id == id &&
      other.expenseOrIncome == expenseOrIncome &&
      other.amount == amount &&
      other.category == category &&
      other.date == date;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      expenseOrIncome.hashCode ^
      amount.hashCode ^
      category.hashCode ^
      date.hashCode;
  }
}
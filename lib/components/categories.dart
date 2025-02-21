import 'package:flutter/material.dart';

class Categories {
  // Make the methods public by removing the underscore
  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'salary':
        return Icons.monetization_on;
      case 'food':
        return Icons.fastfood;
      case 'shopping':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.movie;
      case 'transport':
        return Icons.directions_bus;
      case 'health':
        return Icons.local_hospital;
      case 'education':
        return Icons.school;
      case 'bills':
        return Icons.receipt;
      case 'travel':
        return Icons.flight;
      case 'investment':
        return Icons.trending_up;
      case 'gift':
        return Icons.card_giftcard;
      case 'home':
        return Icons.home;
      case 'electronics':
        return Icons.devices;
      case 'subscriptions':
        return Icons.subscriptions;
      case 'charity':
        return Icons.volunteer_activism;
      case 'savings':
        return Icons.savings;
      case 'insurance':
        return Icons.security;
      case 'taxes':
        return Icons.account_balance;
      case 'debt payment':
        return Icons.money_off;
      case 'pets':
        return Icons.pets;
      case 'clothing':
        return Icons.checkroom;
      case 'fitness':
        return Icons.fitness_center;
      case 'beauty & personal care':
        return Icons.spa;
      case 'furniture':
        return Icons.chair;
      case 'groceries':
        return Icons.local_grocery_store;
      case 'restaurants':
        return Icons.restaurant;
      case 'coffee':
        return Icons.local_cafe;
      case 'childcare':
        return Icons.family_restroom;
      case 'software & apps':
        return Icons.app_settings_alt;
      case 'gaming':
        return Icons.videogame_asset;
      case 'hobbies':
        return Icons.palette;
      case 'events & concerts':
        return Icons.event;
      case 'freelance income':
        return Icons.work;
      case 'bonuses':
        return Icons.card_membership;
      case 'side business':
        return Icons.business;
      case 'rent':
        return Icons.house;
      case 'utilities':
        return Icons.lightbulb;
      case 'loans':
        return Icons.request_quote;
      case 'car maintenance':
        return Icons.car_repair;
      case 'parking':
        return Icons.local_parking;
      case 'gadgets':
        return Icons.smartphone;
      case 'books':
        return Icons.book;
      case 'streaming services':
        return Icons.tv;
      case 'music':
        return Icons.library_music;
      case 'donations':
        return Icons.favorite;
      case 'retirement contributions':
        return Icons.account_balance_wallet;
      case 'other income':
        return Icons.help_outline; // Icon for "Other Income"
      case 'other expense':
        return Icons.help_outline; // Icon for "Other Expense"
      default:
        return Icons.attach_money;
    }
  }

  // Make the methods public by removing the underscore
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'salary':
        return Colors.cyan;
      case 'food':
        return Colors.orange;
      case 'shopping':
        return Colors.purple;
      case 'entertainment':
        return Colors.red;
      case 'transport':
        return Colors.blueGrey;
      case 'health':
        return Colors.green;
      case 'education':
        return Colors.indigo;
      case 'bills':
        return Colors.teal;
      case 'travel':
        return Colors.blue;
      case 'investment':
        return Colors.amber;
      case 'gift':
        return Colors.pink;
      case 'home':
        return Colors.brown;
      case 'electronics':
        return Colors.deepPurple;
      case 'subscriptions':
        return Colors.deepOrange;
      case 'charity':
        return Colors.lightGreen;
      case 'savings':
        return Colors.blueAccent;
      case 'insurance':
        return Colors.lightBlue;
      case 'taxes':
        return Colors.yellow;
      case 'debt payment':
        return Colors.redAccent;
      case 'pets':
        return Colors.lime;
      case 'clothing':
        return Colors.deepOrangeAccent;
      case 'fitness':
        return Colors.blueGrey;
      case 'beauty & personal care':
        return Colors.purpleAccent;
      case 'furniture':
        return Colors.brown.shade300;
      case 'groceries':
        return Colors.green.shade400;
      case 'restaurants':
        return Colors.orange.shade600;
      case 'coffee':
        return Colors.brown.shade700;
      case 'childcare':
        return Colors.pink.shade300;
      case 'software & apps':
        return Colors.blueAccent.shade700;
      case 'gaming':
        return Colors.teal.shade400;
      case 'hobbies':
        return Colors.purple.shade400;
      case 'events & concerts':
        return Colors.red.shade400;
      case 'freelance income':
        return Colors.green.shade800;
      case 'bonuses':
        return Colors.amber.shade700;
      case 'side business':
        return Colors.blueGrey.shade700;
      case 'rent':
        return Colors.brown.shade600;
      case 'utilities':
        return Colors.lightBlueAccent;
      case 'loans':
        return Colors.red.shade900;
      case 'car maintenance':
        return Colors.blue.shade900;
      case 'parking':
        return Colors.grey.shade600;
      case 'gadgets':
        return Colors.deepPurpleAccent;
      case 'books':
        return Colors.lightGreen.shade800;
      case 'streaming services':
        return Colors.deepOrange.shade700;
      case 'music':
        return Colors.indigoAccent;
      case 'donations':
        return Colors.redAccent.shade200;
      case 'retirement contributions':
        return Colors.teal.shade900;
      case 'other income':
        return Colors.green; // Color for "Other Income"
      case 'other expense':
        return Colors.grey; // Color for "Other Expense"
      default:
        return Colors.blue;
    }
  }
}

class CategoriesList {
  // Income categories list
  static const List<String> incomeCategories = [
    'Salary',
    'Freelance Income',
    'Bonuses',
    'Side Business',
    'Investments',
    'Other Income', // Added "Other Income"
  ];

  // Expense categories list
  static const List<String> expenseCategories = [
    'Food',
    'Shopping',
    'Entertainment',
    'Transport',
    'Health',
    'Education',
    'Bills',
    'Travel',
    'Gift',
    'Home',
    'Electronics',
    'Subscriptions',
    'Charity',
    'Savings',
    'Insurance',
    'Taxes',
    'Debt Payment',
    'Pets',
    'Clothing',
    'Fitness',
    'Beauty & Personal Care',
    'Furniture',
    'Groceries',
    'Restaurants',
    'Coffee',
    'Childcare',
    'Software & Apps',
    'Gaming',
    'Hobbies',
    'Events & Concerts',
    'Rent',
    'Utilities',
    'Loans',
    'Car Maintenance',
    'Parking',
    'Gadgets',
    'Books',
    'Streaming Services',
    'Music',
    'Donations',
    'Retirement Contributions',
    'Other Expense', // Added "Other Expense"
  ];
}

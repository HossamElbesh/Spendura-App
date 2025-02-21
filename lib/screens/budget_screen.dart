import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_services.dart';
import '../components/categories.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _budgetAmountController = TextEditingController();

  String? _selectedCategory;
  List<Map<String, dynamic>> _budgets = [];
  String _selectedCurrency = '\$'; // Default currency

  final List<String> categories = CategoriesList.expenseCategories;

  @override
  void initState() {
    super.initState();
    _loadBudgets();
    _loadCurrency();
  }

  @override
  void dispose() {
    _budgetAmountController.dispose();
    super.dispose();
  }

  Future<void> _loadBudgets() async {
    final budgets = await DatabaseServices.instance.getAllBudgets();
    setState(() {
      _budgets = budgets;
    });
  }

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedCurrency = prefs.getString('currency') ?? '\$';
    });
  }

  Future<void> _addBudget() async {
    if (_formKey.currentState!.validate()) {
      final newBudget = {
        'amount': double.parse(_budgetAmountController.text),
        'category': _selectedCategory,
      };

      try {
        await DatabaseServices.instance.insertBudget(newBudget);
        _budgetAmountController.clear();
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop(); // Dismiss the dialog
        _loadBudgets(); // Refresh budget list
      } catch (e) {
        debugPrint("Error inserting budget: $e");
      }
    }
  }

  void _showAddBudgetDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(24, 31, 39, 1),
          title: const Center(
            child: Text(
              'Add Budget',
              style: TextStyle(color: Colors.white),
            ),
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Category dropdown field.
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  dropdownColor: const Color.fromRGBO(24, 31, 39, 1),
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Row(
                        children: [
                          Icon(
                            Categories.getCategoryIcon(category),
                            color: Categories.getCategoryColor(category),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            category,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                  borderRadius: BorderRadius.circular(20),
                ),
                const SizedBox(height: 10),
                // Budget Amount field.
                TextFormField(
                  controller: _budgetAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Budget Amount',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a budget amount';
                    }
                    if (double.tryParse(value) == null ||
                        double.parse(value) <= 0) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: _addBudget,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
              ),
              child: const Text(
                'Add',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteBudget(int id) async {
    await DatabaseServices.instance.deleteBudget(id);
    _loadBudgets();
  }

  /// Calculates the total amount spent for a given category.
  Future<double> _calculateSpent(String category) async {
    double totalSpent = 0.0;
    final transactions = await DatabaseServices.instance.getAllTransactions();

    for (var transaction in transactions) {
      if (transaction.category == category &&
          transaction.expenseOrIncome == true) {
        totalSpent += transaction.amount;
      }
    }
    return totalSpent;
  }

  /// Calculates overall total budget and total spent across all budgets.
  Future<Map<String, double>> _calculateTotalBudgets() async {
    double totalBudget = 0.0;
    double totalSpent = 0.0;

    for (var budget in _budgets) {
      totalBudget += budget['amount'] as double;
      double spent = await _calculateSpent(budget['category']);
      totalSpent += spent;
    }
    return {'totalBudget': totalBudget, 'totalSpent': totalSpent};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(13, 17, 23, 1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(5.0, 16.0, 5.0, 5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: Text(
                    'Budgeting',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _budgets.isEmpty
                    ? const Center(
                  child: Text(
                    'No budgets added yet',
                    style: TextStyle(color: Colors.white),
                  ),
                )
                    : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _budgets.length + 1,
                  separatorBuilder: (context, index) =>
                  const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Total Budget summary (non-dismissible).
                      return Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 10),
                        child: FutureBuilder<Map<String, double>>(
                          future: _calculateTotalBudgets(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return BudgetItem(
                                currency: _selectedCurrency,
                                icon: Icons.attach_money,
                                category: 'Total Budget',
                                amount: '0.00',
                                spent: 'Loading...',
                                color: Colors.purple,
                                completion: 0.0,
                              );
                            }
                            if (snapshot.hasError) {
                              return BudgetItem(
                                currency: _selectedCurrency,
                                icon: Icons.attach_money,
                                category: 'Total Budget',
                                amount: '0.00',
                                spent: 'Error',
                                color: Colors.purple,
                                completion: 0.0,
                              );
                            }
                            final totals = snapshot.data!;
                            final totalBudget = totals['totalBudget']!;
                            final totalSpent = totals['totalSpent']!;
                            final completion = totalBudget > 0
                                ? totalSpent / totalBudget
                                : 0.0;
                            return BudgetItem(
                              currency: _selectedCurrency,
                              icon: Icons.attach_money,
                              category: 'Total Budget',
                              amount: totalBudget.toStringAsFixed(2),
                              spent: totalSpent.toStringAsFixed(2),
                              color: Colors.purple,
                              completion: completion,
                            );
                          },
                        ),
                      );
                    } else {
                      // Individual budget item.
                      final budget = _budgets[index - 1];
                      final category = budget['category'];
                      final categoryIcon =
                      Categories.getCategoryIcon(category);
                      final categoryColor =
                      Categories.getCategoryColor(category);
                      return Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 10),
                        child: Dismissible(
                          key: Key(budget['id'].toString()),
                          background: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.cyan.shade600,
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            _deleteBudget(budget['id']);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "$_selectedCurrency${budget['category']} budget deleted",
                                ),
                              ),
                            );
                          },
                          child: FutureBuilder<double>(
                            future: _calculateSpent(category),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return BudgetItem(
                                  currency: _selectedCurrency,
                                  icon: categoryIcon,
                                  category: category,
                                  amount: budget['amount']
                                      .toStringAsFixed(2),
                                  spent: 'Loading...',
                                  color: categoryColor,
                                  completion: 0.0,
                                );
                              }
                              if (snapshot.hasError) {
                                return BudgetItem(
                                  currency: _selectedCurrency,
                                  icon: categoryIcon,
                                  category: category,
                                  amount: budget['amount']
                                      .toStringAsFixed(2),
                                  spent: 'Error',
                                  color: categoryColor,
                                  completion: 0.0,
                                );
                              }
                              final spent = snapshot.data ?? 0.0;
                              final completion =
                                  spent / (budget['amount'] as double);
                              return BudgetItem(
                                currency: _selectedCurrency,
                                icon: categoryIcon,
                                category: category,
                                amount: budget['amount']
                                    .toStringAsFixed(2),
                                spent: spent.toStringAsFixed(2),
                                color: categoryColor,
                                completion: completion,
                              );
                            },
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      // Bottom button to add a new budget.
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: BottomAppBar(
          color: Colors.transparent,
          elevation: 0,
          child: GestureDetector(
            onTap: _showAddBudgetDialog,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.cyan, Colors.cyan.shade900],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Center(
                child: Text(
                  'ADD BUDGET',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A widget to display a budget item. Note that it now accepts a currency
/// string so that it is independent of any global variables.
class BudgetItem extends StatelessWidget {
  final IconData icon;
  final String category;
  final String amount;
  final String spent;
  final Color color;
  final double completion;
  final String currency;

  const BudgetItem({
    super.key,
    required this.icon,
    required this.category,
    required this.amount,
    required this.spent,
    required this.color,
    required this.completion,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(24, 31, 39, 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            // ignore: deprecated_member_use
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: completion.clamp(0.0, 1.0),
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    completion > 1 ? Colors.red : Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Spent: $currency$spent',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '$currency$amount',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_services.dart';
import '../models/transaction_model.dart';
import '../components/categories.dart';
import '../services/budget_monitor_services.dart'; // Import the budget monitor service

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  bool isExpense = true;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedCurrency = '\$'; // Default currency

  // Accessing the income and expense categories list
  List<String> incomeList = CategoriesList.incomeCategories;
  List<String> expenseList = CategoriesList.expenseCategories;

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedCurrency = prefs.getString('currency') ?? '\$';
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            primaryColor: Colors.teal,
            hintColor: Colors.tealAccent,
            colorScheme: const ColorScheme.dark(
              primary: Colors.teal,
              onPrimary: Colors.white,
              surface: Color.fromRGBO(24, 31, 39, 1),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color.fromRGBO(24, 31, 39, 1),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (_amountController.text.isEmpty || _categoryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      final amount = int.parse(_amountController.text);
      final transaction = ExpenseTransaction(
        expenseOrIncome: isExpense,
        amount: amount,
        category: _categoryController.text,
        date: _selectedDate.millisecondsSinceEpoch,
      );

      // Insert the transaction into the database.
      await DatabaseServices.instance.insertTransaction(transaction);

      // Immediately check if any budget is exceeded.
      await BudgetMonitorServices().checkBudgets();

      // Clear the form and reset the date.
      _amountController.clear();
      _categoryController.clear();
      setState(() {
        _selectedDate = DateTime.now();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error saving transaction')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCurrency();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(13, 17, 23, 1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Center(
                  child: Text(
                    'Add Transaction',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildIncomeExpenseToggle(),
                const SizedBox(height: 24),
                _buildAmountInput(),
                const SizedBox(height: 24),
                _buildCategoryField(),
                const SizedBox(height: 24),
                _buildDateField(context),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: _saveTransaction,
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
                        'SAVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseToggle() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(24, 31, 39, 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isExpense = false;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: !isExpense
                        ? Colors.cyan.shade700
                        : const Color.fromRGBO(24, 31, 39, 1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text(
                      'Income',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isExpense = true;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isExpense
                        ? Colors.cyan.shade700
                        : const Color.fromRGBO(24, 31, 39, 1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text(
                      'Expense',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(24, 31, 39, 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            fontSize: 36,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: isExpense ? '- $_selectedCurrency 0' : '+ $_selectedCurrency 0',
            hintStyle: const TextStyle(
              fontSize: 36,
              color: Colors.white,
            ),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildCategoryField() {
    return Container(
      height: 75,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(24, 31, 39, 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            _categoryController.text.isNotEmpty
                ? Categories.getCategoryIcon(_categoryController.text)
                : Icons.category_outlined,
            color: Colors.white,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _categoryController,
              style: const TextStyle(color: Colors.white),
              readOnly: true,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Category",
                hintStyle: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: const Color.fromRGBO(24, 31, 39, 1),
                builder: (BuildContext context) {
                  final categories = isExpense
                      ? CategoriesList.expenseCategories
                      : CategoriesList.incomeCategories;
                  return ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return ListTile(
                        leading: Icon(
                          Categories.getCategoryIcon(category),
                          color: Categories.getCategoryColor(category),
                        ),
                        title: Text(
                          category,
                          style: const TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          setState(() {
                            _categoryController.text = category;
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        height: 75,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(24, 31, 39, 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Center(
                child: Text(
                  "${_selectedDate.toLocal()}".split(' ')[0],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

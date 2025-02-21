import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_services.dart';
import '../models/transaction_model.dart';
import '../components/transaction_item.dart';
import 'transactions_screen.dart';
import 'notifications_screen.dart';
import '../components/categories.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int totalBalance = 0;
  int totalIncome = 0;
  int totalExpenses = 0;
  List<ExpenseTransaction> recentTransactions = [];
  String _selectedCurrency = '\$'; // Default currency

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadCurrency();
  }

  Future<void> _loadData() async {
    final balance = await DatabaseServices.instance.getTotalBalance();
    final income = await DatabaseServices.instance.getTotalIncome();
    final expenses = await DatabaseServices.instance.getTotalExpenses();
    final transactions = await DatabaseServices.instance.getAllTransactions();

    setState(() {
      totalBalance = balance;
      totalIncome = income;
      totalExpenses = expenses;
      recentTransactions = transactions.reversed.toList();
    });
  }

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedCurrency = prefs.getString('currency') ?? '\$';
    });
  }

  Future<void> _deleteTransaction(int id) async {
    await DatabaseServices.instance.deleteTransaction(id);
    _loadData(); // Refresh the data after deletion
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Navigator(
        onGenerateRoute: (settings) {
          if (settings.name == '/transactions') {
            return MaterialPageRoute(
              builder: (context) => TransactionsScreen(transactions: recentTransactions),
            );
          } else if (settings.name == '/notifications') {
            return MaterialPageRoute(
              builder: (context) => const NotificationsScreen(),
            );
          }
          return MaterialPageRoute(
            builder: (context) => _buildHomeContent(context),
          );
        },
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(13, 17, 23, 1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Spendura",
                          style: TextStyle(
                            fontFamily: "Righteous",
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),

                    // Right Section - Notifications Icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed('/notifications');
                          },
                          child: CircleAvatar(
                            radius: 17, // Smaller radius
                            backgroundColor: Colors.grey[300],
                            child: const Icon(Icons.notifications,
                                color: Colors.black, size: 22), // Smaller icon size
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(45),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: [Colors.cyan, Colors.cyan.shade900],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  image: const DecorationImage(
                    image: AssetImage('lib/assets/Dots.png'),
                    fit: BoxFit.cover,
                    opacity: 0.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Total Balance",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "$_selectedCurrency${totalBalance.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            const Text(
                              "Income",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "$_selectedCurrency${totalIncome.toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text(
                              "Expenses",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "$_selectedCurrency${totalExpenses.toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Transactions",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TransactionsScreen(transactions: recentTransactions),
                        ),
                      );
                    },
                    child: const Text(
                      "View All",
                      style: TextStyle(color: Colors.cyan),
                    ),
                  ),

                ],
              ),
              const SizedBox(height: 10),

              Expanded(
                child: ListView.builder(
                  itemCount: recentTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = recentTransactions[index];
                    return Dismissible(
                      key: Key(transaction.id.toString()),
                      background: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                30), // Apply border radius only here
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
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        if (transaction.id != null) {
                          _deleteTransaction(
                              transaction.id!); // Use '!' to assert non-null
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                Text("${transaction.category} deleted")),
                          );
                        }
                      },
                      child: TransactionItem(
                        icon: Categories.getCategoryIcon(transaction.category), // Use a public method without '_'
                        category: transaction.category,
                        amount: transaction.expenseOrIncome
                            ? "- $_selectedCurrency${transaction.amount.toStringAsFixed(2)}"
                            : "+ $_selectedCurrency${transaction.amount.toStringAsFixed(2)}",
                        date: DateTime.fromMillisecondsSinceEpoch(transaction.date)
                            .toLocal() // Ensure the time zone is local
                            .toString()
                            .split(' ')[0], // Format the date
                        color: Categories.getCategoryColor(transaction.category), // Use a public method without '_'
                      ),

                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

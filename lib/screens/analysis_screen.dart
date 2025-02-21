import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';
import '../services/database_services.dart';
import '../components/categories.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

String _selectedCurrency = '\$'; // Default currency

class _AnalysisScreenState extends State<AnalysisScreen> {
  List<ExpenseTransaction> _transactions = [];
  final DateTime _selectedDate = DateTime.now();
  String _selectedView = 'Weekly'; // Default to 'Weekly'

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _loadCurrency();
  }

  Future<void> _loadTransactions() async {
    final transactions = await DatabaseServices.instance.getAllTransactions();
    setState(() {
      _transactions = transactions;
    });
  }

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedCurrency = prefs.getString('currency') ?? '\$';
    });
  }

  // Get start and end dates based on the selected view
  Map<String, DateTime> _getDateRange() {
    DateTime startDate, endDate;

    if (_selectedView == 'Weekly') {
      // This will ensure your week starts on Saturday and ends on Friday.
      startDate = _selectedDate.subtract(Duration(days: (_selectedDate.weekday == 7) ? 0 : (_selectedDate.weekday % 7)));
      endDate = startDate.add(const Duration(days: 7)); // Ends on the following Friday
    } else {
      startDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
      endDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
    }

    return {'startDate': startDate, 'endDate': endDate};
  }

  Widget _buildViewChartToggle() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(24, 31, 39, 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: ['Weekly', 'Monthly'].map((view) {
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedView = view;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _selectedView == view
                        ? Colors.cyan.shade700
                        : const Color.fromRGBO(24, 31, 39, 1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      view,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  double _getTotalAmount(bool expenseOrIncome) {
    return _transactions
        .where((transaction) => transaction.expenseOrIncome == expenseOrIncome)
        .fold(0, (sum, transaction) => sum + transaction.amount);
  }

  List<FlSpot> _getDailyExpenseSpots() {
    final range = _getDateRange();
    final List<FlSpot> spots = [];
    final startDate = range['startDate']!;
    final daysInPeriod = range['endDate']!.difference(startDate).inDays;

    for (var i = 0; i < daysInPeriod; i++) {
      final currentDate = startDate.add(Duration(days: i));
      final dailyTotal = _transactions
          .where((transaction) =>
      transaction.expenseOrIncome &&
          transaction.date >= currentDate.millisecondsSinceEpoch &&
          transaction.date <
              currentDate
                  .add(const Duration(days: 1))
                  .millisecondsSinceEpoch)
          .fold(0, (sum, transaction) => sum + transaction.amount);
      spots.add(FlSpot(i.toDouble(), dailyTotal.toDouble()));
    }

    return spots;
  }

  Map<String, double> _getCategoryTotals() {
    final Map<String, double> categoryTotals = {};

    for (var transaction in _transactions) {
      if (transaction.expenseOrIncome) {
        categoryTotals.update(
          transaction.category,
              (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount.toDouble(),
        );
      }
    }

    return categoryTotals;
  }

  @override
  Widget build(BuildContext context) {
    final totalExpenses = _getTotalAmount(true);
    final totalIncome = _getTotalAmount(false);
    final balance = totalIncome - totalExpenses;
    final growthPercentage = totalIncome != 0 ? ((balance / totalIncome) * 100) : 0;
    final dailyExpenseSpots = _getDailyExpenseSpots();
    final categoryTotals = _getCategoryTotals();

    return Scaffold(
      backgroundColor: const Color.fromRGBO(13, 17, 23, 1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Analytics',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard('Expenses',
                        '$_selectedCurrency${totalExpenses.toStringAsFixed(2)}', Colors.red),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildSummaryCard('Income',
                        '$_selectedCurrency${totalIncome.toStringAsFixed(2)}', Colors.green),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard('Balance',
                        '$_selectedCurrency${balance.toStringAsFixed(2)}', Colors.cyan),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildSummaryCard(
                      'Growth',
                      '${growthPercentage.toStringAsFixed(2)}%',
                      growthPercentage >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Toggle Buttons for Weekly/Monthly
              _buildViewChartToggle(),
              const SizedBox(height: 20),

              // Line Chart for Weekly/Monthly Expenses
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: dailyExpenseSpots,
                        isCurved: true,
                        barWidth: 3,
                        color: Colors.cyan,
                        dotData: FlDotData(show: false),
                      ),
                    ],
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(color: Colors.white),
                            );
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                  ),
                ),
              ),

              const Divider(
                color: Colors.white24,
                thickness: 1,
                height: 30,
              ), // Line separator

              // Pie Chart for Categories
              const Center(
                child: Text(
                  'Expenses By Category',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Pie chart on the left
                  Expanded(
                    child: SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: categoryTotals.entries.map((entry) {
                            return PieChartSectionData(
                              color: Categories.getCategoryColor(entry.key),
                              value: entry.value,
                              title: (entry.value / totalExpenses * 100) < 5.9
                                  ? ''
                                  : '${(entry.value / totalExpenses * 100).toStringAsFixed(1)}%',

                              radius: 60,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }).toList(),
                          centerSpaceRadius: 28,
                          startDegreeOffset: 90,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 15),

                  // Expense list with fixed height and separate scrolling
                  Expanded(
                    child: SizedBox(
                      height: 250, // Adjust height as needed
                      child: ListView.builder(
                        itemCount: categoryTotals.length,
                        itemBuilder: (context, index) {
                          final category = categoryTotals.keys.toList()[index];
                          final amount = categoryTotals[category];

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(24, 31, 39, 1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        // Circle with category color
                                        Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Categories.getCategoryColor(category),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Category text with flexible wrapping
                                        Expanded(
                                          child: Text(
                                            category,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '$_selectedCurrency${amount!.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),

                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(24, 31, 39, 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
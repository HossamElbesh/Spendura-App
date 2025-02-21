import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import '../models/transaction_model.dart';

class DatabaseServices {
  static Database? _db;
  static final DatabaseServices instance = DatabaseServices._constructor();

  // Transactions table details
  final String _transactionsTableName = "transactions";
  final String _transactionsIdColumnName = "id";
  final String _transactionsExpenseOrIncomColumnName = "expenseOrIncome";
  final String _transactionsaAmountColumnName = "amount";
  final String _transactionsCategoryColumnName = "category";
  final String _transactionsDateColumnName = "date";

  // Budgets table details
  final String _budgetsTableName = "budgets";
  final String _budgetsIdColumnName = "id";
  final String _budgetsCategoryColumnName = "category";
  final String _budgetsAmountColumnName = "amount";

  DatabaseServices._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _getDatabase();
    return _db!;
  }

  Future<Database> _getDatabase() async {
    final dataBaseDirPath = await getDatabasesPath();
    final databasePath = join(dataBaseDirPath, "masterDb.db");
    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) {
        // Create the transactions table
        db.execute('''
          CREATE TABLE $_transactionsTableName(
            $_transactionsIdColumnName INTEGER PRIMARY KEY AUTOINCREMENT, 
            $_transactionsExpenseOrIncomColumnName INTEGER NOT NULL,
            $_transactionsaAmountColumnName INTEGER NOT NULL,
            $_transactionsCategoryColumnName TEXT NOT NULL,
            $_transactionsDateColumnName INTEGER NOT NULL 
          )
        ''');
        // Create the budgets table
        db.execute('''
          CREATE TABLE $_budgetsTableName(
            $_budgetsIdColumnName INTEGER PRIMARY KEY AUTOINCREMENT,
            $_budgetsCategoryColumnName TEXT NOT NULL,
            $_budgetsAmountColumnName REAL NOT NULL
          )
        ''');
      },
    );
    return database;
  }

  // Transaction methods

  Future<int> insertTransaction(ExpenseTransaction transaction) async {
    final db = await database;
    return await db.insert(
      _transactionsTableName,
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ExpenseTransaction>> getAllTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_transactionsTableName);
    return List.generate(
      maps.length,
          (i) => ExpenseTransaction.fromMap(maps[i]),
    );
  }

  Future<int> getTotalBalance() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        SUM(CASE WHEN $_transactionsExpenseOrIncomColumnName = 0 THEN $_transactionsaAmountColumnName ELSE -$_transactionsaAmountColumnName END) as balance 
      FROM $_transactionsTableName
    ''');
    return result.first['balance'] ?? 0;
  }

  Future<int> getTotalIncome() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT SUM($_transactionsaAmountColumnName) as total FROM $_transactionsTableName 
      WHERE $_transactionsExpenseOrIncomColumnName = 0
    ''');
    return result.first['total'] ?? 0;
  }

  Future<int> getTotalExpenses() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT SUM($_transactionsaAmountColumnName) as total FROM $_transactionsTableName 
      WHERE $_transactionsExpenseOrIncomColumnName = 1
    ''');
    return result.first['total'] ?? 0;
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      _transactionsTableName,
      where: '$_transactionsIdColumnName = ?',
      whereArgs: [id],
    );
  }

  // Budget methods

  /// Retrieves all budgets from the database.
  Future<List<Map<String, dynamic>>> getAllBudgets() async {
    final db = await database;
    return await db.query(_budgetsTableName);
  }

  /// Inserts a new budget into the database.
  Future<int> insertBudget(Map<String, dynamic> budget) async {
    final db = await database;
    return await db.insert(
      _budgetsTableName,
      budget,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Deletes a budget from the database by its [id].
  Future<int> deleteBudget(int id) async {
    final db = await database;
    return await db.delete(
      _budgetsTableName,
      where: '$_budgetsIdColumnName = ?',
      whereArgs: [id],
    );
  }
}

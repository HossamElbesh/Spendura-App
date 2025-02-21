// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../services/database_services.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final TextEditingController _usernameController = TextEditingController();
  File? _userImage;
  String _selectedCurrency = '\$'; // Default currency
  final List<String> _currencies = ['\$', '€', '£', '₹', '¥'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _usernameController.text = prefs.getString('username') ?? '';
      _selectedCurrency = prefs.getString('currency') ?? '\$';
      final String? imagePath = prefs.getString('userImagePath');
      if (imagePath != null && imagePath.isNotEmpty) {
        _userImage = File(imagePath);
      }
    });
  }

  Future<void> _saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    setState(() {
      _usernameController.text = username;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Username saved!')),
    );
  }

  Future<void> _saveCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', currency);
    setState(() {
      _selectedCurrency = currency;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Currency updated!')),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _userImage = File(pickedImage.path);
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userImagePath', pickedImage.path);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User picture updated!')),
      );
    }
  }

  Future<void> _exportAppData() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';
    final currency = prefs.getString('currency') ?? '\$';
    final userImagePath = prefs.getString('userImagePath') ?? '';

    final dbService = DatabaseServices.instance;
    final db = await dbService.database;
    final List<Map<String, dynamic>> transactionsData =
    await db.query("transactions");
    final List<Map<String, dynamic>> budgetsData =
    await db.query("budgets");

    final Map<String, dynamic> data = {
      'user': {
        'username': username,
        'currency': currency,
        'userImagePath': userImagePath,
      },
      'transactions': transactionsData,
      'budgets': budgetsData,
    };

    final String jsonData = jsonEncode(data);

    Directory? directory;
    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download');
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      directory = await getDownloadsDirectory();
      directory ??= await getApplicationDocumentsDirectory();
    }

    final String baseFileName = 'spendura_user_data';
    final String extension = '.json';
    String filePath = '${directory.path}/$baseFileName$extension';
    int fileIndex = 1;
    while (await File(filePath).exists()) {
      filePath = '${directory.path}/$baseFileName($fileIndex)$extension';
      fileIndex++;
    }

    final file = File(filePath);
    await file.writeAsString(jsonData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('User data exported to $filePath')),
    );
  }

  Future<void> _importAppData() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.single.path == null) {
      return;
    }

    final filePath = result.files.single.path!;
    try {
      final file = File(filePath);
      final String jsonData = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(jsonData);

      final userData = data['user'];
      if (userData is Map<String, dynamic>) {
        final prefs = await SharedPreferences.getInstance();
        final String username = userData['username'] ?? '';
        final String currency = userData['currency'] ?? '\$';
        final String userImagePath = userData['userImagePath'] ?? '';
        await prefs.setString('username', username);
        await prefs.setString('currency', currency);
        await prefs.setString('userImagePath', userImagePath);
        setState(() {
          _usernameController.text = username;
          _selectedCurrency = currency;
          _userImage = userImagePath.isNotEmpty ? File(userImagePath) : null;
        });
      }

      final dbService = DatabaseServices.instance;
      final db = await dbService.database;

      await db.delete("transactions");
      await db.delete("budgets");

      if (data['transactions'] is List) {
        for (var transaction in data['transactions']) {
          if (transaction is Map<String, dynamic>) {
            await db.insert("transactions", transaction);
          }
        }
      }
      if (data['budgets'] is List) {
        for (var budget in data['budgets']) {
          if (budget is Map<String, dynamic>) {
            await db.insert("budgets", budget);
          }
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User data imported successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to import data: $e")),
      );
    }
  }

  Future<void> _resetAppData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    final dbService = DatabaseServices.instance;
    final db = await dbService.database;
    await db.delete("transactions");
    await db.delete("budgets");

    setState(() {
      _usernameController.text = '';
      _userImage = null;
      _selectedCurrency = '\$';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All app data has been reset!')),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  'Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey.shade800,
                          backgroundImage: _userImage != null
                              ? FileImage(_userImage!)
                              : null,
                          child: _userImage == null
                              ? const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white70,
                          )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: _pickImage,
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.cyan,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _usernameController.text.isNotEmpty
                          ? _usernameController.text
                          : 'Your Name',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Change Username Button
              Center(
                child: SizedBox(
                  width: 250,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final newUsername = await showDialog<String>(
                        context: context,
                        builder: (context) {
                          final dialogController = TextEditingController(
                              text: _usernameController.text);
                          return AlertDialog(
                            backgroundColor:
                            const Color.fromRGBO(24, 31, 39, 1),
                            title: const Center(
                              child: Text(
                                'Change Username',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            content: TextField(
                              controller: dialogController,
                              decoration: const InputDecoration(
                                hintText: 'Enter your username',
                                hintStyle: TextStyle(color: Colors.white70),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                              style: const TextStyle(color: Colors.white),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(dialogController.text);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.cyan,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Save'),
                              ),
                            ],
                          );
                        },
                      );
                      if (newUsername != null) {
                        _saveUsername(newUsername);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Change Username'),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Change Currency Button
              Center(
                child: SizedBox(
                  width: 250,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final newCurrency = await showDialog<String>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor:
                            const Color.fromRGBO(24, 31, 39, 1),
                            title: const Center(
                              child: Text(
                                'Change Currency',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            content: StatefulBuilder(
                              builder: (context, setState) {
                                return DropdownButton<String>(
                                  value: _selectedCurrency,
                                  dropdownColor: Colors.grey[800],
                                  items: _currencies.map((String currency) {
                                    return DropdownMenuItem<String>(
                                      value: currency,
                                      child: Text(
                                        currency,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _selectedCurrency = newValue;
                                      });
                                    }
                                  },
                                  style: const TextStyle(color: Colors.white),
                                  underline: Container(
                                    height: 1,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(_selectedCurrency),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.cyan,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Save'),
                              ),
                            ],
                          );
                        },
                      );
                      if (newCurrency != null) {
                        _saveCurrency(newCurrency);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Change Currency'),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Export User Data Button
              Center(
                child: SizedBox(
                  width: 250,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _exportAppData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Export User Data'),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Import User Data Button
              Center(
                child: SizedBox(
                  width: 250,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _importAppData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Import User Data'),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Reset App Data Button
              Center(
                child: SizedBox(
                  width: 250,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final confirmReset = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor:
                            const Color.fromRGBO(24, 31, 39, 1),
                            title: const Text(
                              'Reset App Data',
                              style: TextStyle(color: Colors.white),
                            ),
                            content: const Text(
                              'Are you sure you want to reset all app data? This action cannot be undone.',
                              style: TextStyle(color: Colors.white),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Reset'),
                              ),
                            ],
                          );
                        },
                      );
                      if (confirmReset == true) {
                        await _resetAppData();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Reset App Data'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

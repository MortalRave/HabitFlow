import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const HabitFlowApp());
}

class HabitFlowApp extends StatelessWidget {
  const HabitFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HabitFlow',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HabitScreen(),
    );
  }
}

class HabitScreen extends StatefulWidget {
  const HabitScreen({super.key});

  @override
  State<HabitScreen> createState() => _HabitScreenState();
}

class _HabitScreenState extends State<HabitScreen> {
  List<dynamic> habits = [];

  @override
  void initState() {
    super.initState();
    fetchHabits();
  }

  Future<void> fetchHabits() async {
    final url = Uri.parse('https://localhost:7185/api/habits');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          habits = json.decode(response.body);
        });
      }
    } catch (e) {
      print('Błąd połaczenia z API: {$e}');
    }
  }

  Future<void> _createNewHabit(String name, String description) async {
    if (name.isEmpty) return;

    final url = Uri.parse('https://localhost:7185/api/habits');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'description': description,
        }),
      );

      if (response.statusCode == 201) {
        fetchHabits();
      } else{
        print('Addition error. Server code: ${response.statusCode}');
      }
    } catch (e) {
      print('API connection error: $e');
    }
  }

  Future<void> _showAddHabitDialog() async {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add new habit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Habit\' name'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description (optional)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _createNewHabit(nameController.text, descController.text);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moje nawyki'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchHabits,
          )
        ]
      ),
      body: habits.isEmpty
          ? const Center(child: Text('Brak nawyków! Dodaj nowy nawyk'))
          :ListView.builder(
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.check_circle_outline, color: Colors.deepPurple),
                  title: Text(habit['name'] ?? 'Brak nazwy'),
                  subtitle: Text(habit['description'] ?? ''),
                  trailing: Text('🔥 ${habit['streakCount'] ?? 0}'),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showAddHabitDialog,
            tooltip: 'Add new habit',
            child: const Icon(Icons.add),
          ),
    );
  }
}
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

  Future<void> _deleteHabit(int id) async {
    final url = Uri.parse('https://localhost:7185/api/habits/$id');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 204) {
        fetchHabits();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Habit has been deleted.')),
          );
        }
      } else {
        print('Deleting error: Code: ${response.statusCode}');
      }
    }
    catch (e) {
      print('API connection error: $e');
    }
  }

  Future<void> _updateHabit(int id, String newName, String newDesc, dynamic existingHabit) async {
    final url = Uri.parse('https://localhost:7185/api/habits/$id');

    final updatedData = Map<String, dynamic>.from(existingHabit);
    updatedData['name'] = newName;
    updatedData['description'] = newDesc;

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedData),
      );

      if (response.statusCode == 204) {
        fetchHabits();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Habit updated')),
          );
        }
      } else {
        print('Edditing error. Server code ${response.statusCode}');
      }
    } catch (e) {
      print('API connection error: $e');
    }
  }

  Future<void> _showEditDialog(dynamic habit) async {
    final nameController = TextEditingController(text: habit['name']);
    final descController = TextEditingController(text: habit['description']);

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit habit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Habit\'s name'),
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
                _updateHabit(habit['id'], nameController.text, descController.text, habit);
                Navigator.pop(context);
              },
              child: const Text('Save changes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmation(int id, String name) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Deleting habit'),
          content: Text('Are you sure you want to delete "$name" habit?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteHabit(id);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _completeHabit(int id) async {
    final url = Uri.parse('https://localhost:7185/api/habits/$id/complete');
    
    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        fetchHabits();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Habit marked as done! 🎉')),
          );
        }
      } else if (response.statusCode == 400) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('This habit has already been done!')),
          );
        }
      }
    } catch (e) {
      print('API connection error: &e');
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
                  leading: IconButton(
                    icon: Icon(
                      habit['isCompletedToday'] == true
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                      color: habit['isCompletedToday'] == true
                        ? Colors.green
                        : Colors.grey,
                    ),
                    onPressed: () {
                      _completeHabit(habit['id']);
                    },
                  ),
                  title: Text(habit['name'] ?? 'No name'),
                  subtitle: Text(habit['description'] ?? ''),
                  onTap: () => _showEditDialog(habit),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '🔥 ${habit['streakCount'] ?? 0}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          _showDeleteConfirmation(
                            habit['id'],
                            habit['name'] ?? 'No name'
                          );
                        },
                      ),
                    ],
                  ),
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
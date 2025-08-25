import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meine Gerichte',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 58, 60, 183)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Meine Gerichte'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> _meals = [];
  List<String> _weeklyPlan = [];

  Future<void> _showAddMealDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Gericht hinzufügen'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration:
                const InputDecoration(hintText: 'z. B. Spaghetti Bolognese'),
            textInputAction: TextInputAction.done,
            onSubmitted: (value) => Navigator.of(context).pop(value),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Abbrechen')),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Gericht hinzufügen'),
            ),
          ],
        );
      },
    );

    if (result == null) return;
    final name = result.trim();
    if (name.isEmpty) return;
    setState(() {
      _meals.add(name);
    });
  }

  void _removeMealAt(int index) {
    setState(() {
      _meals.removeAt(index);
    });
  }

  void _generatePlan(int count) {
    if (_meals.length < count) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bitte füge mindestens $count Gerichte hinzu.'),
        ),
      );
      return;
    }
    final shuffled = List.of(_meals)..shuffle();
    setState(() {
      _weeklyPlan = shuffled.take(count).toList();
    });
  }

  Future<void> _askCountAndGenerate() async {
    if (_meals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte füge zuerst Gerichte hinzu.'),
        ),
      );
      return;
    }
    final _max = _meals.length < 7 ? _meals.length : 7;
    int selected = _max >= 5 ? 5 : _max;

    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('Anzahl für den Wochenplan'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Gerichte: $selected'),
                  Slider(
                    value: selected.toDouble(),
                    min: 1,
                    max: _max.toDouble(),
                    divisions: _max > 1 ? _max - 1 : null,
                    label: '$selected',
                    onChanged: (value) =>
                        setLocalState(() => selected = value.round()),
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Abbrechen')),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(selected),
                  child: const Text('Erzeugen'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      _generatePlan(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('Gerichte insgesamt: ${_meals.length}'),
            ElevatedButton(
              onPressed: _askCountAndGenerate,
              child: const Text('Wochenplan erzeugen'),
            ),
            if (_weeklyPlan.isNotEmpty) ...[
              const SizedBox(
                height: 16,
              ),
              const Text(
                'Dein Wochenplan:',
              ),
              ..._weeklyPlan.map((meal) => Text(meal)).toList(),
            ],
            Expanded(
              child: ListView.builder(
                itemCount: _meals.length,
                itemBuilder: (context, index) {
                  final meal = _meals[index];
                  return ListTile(
                    title: Text(meal),
                    trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeMealAt(index)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMealDialog,
        tooltip: 'Gericht hinzufügen',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

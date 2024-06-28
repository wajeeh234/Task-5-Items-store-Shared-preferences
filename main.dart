import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(ItemListApp());
}

class ItemListApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Item List App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: ItemListScreen(),
      routes: {
        '/details': (context) => ItemDetailsScreen(),
        '/add': (context) => AddItemScreen(),
      },
    );
  }
}

class Fruit {
  final String name;
  final String description;

  Fruit({required this.name, required this.description});

  factory Fruit.fromJson(Map<String, dynamic> json) {
    return Fruit(
      name: json['name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }
}

class ItemListScreen extends StatefulWidget {
  @override
  _ItemListScreenState createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  bool _isLoading = false;
  List<Fruit> _items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final String? itemsString = prefs.getString('items');

    if (itemsString != null) {
      final List<dynamic> itemsJson = jsonDecode(itemsString);
      setState(() {
        _items = itemsJson
            .map((json) => Fruit.fromJson(json as Map<String, dynamic>))
            .toList();
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveItems(List<Fruit> items) async {
    final prefs = await SharedPreferences.getInstance();
    final String itemsString =
        jsonEncode(items.map((item) => item.toJson()).toList());
    await prefs.setString('items', itemsString);
  }

  void _addItem(Fruit newItem) async {
    setState(() {
      _isLoading = true;
    });

    _items.add(newItem);
    await _saveItems(_items);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fruits List'),
        centerTitle: true,
        backgroundColor: Colors.yellow,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(child: Text('No items'))
              : ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_items[index].name),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/details',
                          arguments: _items[index],
                        );
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          setState(() {
            _isLoading = true;
          });

          final newItem = await Navigator.pushNamed(context, '/add');

          if (newItem != null && newItem is Fruit) {
            _addItem(newItem);
          }

          setState(() {
            _isLoading = false;
          });
        },
        child: _isLoading
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class ItemDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Fruit item = ModalRoute.of(context)!.settings.arguments as Fruit;

    return Scaffold(
      appBar: AppBar(
        title: Text('${item.name} Details'),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.name,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                item.description,
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddItemScreen extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Fruit'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Fruit Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final String name = _nameController.text;
                final String description = _descriptionController.text;

                if (name.isNotEmpty && description.isNotEmpty) {
                  final newItem = Fruit(name: name, description: description);
                  Navigator.pop(context, newItem);
                }
              },
              child: Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }
}

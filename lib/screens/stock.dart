// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Stock extends StatefulWidget {
  const Stock({Key? key}) : super(key: key);

  @override
  State<Stock> createState() => _StockState();
}

class _StockState extends State<Stock> {
  List<Map<String, dynamic>> materials = [];
  bool isLoading = true;
  String errorMessage = '';
  final Uri uri = Uri.parse('http://127.0.0.1/atta/material.php');

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  Future<void> _loadMaterials() async {
    try {
      final response = await http.post(
        uri,
        body: {'action': 'view'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == 'success') {
          setState(() {
            materials = List.from(jsonData['data']);
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            errorMessage = jsonData['message'];
          });
        }
      } else {
        // Handle network error
        setState(() {
          isLoading = false;
          errorMessage = 'Network error: ${response.statusCode}';
        });
      }
    } catch (error) {
      // Handle other errors
      setState(() {
        isLoading = false;
        errorMessage = 'Error: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المستودع'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: "اضافة مادة",
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddMaterialDialog();
            },
          ),
        ],
        backgroundColor: Colors.black12,
      ),
      body: _buildMaterialList(),
    );
  }

  Widget _buildMaterialList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 25),
      itemCount: materials.length,
      itemBuilder: (context, index) {
        return Container(
          color: index % 2 == 0 ? Colors.black26 : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 350,
                child: Text(' ${materials[index]['name']}'),
              ),
              SizedBox(
                width: 350,
                child: Text(' ${materials[index]['name_en']}'),
              ),
              SizedBox(
                width: 100,
                child: Text(' ${materials[index]['quantity']}'),
              ),
              SizedBox(
                width: 100,
                child: Text(' ${materials[index]['p_id']}'),
              ),
              SizedBox(
                width: 100,
                child: Text(' ${materials[index]['type']}'),
              ),


              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _showEditMaterialDialog(materials[index]);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddMaterialDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController quantityController = TextEditingController();
    TextEditingController paltelIDController = TextEditingController();
    TextEditingController nameEngController = TextEditingController();
    TextEditingController typeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('اضافة مادة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'الاسم'),
              ),
              TextField(
                controller: quantityController,
                decoration: InputDecoration(labelText: 'الكمية'),
              ),
              TextField(
                controller: paltelIDController,
                decoration: InputDecoration(labelText: 'الرقم التسلسلي'),
              ),
              TextField(
                controller: nameEngController,
                decoration: InputDecoration(labelText: 'الاسم بالانجليزية'),
              ),
              TextField(
                controller: typeController,
                decoration: InputDecoration(labelText: 'الوحدة'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _addMaterial(
                  nameController.text,
                  quantityController.text,
                  paltelIDController.text,
                  nameEngController.text,
                  typeController.text,
                );
              },
              child: const Text('Submit'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('إلغاء'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addMaterial(String name, String quantity, String p_id,
      String name_en, String type) async {
    try {
      final response = await http.post(
        uri,
        body: {
          'action': 'add',
          'name': name,
          'name_en': name_en,
          'p_id': p_id,
          'quantity': quantity,
          'type': type
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == 'success') {
          // Reload teams after successful addition
          _loadMaterials();
          Navigator.pop(context); // Close the dialog
        } else {
          // Handle error
          print('Error: ${jsonData['message']}');
        }
      } else {
        // Handle network error
        print('Network error: ${response.statusCode}');
      }
    } catch (error) {
      // Handle other errors
      print('Error: $error');
    }
  }

  Future<void> _postEditMaterial(Map<String, dynamic> materials) async {
    try {
      final response = await http.post(
        uri,
        body: {
          'action': 'update',
          'id': materials['id'],
          'name': materials['name'],
          'name_en': materials['name_en'],
          'p_id': materials['p_id'],
          'quantity': materials['quantity'],
          'type': materials['type']
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == 'success') {
          _loadMaterials();
          final snackBar = SnackBar(
            content: Text(jsonData['message']),
            action: SnackBarAction(
              label: 'تخطي',
              onPressed: () {
                // Some code to undo the change.
              },
            ),
          );

          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else {
          final snackBar = SnackBar(
            content: Text('Error: ${jsonData['message']}'),
            action: SnackBarAction(
              label: 'تخطي',
              onPressed: () {
                // Some code to undo the change.
              },
            ),
          );

          // Find the ScaffoldMessenger in the widget tree
          // and use it to show a SnackBar.
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } else {
        print('Network error: ${response.statusCode}');
      }
    } catch (error) {
      // Handle other errors
      print('Error: $error');
    }
  }

  void _showEditMaterialDialog(Map<String, dynamic> material) {
    TextEditingController nameController =
        TextEditingController(text: material['name']);
    TextEditingController quantityController =
        TextEditingController(text: material['quantity'].toString());
    TextEditingController paltelIDController =
        TextEditingController(text: material['p_id']);
    TextEditingController nameEngController =
        TextEditingController(text: material['name_en']);
    TextEditingController typeController =
        TextEditingController(text: material['type']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تعديل المادة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'الاسم'),
              ),
              TextField(
                controller: nameEngController,
                decoration:
                    const InputDecoration(labelText: 'الاسم بالانجليزي'),
              ),
              TextField(
                controller: paltelIDController,
                decoration: const InputDecoration(labelText: 'الرقم التسلسلي'),
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'الكمية'),
              ),
              TextField(
                controller: typeController,
                decoration: const InputDecoration(labelText: 'الوحدة'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _editMaterial(
                    material,
                    nameController.text,
                    quantityController.text,
                    nameEngController.text,
                    paltelIDController.text,
                    typeController.text);
              },
              child: const Text('حفظ'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the edit material dialog
              },
              child: const Text('إلغاء'),
            ),
          ],
        );
      },
    );
  }

  void _editMaterial(
      Map<String, dynamic> material,
      String newName,
      String newQuantity,
      String newEngName,
      String newPaltelID,
      String newType) {
    setState(() {
      material['name'] = newName;
      material['quantity'] = newQuantity;
      material['name_en'] = newEngName;
      material['p_id'] = newPaltelID;
      material['type'] = newType;
    });

    _postEditMaterial(material);

    Navigator.pop(context); // Close the edit material dialog
  }
}

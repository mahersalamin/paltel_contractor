import 'dart:io';

import 'package:desktop/screens/team_materials_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

class RegMaterialsTeam extends StatefulWidget {
  const RegMaterialsTeam({Key? key}) : super(key: key);

  @override
  State<RegMaterialsTeam> createState() => _RegMaterialsTeamState();
}

class _RegMaterialsTeamState extends State<RegMaterialsTeam> {
  String selectedOption = '';
  String selectedMaterial = '';
  String selectedMaterialID = '';
  String errorMessage = '';

  List<Map<String, dynamic>> teams = [];
  List<Map<String, dynamic>> materials = [];
  List<TextEditingController> textControllers = [];
  List<TextEditingController> quantityControllers = [];
  List<String> matIDs = [];
  List<String> materialNames = [];

  bool isLoading = true;

  TextEditingController dateController = TextEditingController();

  final Uri teamUri = Uri.parse('http://127.0.0.1/atta/team_operations.php');
  final Uri materialUri = Uri.parse('http://127.0.0.1/atta/material.php');
  final Uri teamMaterialsUri =
      Uri.parse('http://127.0.0.1/atta/team_materials.php');

  @override
  void initState() {
    super.initState();
    _fetchTeamsData();
    _fetchMaterialsData();
  }

  Future<void> _fetchTeamsData() async {
    try {
      final response = await http.post(
        teamUri,
        body: {'action': 'view'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == 'success') {
          setState(() {
            teams = List.from(jsonData['data']);
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
    if (teams.isNotEmpty) {
      setState(() {
        selectedOption = teams.first['id'].toString();
      });
    }
  }

  Future<void> _fetchMaterialsData() async {
    try {
      final response = await http.post(
        materialUri,
        body: {'action': 'view'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          setState(() {
            materials = List.from(jsonData['data']);
            materialNames = materials
                .map((material) => material['name'].toString())
                .toList();
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            errorMessage = jsonData['message'];
          });
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Network error: ${response.statusCode}';
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: $error';
      });
    }
  }

  void _addNewRow() {
    setState(() {
      textControllers.add(TextEditingController());
      quantityControllers.add(TextEditingController());
    });
  }

  Future<void> _saveTeamMaterials(
      List savedMaterials, List savedQuantities) async {
    List<Map<String, String>> materialDataList = [];
    if (dateController.text.isEmpty) {
      const snackBar = SnackBar(
        content: Text(
          'التاريخ فارغ!',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      for (int i = 0; i < savedMaterials.length; i++) {
        if (savedMaterials[i].text == '') {
          const snackBar = SnackBar(
            content: Text('مواد بدون اسم!!'),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          break;
        } else {
          // Find the material with the corresponding name
          Map<String, dynamic>? selectedMaterial = materials.firstWhere(
            (material) => material['name'] == savedMaterials[i].text,
            orElse: () => {'name': 'not found'},
          );

          if (selectedMaterial['name'] != 'not found') {
            // Create a map with material ID, name, and quantity
            Map<String, String> materialData = {
              'material_id': selectedMaterial['id'].toString(),
              // 'name': savedMaterials[i].text,
              'quantity_taken': savedQuantities[i].text,
            };

            // Add the material data to the list
            materialDataList.add(materialData);
          }
        }
      }
      for (int i = 0; i < savedQuantities.length; i++) {
        if (savedQuantities[i].text == '') {
          const snackBar = SnackBar(
            content: Text('كميات غير معبأة!!'),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          break;
        }
      }
      String materialDataJson = json.encode(materialDataList);

      try {
        final response = await http.post(
          teamMaterialsUri,
          body: {
            'action': "add",
            'team_id': selectedOption,
            'date_taken': dateController.text,
            'transaction_type': "استلام من المستودع",
            'material_data': materialDataJson,
          },
        );

        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);

          if (jsonData['status'] == 'success') {
            final snackBar = SnackBar(
              showCloseIcon: true,
              backgroundColor: Colors.black,
              content: Text(jsonData['message']),
            );

            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            // Navigator.pop(context); // Close the dialog
          } else {
            // Handle error
            print('Error: ${jsonData['message']}');
          }
        } else {
          // Handle network error
          print('Network error: ${response.statusCode}');
        }
      } catch (error) {
        print('Error: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black26,
        title: const Text('تسجيل المواد على الفرق'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(50.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 150,
                    child: DropdownButton<String>(
                      icon: const Icon(Icons.arrow_downward_outlined),
                      value: selectedOption,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedOption = newValue!;
                        });
                      },
                      items: _buildDropdownItems(),
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      controller: dateController,
                      decoration: InputDecoration(
                        labelText: 'حدد التاريخ',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            DateTime? pickedDate = await showDatePicker(
                              helpText: 'التاريخ',
                              cancelText: 'إلغاء',
                              confirmText: 'تأكيد',
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );

                            if (pickedDate != null) {
                              dateController.text =
                                  DateFormat('yyyy-MM-dd').format(pickedDate);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('المواد:'),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                itemCount: textControllers.length,
                itemBuilder: (BuildContext context, int index) {
                  // Ensure the index is within bounds
                  if (index < textControllers.length) {
                    final TextEditingController nameController =
                        textControllers[index];
                    final TextEditingController quantityController =
                        quantityControllers[index];
                    int availableQuantity = 0; // Default value

                    // Find the material with the corresponding name
                    Map<String, dynamic>? selectedMaterial =
                        materials.firstWhere(
                      (material) => material['name'] == nameController.text,
                      orElse: () => {'name': 'not found'},
                    );

                    selectedMaterial['name'] == 'not found'
                        ? availableQuantity = 0
                        : availableQuantity =
                            int.parse(selectedMaterial['quantity']);

                    return Row(
                      children: [
                        Expanded(
                          child: MaterialNameAutocomplete(
                            materialNames: materialNames,
                            onSelected: (String selection) {
                              nameController.text = selection;

                              // Update available quantity when a material is selected
                              Map<String, dynamic>? selectedMaterial =
                                  materials.firstWhere(
                                (material) => material['name'] == selection,
                                orElse: () => {'name': 'empty'},
                              );

                              setState(() {
                                availableQuantity =
                                    int.parse(selectedMaterial['quantity']);
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 300,
                          child: TextField(
                            controller: quantityController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'الكمية',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 180,
                          child: Text(
                            'الكمية المتاحة: $availableQuantity',
                            style: TextStyle(
                                color: availableQuantity > 0
                                    ? Colors.green
                                    : Colors.red),
                          ),
                        ),
                        // const SizedBox(width: 30),
                      ],
                    );
                  } else {
                    // Handle the case where the index is out of bounds (optional)
                    return Container();
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              FloatingActionButton(
                heroTag: 'عرض مواد',
                tooltip: 'عرض مواد الفريق',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            TeamMaterialsPage(team_id: selectedOption)),
                  );
                },
                child: const Icon(Icons.list),
              ),
              FloatingActionButton(
                heroTag: 'اضافة مادة',
                tooltip: 'اضافة مادة',
                onPressed: _addNewRow,
                child: const Icon(Icons.add),
              ),
              FloatingActionButton(
                heroTag: 'حفظ',
                tooltip: 'حفظ',
                onPressed: () {
                  if (textControllers.isNotEmpty &&
                      quantityControllers.isNotEmpty) {
                    _saveTeamMaterials(textControllers, quantityControllers);
                  } else {
                    const snackBar = SnackBar(
                      showCloseIcon: true,
                      backgroundColor: Colors.black,
                      content: Text(
                        'لا توجد مواد لإضافتها!',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                },
                child: const Icon(Icons.save),
              )
            ],
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildDropdownItems() {
    return teams.map((team) {
      return DropdownMenuItem<String>(
        value: team['id'].toString(),
        child: Text(team['name']),
      );
    }).toList();
  }
}

class MaterialNameAutocomplete extends StatelessWidget {
  final List<String> materialNames;
  final Function(String) onSelected;

  const MaterialNameAutocomplete({
    super.key,
    required this.materialNames,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        return materialNames.where((String option) {
          return option
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        onSelected(selection);
      },
      fieldViewBuilder: (BuildContext context,
          TextEditingController textEditingController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted) {
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          onChanged: (String value) {
            // You can add additional logic here if needed
          },
          decoration: const InputDecoration(
            labelText: 'الإسم',
          ),
        );
      },
      optionsViewBuilder: (BuildContext context,
          AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
        return MaterialNameOptions(
          materialNames: materialNames,
          onSelected: onSelected,
        );
      },
    );
  }
}

class MaterialNameOptions extends StatelessWidget {
  final List<String> materialNames;
  final AutocompleteOnSelected<String> onSelected;

  const MaterialNameOptions({
    super.key,
    required this.materialNames,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: 200.0,
        child: ListView.builder(
          itemCount: materialNames.length,
          itemBuilder: (BuildContext context, int index) {
            final String materialName = materialNames[index];
            return GestureDetector(
              onTap: () {
                onSelected(materialName);
              },
              child: ListTile(
                title: Text(materialName),
              ),
            );
          },
        ),
      ),
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class TeamMaterialsPage extends StatefulWidget {
  final String team_id;

  const TeamMaterialsPage({super.key, required this.team_id});

  @override
  State<TeamMaterialsPage> createState() => _TeamMaterialsPageState();
}

class _TeamMaterialsPageState extends State<TeamMaterialsPage> {
  final Uri uri = Uri.parse('http://127.0.0.1/atta/team_materials.php');
  bool isLoading = true;
  String errorMessage = '';
  List<Map<String, dynamic>> materials = [];
  List<TextEditingController> controllers = [];
  final Uri teamMaterialsUri = Uri.parse('http://127.0.0.1/atta/team_materials_logs.php');

  Future<void> _loadMaterials() async {
    try {
      final response = await http.post(
        uri,
        body: {'action': 'view', 'team_id': widget.team_id},
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
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadMaterials();
    controllers = materials.map((material) {
      return TextEditingController(text: material['used_quantity'].toString());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Map<String, dynamic>>> groupedMaterials =
        groupMaterialsByDate(materials);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'سجل استلامات الفريق'
        ),
      ),
      body: ListView.builder(
        itemCount: groupedMaterials.keys.length,
        itemBuilder: (BuildContext context, int index) {
          String dateTaken = groupedMaterials.keys.elementAt(index);
          List<Map<String, dynamic>> groupedRows = groupedMaterials[dateTaken]!;

          return ExpansionTile(
            collapsedBackgroundColor: Colors.white,
            tilePadding: const EdgeInsets.symmetric(vertical: 10),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // print(groupedMaterials[dateTaken]);
                _showEditMaterialDialog(groupedMaterials[dateTaken]!);
              },
            ),
            title: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(' $dateTaken'),
            ),
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: groupedRows.length,
                itemBuilder: (BuildContext context, int childIndex) {
                  Map<String, dynamic> row = groupedRows[childIndex];
                  return Container(
                    color: index % 2 == 0 ? Colors.black26 : Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 350,
                          child: Text(' ${row['material_name']}'),
                        ),
                        SizedBox(
                          width: 350,
                          child: Text(' ${row['stock_quantity']}'),
                        ),
                        SizedBox(
                          width: 100,
                          child: Text(' ${row['quantity']}'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditMaterialDialog(List<Map<String, dynamic>> savedMaterial) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        List<TextEditingController> textControllers = List.generate(
            savedMaterial.length, (index) => TextEditingController());
        List<TextEditingController> dateControllers = List.generate(
            savedMaterial.length, (index) => TextEditingController());

        List<String> errorTextList =
            List.generate(savedMaterial.length, (index) => '');
        List<String> errorDateList =
            List.generate(savedMaterial.length, (index) => '');

        return AlertDialog(
          title: const Center(child: Text('تسجيل شغل')),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < savedMaterial.length; i++)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(
                            text: savedMaterial[i]['material_name']),
                        decoration:
                            const InputDecoration(labelText: 'اسم المادة'),
                        readOnly: true,
                        enabled: false,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(
                            text: savedMaterial[i]['quantity'].toString()),
                        decoration:
                            const InputDecoration(labelText: 'المستلمة'),
                        readOnly: true,
                        enabled: false,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        onChanged: (String value) {
                          setState(() {
                            if (int.parse(value) >
                                int.parse(savedMaterial[i]['quantity'])) {
                              errorTextList[i] =
                                  'كمية ${savedMaterial[i]['material_name']} المستخدمة أعلى من المستلمة';
                            } else {
                              errorTextList [i] = ''; // Reset error message
                            }
                          });
                        },
                        controller: textControllers[i],
                        decoration: const InputDecoration(
                          labelText: 'المستخدمة',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(

                        controller: dateControllers[i],
                        decoration: InputDecoration(
                          labelText: 'تاريخ الاستخدام',
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
                                dateControllers[i].text =
                                    DateFormat('yyyy-MM-dd').format(pickedDate);
                              }
                            },
                          ),
                        ),
                      ),
                    )
                  ],
                ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                int i = 0;
                int j = 0;
                for (var controller in textControllers) {
                  if(controller.text.isEmpty){
                    errorTextList[i] =
                    'كمية ${savedMaterial[i]['material_name']} المستخدمة فارغة';
                  }
                  i++;
                }
                for (var dateController in dateControllers) {
                  if(dateController.text.isEmpty){
                    errorDateList[j] =
                    ' تاريخ العمل للمادة  ${savedMaterial[j]['material_name']} فارغ';
                  }
                  j++;
                }

                if (errorTextList.every((errorText) => errorText.isEmpty)
                    && errorDateList.every((element) => element.isEmpty)) {

                  for (int i = 0; i < savedMaterial.length; i++) {
                    savedMaterial[i]['used_quantity'] =
                        int.parse(textControllers[i].text);
                    savedMaterial[i]['used_date'] = dateControllers[i].text;
                  }
                  saveLog(savedMaterial);
                  Navigator.pop(context);
                } else {

                  for (var errorText in errorTextList) {
                    if(errorText.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(errorText),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                  for (var errorDate in errorDateList) {
                    if(errorDate.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(errorDate),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }

                }
              },
              child: const Text('تأكيد'),
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

  Future<void> saveLog(List<Map<String, dynamic>> savedMaterials) async {
    // print(jsonEncode(savedMaterials));
    try {
      final response = await http.post(
        teamMaterialsUri,
        body: {
          'action': 'add',
          'team_id': widget.team_id,
          'data': jsonEncode(savedMaterials),
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == 'success') {
          // Handle success
          // Navigator.pop(context);
          _loadMaterials();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(jsonData['message']),
              duration: const Duration(seconds: 2),
            ),
          );
          print('Log added successfully');
        } else {
          // Handle error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(jsonData['message']),
              duration: const Duration(seconds: 2),
            ),
          );
          print('Error adding Log: ${jsonData['message']}');
        }
      } else {
        // Handle network error

        print('Network error: ${response.statusCode}');
      }
    } catch (error) {
      // Handle other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$error'),
          duration: const Duration(seconds: 2),
        ),
      );
      print('Error: $error');
    }
  }


  Map<String, List<Map<String, dynamic>>> groupMaterialsByDate(
      List<Map<String, dynamic>> materials) {
    Map<String, List<Map<String, dynamic>>> groupedMaterials = {};

    for (Map<String, dynamic> material in materials) {
      String dateTaken = material['date_taken'];
      if (!groupedMaterials.containsKey(dateTaken)) {
        groupedMaterials[dateTaken] = [];
      }
      groupedMaterials[dateTaken]!.add(material);
    }

    return groupedMaterials;
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 350,
              child: Text(' الإسم'),
            ),
            SizedBox(
              width: 350,
              child: Text('الكمية في المستودع'),
            ),
            SizedBox(
              width: 150,
              child: Text(' تاريخ الاستلام'),
            ),
            SizedBox(
              width: 150,
              child: Text('الكمية المستلمة'),
            ),



            SizedBox(width: 24,),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: groupedMaterials.keys.length,
        itemBuilder: (BuildContext context, int index) {
          String dateTaken = groupedMaterials.keys.elementAt(index);
          List<Map<String, dynamic>> groupedRows =
          groupedMaterials[dateTaken]!;

          return ExpansionTile(
            collapsedBackgroundColor:  Colors.white,
            tilePadding: const EdgeInsets.symmetric(vertical: 10),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {

                _showEditMaterialDialog(groupedMaterials);
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

  void _showEditMaterialDialog(Map<String, dynamic> material) {



    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تسجيل شغل'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (Map<String, dynamic> material in materials)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(text: material['material_name']),
                        decoration: const InputDecoration(labelText: 'اسم المادة'),
                        readOnly: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(text: material['quantity'].toString()),
                        decoration: const InputDecoration(labelText: 'المستلمة'),
                        readOnly: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(),
                        decoration: const InputDecoration(labelText: 'المستخدمة'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed:(){
                print(materials);
                // _saveLog(materials)
              },// _saveLog,
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

  Future<void> _saveLog(
      List savedMaterials, List savedQuantities
      ) async {
    List<Map<String, String>> materialDataList = [];
    // if (dateController.text.isEmpty) {
    //   const snackBar = SnackBar(
    //     content: Text(
    //       'التاريخ فارغ!',
    //       style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
    //     ),
    //   );
    //
    //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
    // } else {
    //   for (int i = 0; i < savedMaterials.length; i++) {
    //     if (savedMaterials[i].text == '') {
    //       const snackBar = SnackBar(
    //         content: Text('مواد بدون اسم!!'),
    //       );
    //       ScaffoldMessenger.of(context).showSnackBar(snackBar);
    //       break;
    //     } else {
    //       // Find the material with the corresponding name
    //       Map<String, dynamic>? selectedMaterial = materials.firstWhere(
    //             (material) => material['name'] == savedMaterials[i].text,
    //         orElse: () => {'name': 'not found'},
    //       );
    //
    //       if (selectedMaterial['name'] != 'not found') {
    //         // Create a map with material ID, name, and quantity
    //         Map<String, String> materialData = {
    //           'material_id': selectedMaterial['id'].toString(),
    //           // 'name': savedMaterials[i].text,
    //           'quantity_taken': savedQuantities[i].text,
    //         };
    //
    //         // Add the material data to the list
    //         materialDataList.add(materialData);
    //       }
    //     }
    //   }
    //   for (int i = 0; i < savedQuantities.length; i++) {
    //     if (savedQuantities[i].text == '') {
    //       const snackBar = SnackBar(
    //         content: Text('كميات غير معبأة!!'),
    //       );
    //       ScaffoldMessenger.of(context).showSnackBar(snackBar);
    //       break;
    //     }
    //   }
    //   String materialDataJson = json.encode(materialDataList);
    //
    //   try {
    //     final response = await http.post(
    //       teamMaterialsUri,
    //       body: {
    //         'action': "add",
    //         'team_id': selectedOption,
    //         'date_taken': dateController.text,
    //         'transaction_type': "استلام من المستودع",
    //         'material_data': materialDataJson,
    //       },
    //     );
    //
    //     if (response.statusCode == 200) {
    //       final jsonData = json.decode(response.body);
    //
    //       if (jsonData['status'] == 'success') {
    //         final snackBar = SnackBar(
    //           showCloseIcon: true,
    //           backgroundColor: Colors.black,
    //           content: Text(jsonData['message']),
    //         );
    //
    //         ScaffoldMessenger.of(context).showSnackBar(snackBar);
    //         // Navigator.pop(context); // Close the dialog
    //       } else {
    //         // Handle error
    //         print('Error: ${jsonData['message']}');
    //       }
    //     } else {
    //       // Handle network error
    //       print('Network error: ${response.statusCode}');
    //     }
    //   } catch (error) {
    //     print('Error: $error');
    //   }
    // }
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

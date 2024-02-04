import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override

  _TeamPageState createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  List<Map<String, dynamic>> teams = [];
  bool isLoading = true;
  String errorMessage = '';
  final Uri uri = Uri.parse('http://127.0.0.1/atta/team_operations.php');

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    try {
      final response = await http.post(
        uri,
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
  }

  Future<void> _addTeam(String name, String type) async {
    try {
      final response = await http.post(
        uri,
        body: {'action': 'add', 'name': name, 'type': type},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == 'success') {
          // Reload teams after successful addition
          _loadTeams();
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
  Future<void> _editTeam(int teamId) async {

  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
            ? Center(
          child: Text(
            'Error: $errorMessage',
            style: const TextStyle(color: Colors.red),
          ),
        )
            : ListView.builder(
          itemCount: teams.length,
          itemBuilder: (context, index) {
            return Container(
              color: index % 2 == 0 ? Colors.black12 : null, // Set color for even rows
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(teams[index]['name']),
                    Text(teams[index]['type']),
                  ],
                ),
                leading: Text(teams[index]['id']),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'تعديل',
                  onPressed: () {

                    _showEditTeamDialog(
                      int.parse(teams[index]['id']),
                      teams[index]['name'],
                      teams[index]['type'],
                    );
                  },
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: 'اضافة فريق',
          onPressed: () {
            _showAddTeamDialog();
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showAddTeamDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController typeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('إنشاء فريق جديد'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'الإسم'),
              ),
              TextField(
                controller: typeController,
                decoration: const InputDecoration(labelText: 'النوع'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _addTeam(nameController.text, typeController.text);
              },
              child: const Text('حفظ'),
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

  void _showEditTeamDialog(int teamId, String currentName, String currentType) {
    TextEditingController nameController = TextEditingController(text: currentName);
    TextEditingController typeController = TextEditingController(text: currentType);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(

          title: const Center(child: Text('تعديل بيانات الفريق')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                textDirection: TextDirection.rtl,
                controller: nameController,
                decoration: const InputDecoration(labelText: 'الإسم',),
              ),
              TextField(
                textDirection: TextDirection.rtl,
                controller: typeController,
                decoration: const InputDecoration(labelText: 'النوع'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                _submitEditTeam(teamId, nameController.text, typeController.text);
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitEditTeam(int teamId, String newName, String newType) async {
    try {
      final response = await http.post(
        uri,
        body: {'action': 'edit', 'id': teamId.toString(), 'name': newName, 'type': newType},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == 'success') {
          // Reload teams after successful edit
          _loadTeams();
          Navigator.pop(context); // Close the edit dialog
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

}

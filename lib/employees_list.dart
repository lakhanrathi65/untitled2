import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'add_edit_employee.dart';
import 'database_helper.dart';
import 'employee.dart';
class EmployeesList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return EmployeesListState();
  }
}

class EmployeesListState extends State<EmployeesList> {
  List<Employee> listEmployees = [];



  String? data;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    print(directory.path);
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.json');
  }

  Future<String> readContent() async {
    try {
      final file = await _localFile;
      // Read the file
      String contents = await file.readAsString();
      // Returning the contents of the file
      return contents;
    } catch (e) {
      // If encountering an error, return
      return 'Error!';
    }
  }

  Future<File> writeContent() async {
    final file = await _localFile;
    // Write the file
    return file.writeAsString('Hello Folk');
  }


  getEmployees() async {
    List<Map<String, dynamic>> listMap = await DatabaseHelper.instance.queryAllRows();
    final file = await _localFile;
    // file.writeAsStringSync("[{}",mode: FileMode.append);
    // setState(() {
    //   for(int i =0;i<listMap.length-1;i++){
    //     file.writeAsStringSync(json.encode(listMap[i]),mode: FileMode.append);
    //     file.writeAsStringSync(",",mode: FileMode.append);
    //   }
    //   file.writeAsStringSync(json.encode(listMap[listMap.length-1]),mode: FileMode.append);
    // });
    // file.writeAsStringSync("]",mode: FileMode.append);
    readContent().then((String value) {
      setState(() {
        print(value);
        if(value.isNotEmpty) {
          data = value;
          value = "$value]";
          List jsonResponse = jsonDecode(value);
          for (int i = 1; i < jsonResponse.length; i++) {
            Employee player = Employee(empId: jsonResponse[i]['emp_id'],
                empName: jsonResponse[i]['emp_name'],
                empSalary: jsonResponse[i]['emp_salary'],
                empAge: jsonResponse[i]['emp_age']);
            listEmployees.add(player);
          }
        }

      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getEmployees();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Flutter Sqflite Sample"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => AddEditEmployee(false)));
              },
            )
          ],
        ),
        body: Container(
            padding: EdgeInsets.all(15),
            child: ListView.builder(
                itemCount: listEmployees.length,
                itemBuilder: (context, position) {
                  Employee getEmployee = listEmployees[position];
                  var salary = getEmployee.empSalary;
                  var age = getEmployee.empAge;
                  return Card(
                    elevation: 8,
                    child: Container(
                      height: 80,
                      padding: EdgeInsets.all(15),
                      child: Stack(
                        children: <Widget>[
                          Align(
                              alignment: Alignment.topLeft,
                              child: Text(getEmployee.empName.toString(),
                                  style: TextStyle(fontSize: 18))),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              margin: EdgeInsets.only(right: 45),
                              child: IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => AddEditEmployee(
                                                true, getEmployee)));
                                  }),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: (){
                                  // DatabaseHelper.instance.delete(getEmployee.empId);
                                  setState(() => {
                                    listEmployees.removeWhere((item) => item.empId == getEmployee.empId)
                                  });
                                }),
                          ),
                          Align(
                              alignment: Alignment.bottomLeft,
                              child: Text("Salary: $salary | Age: $age",
                                  style: TextStyle(fontSize: 18))),
                        ],
                      ),
                    ),
                  );
                })),
      ),
    );
  }
}

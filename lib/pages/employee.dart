import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:random_string/random_string.dart';
import 'package:task_management/service/database.dart';

class Employee extends StatefulWidget {
  const Employee({super.key});

  @override
  State<Employee> createState() => _EmployeeState();
}

class _EmployeeState extends State<Employee> {
  TextEditingController nameController = TextEditingController();
  TextEditingController deadlineController = TextEditingController();
  TextEditingController taskController = TextEditingController();
  String deadlineError = ''; // Error message for invalid deadline

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Task",
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              "Form",
              style: TextStyle(
                  color: Colors.orange,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(left: 20.0, top: 30, right: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Name",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10.0),
                Container(
                  padding: EdgeInsets.only(left: 10.0),
                  decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(10.0)),
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                        hintText: "Enter name",
                        hintStyle: TextStyle(
                          color: Colors.grey, // Color of the hint text
                        ),
                        border: InputBorder.none),
                  ),
                ),
                SizedBox(height: 20.0),
                Text(
                  "Deadline",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10.0),
                Container(
                  padding: EdgeInsets.only(left: 10.0),
                  decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(10.0)),
                  child: TextField(
                    controller: deadlineController,
                    keyboardType: TextInputType.number, // Numeric keyboard
                    decoration: InputDecoration(
                      hintText: "Enter task deadline in days",
                      hintStyle: TextStyle(
                        color: Colors.grey, // Color of the hint text
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                if (deadlineError.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      deadlineError,
                      style: TextStyle(
                        color: Colors.red, // Color for error message
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                SizedBox(height: 20.0),
                Text(
                  "Task",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10.0),
                Container(
                  padding: EdgeInsets.only(left: 10.0),
                  decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(10.0)),
                  child: TextField(
                    controller: taskController,
                    decoration: InputDecoration(
                        hintText: "Enter task or work",
                        hintStyle: TextStyle(
                          color: Colors.grey, // Color of the hint text
                        ),
                        border: InputBorder.none),
                  ),
                ),
                SizedBox(height: 30.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Validate deadline field
                      if (deadlineController.text.isEmpty ||
                          !RegExp(r'^[0-9]+$').hasMatch(deadlineController.text)) {
                        setState(() {
                          deadlineError = 'deadline data should be in numbers'; // Set error message
                        });
                      } else {
                        // Clear the error message
                        setState(() {
                          deadlineError = '';
                        });

                        String Id = randomAlphaNumeric(10);
                        Map<String, dynamic> employeeInfoMap = {
                          "Name": nameController.text,
                          "Deadline": deadlineController.text,
                          "Id": Id,
                          "Task": taskController.text
                        };
                        await DatabaseMethods()
                            .addEmployeeDetails(employeeInfoMap, Id)
                            .then((value) {
                          Fluttertoast.showToast(
                            msg: "Added successfully",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );

                          // Clear the text fields after submission
                          nameController.clear();
                          deadlineController.clear();
                          taskController.clear();

                          // Navigate back to the previous page
                          Navigator.pop(context);
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      elevation: 6.0,
                      // Change color when hovering or pressed
                    ).copyWith(
                      backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.hovered)) {
                            return Colors.orange; // Color when hovered
                          } else if (states.contains(MaterialState.pressed)) {
                            return Colors.orange.shade700; // Darker color when clicked
                          }
                          return Colors.blue; // Default button color
                        },
                      ),
                    ),
                    child: Text("Add",
                        style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

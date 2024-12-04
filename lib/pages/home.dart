import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:task_management/pages/employee.dart';
import 'package:task_management/service/database.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController nameController = TextEditingController();
  TextEditingController deadlineController = TextEditingController();
  TextEditingController taskController = TextEditingController();
  TextEditingController searchController = TextEditingController(); // Controller for search bar
  Stream? employeeStream;
  List<DocumentSnapshot>? allEmployees;
  List<DocumentSnapshot>? filteredEmployees;

  getontheload() async {
    employeeStream = await DatabaseMethods().getEmployeeDetails();
    employeeStream!.listen((event) {
      setState(() {
        allEmployees = event.docs;
        filteredEmployees = allEmployees; // Initially all employees are shown
      });
    });
  }

  @override
  void initState() {
    getontheload();
    super.initState();
  }

  void searchEmployee(String query) {
    List<DocumentSnapshot> searchResults = [];
    if (query.isNotEmpty) {
      searchResults = allEmployees!.where((employee) {
        String name = employee["Name"].toString().toLowerCase();
        return name.contains(query.toLowerCase());
      }).toList();
    } else {
      searchResults = allEmployees!;
    }

    setState(() {
      filteredEmployees = searchResults;
    });
  }

  Widget allEmployeeDetails() {
    return filteredEmployees != null && filteredEmployees!.isNotEmpty
        ? ListView.builder(
            itemCount: filteredEmployees!.length,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = filteredEmployees![index];
              return Container(
                margin: EdgeInsets.only(bottom: 20.0),
                child: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Name : " + ds["Name"],
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
                            GestureDetector(
                              onTap: () {
                                nameController.text = ds["Name"];
                                deadlineController.text = ds["Deadline"];
                                taskController.text = ds["Task"];
                                EditEmployeeDetails(ds["Id"]);
                              },
                              child: Icon(
                                Icons.edit,
                                color: Colors.orange, // Change edit icon color here
                              ),
                            ),
                            SizedBox(width: 5.0),
                            GestureDetector(
                              onTap: () async {
                                await DatabaseMethods()
                                    .deleteEmployeeDetail(ds["Id"]);
                              },
                              child: Icon(
                                Icons.delete,
                                color: Colors.orange, // Change delete icon color here
                              ),
                            )
                          ],
                        ),
                        Text(
                          "Deadline : " + ds["Deadline"],
                          style: TextStyle(
                              color: Colors.orange,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Task : " + ds["Task"],
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
              );
            })
        : Center(
            child: Text(
              "No Result",
              style: TextStyle(
                  color: Colors.red, fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Add a Drawer here
      drawer: Drawer(
      
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.orange), // Change the icon color here
                title: Text(
                  'Logout',
                  style: TextStyle(color: Colors.blue,fontSize: 20.0,fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  // Implement your logout logic here
                  Navigator.pop(context); // Close the drawer
                  // For example, navigate to login screen
                  // Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
        ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Employee()));
        },
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        hoverColor: Colors.orange,
        child: Icon(Icons.add),
      ),
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
              "Management",
              style: TextStyle(
                  color: Colors.orange,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 30.0),
        child: Column(
          children: [
            // Search bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: const Color.fromARGB(255, 218, 215, 215)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search by name...",
                  border: InputBorder.none,
                  icon: Icon(Icons.search),
                ),
                onChanged: searchEmployee, // Call the search function
              ),
            ),
            SizedBox(height: 20),
            Expanded(child: allEmployeeDetails()),
          ],
        ),
      ),
    );
  }

  Future EditEmployeeDetails(String id) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            content: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.cancel)),
                      SizedBox(
                        width: 60.0,
                      ),
                      Text(
                        "Edit",
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Details",
                        style: TextStyle(
                            color: Colors.orange,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
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
                      decoration: InputDecoration(border: InputBorder.none),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
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
                      decoration: InputDecoration(border: InputBorder.none),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
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
                      decoration: InputDecoration(border: InputBorder.none),
                    ),
                  ),

                  SizedBox(
                    height: 30.0,
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        Map<String, dynamic> updateInfo = {
                          "Name": nameController.text,
                          "Deadline": deadlineController.text,
                          "Id": id,
                          "Task": taskController.text
                        };
                        

      await DatabaseMethods().updateEmployeeDetail(id, updateInfo).then((value) {
        Navigator.pop(context);
      });
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      elevation: 6.0,
    ).copyWith(
      backgroundColor: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.hovered)) {
            return Colors.orange; // Change color when hovered
          } else if (states.contains(MaterialState.pressed)) {
            return Colors.orange.shade700; // Darker orange when pressed
          }
          return Colors.blue; // Default button color
        },
      ),
    ),
    child: Text(
      "Update",
      style: TextStyle(
        color: Colors.white,
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
)
                ],
              ),
            ),
          ));
}
import 'package:contactsbuddy_master/screens/addContact.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/contactModel.dart';
import '../utilities/dbHelper.dart';

class MyContacts extends StatefulWidget {
  const MyContacts({super.key});

  @override
  _MyContactsState createState() => _MyContactsState();
}

class _MyContactsState extends State<MyContacts> {
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  late Future<List<Contact>> _contactList;
  late DatabaseHelper _dbHelper;

  String contactListSearch = "";

  void _refreshTaskList() async {
    setState(() {
      _contactList = _dbHelper.fetchContacts(contactListSearch);
    });
  }

  @override
  void initState() {
    _dbHelper = DatabaseHelper.instance;
    _refreshTaskList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
   String? todoListSearch;
    _refreshTaskList();
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => AddContacts(
                          refreshList: _refreshTaskList,
                          task: todoListSearch,
                        )));
          },
          child: const Icon(Icons.add),
        ),
        body: FutureBuilder(
          future: _contactList,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final int completedTask = snapshot.data!
                .where((Contact task) => task.status == 1)
                .toList()
                .length;

            return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  vertical: 60,
                  horizontal: 25,
                ),
                itemCount: 1 + snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "My Tasks",
                          style: TextStyle(
                              fontSize: 30,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Completed $completedTask of ${snapshot.data!.length}",
                          style: TextStyle(
                              fontSize: 15,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        TextField(
                          style: const TextStyle(color: Colors.white),
                          textCapitalization: TextCapitalization.sentences,
                          onChanged: (value) {
                            setState(() {
                              todoListSearch = value;
                            });
                          },
                          decoration: const InputDecoration(
                              labelText: 'Search',
                              labelStyle: TextStyle(color: Colors.white),
                              prefixIcon:
                                  Icon(Icons.search, color: Color(0XFF06BAD9)),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25)),
                              )),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    );
                  }
                  return _buildTask(snapshot.data![index - 1]);
                });
          },
        ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }

  Widget _buildTask(task) {
    String date = "";

    if (task?.date != null) {
      date = _dateFormat.format(task.date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(),
      child: Material(
        color: Colors.transparent,
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
              decoration: BoxDecoration(
                gradient: task?.status == 0
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                            Color(0XFF70A9FF),
                            Color(0XFF90BCFF),
                          ])
                    : const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                            Color(0XFFFFC026),
                            Color(0XFFFFA21D),
                          ]),
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0XFF515151).withOpacity(.25),
                      blurRadius: 6,
                      offset: const Offset(2, 5))
                ],
              ),
              child: ListTile(
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: Text(
                    task?.title != null ? task.title : "Task",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                subtitle: Text("$date . ${task?.priority}",
                    style: const TextStyle(
                      fontSize: 15,
                    )),
                trailing: Checkbox(
                  onChanged: (val) {
                    task?.status = val! ? 1 : 0;

                    _dbHelper.updateContact(task);
                    _refreshTaskList();
                  },
                  value: task?.status == 1 ? true : false,
                  activeColor: const Color(0XFF52001B),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddContacts(
                      task: task,
                      refreshList: _refreshTaskList,
                    ),
                  ),
                ),
                leading: task?.status == 0
                    ? Icon(
                        Icons.event,
                        color: task?.priority == "High"
                            ? Colors.red
                            : task?.priority == "Medium"
                                ? const Color(0XFF0776CA)
                                : const Color(0XFF0AA51A),
                      )
                    : Icon(
                        Icons.check,
                        color: task?.priority == "High"
                            ? Colors.red
                            : const Color(0XFF0E1D35),
                      ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 5),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
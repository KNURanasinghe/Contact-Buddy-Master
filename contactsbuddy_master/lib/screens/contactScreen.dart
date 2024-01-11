import 'package:flutter/material.dart';

import '../models/contactModel.dart';
import '../utilities/dbHelper.dart';
import 'addContact.dart';

class MyContacts extends StatefulWidget {
  const MyContacts({super.key});

  @override
  _MyContactsState createState() => _MyContactsState();
}

class _MyContactsState extends State<MyContacts> {
  late Future<List<Contact>> _contactList;
  late DatabaseHelper _dbHelper;

  String contactListSearch = "";
  String todoListSearch = "";

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
                        id: null)));
          },
          child: const Icon(Icons.person_add_alt_1),
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
                .where((Contact task) => task.isDone!)
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
                          "Contact Buddy",
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
        ));
  }

  Widget _buildTask(Contact task) {
    String date = "";

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(),
        child: Material(
          color: Colors.transparent,
          elevation: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 10.0),
                decoration: BoxDecoration(
                  gradient: !task.isDone!
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                              Color.fromARGB(226, 106, 183, 250),
                              Color.fromARGB(255, 80, 149, 252),
                            ])
                      : const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                              Color.fromARGB(217, 142, 241, 67),
                              Color.fromARGB(255, 29, 255, 195),
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
                      task.title != null ? "${task.title}" : "Contact",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  subtitle: Text("$date . ${task.priority}",
                      style: const TextStyle(
                        fontSize: 15,
                      )),
                  trailing: Checkbox(
                    value: task.isDone!,
                    onChanged: (val) {
                      setState(() {
                        task.isDone = val;
                      });

                      _dbHelper.markDone(task, task.id!);
                    },
                    activeColor: const Color(0XFF52001B),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddContacts(
                          task: task.title.toString(),
                          refreshList: _refreshTaskList,
                          id: task.id),
                    ),
                  ),
                  leading: !task.isDone!
                      ? Icon(
                          Icons.person,
                          color: task.priority == "Family"
                              ? Colors.red
                              : task.priority == "Office"
                                  ? const Color.fromARGB(214, 1, 47, 83)
                                  : const Color(0XFF0AA51A),
                        )
                      : Icon(
                          Icons.check,
                          color: task.priority == "Family"
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
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/contactModel.dart';
import '../utilities/dbHelper.dart';

class AddContacts extends StatefulWidget {
  Function refreshList;
  final Contact? contact;
  final String task;

  AddContacts(
      {super.key, required this.task, required this.refreshList, this.contact});

  @override
  _AddTaskState createState() => _AddTaskState();
}

class _AddTaskState extends State<AddContacts> {
  _AddTaskState({this.title, this.date, this.status, this.priority});

  final _formKey = GlobalKey<FormState>();
  String? title, priority;
  late int? status;
  DateTime? date;
  final TextEditingController _dateController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  final List<String> _priorities = ["Friends", "Medium", "High"];
  late DatabaseHelper _dbHelper;
  int id = 0;

  @override
  void initState() {
    _dbHelper = DatabaseHelper.instance;

    title = widget.task.toString();
    date = date;
    priority = priority;
    status = 0;

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _dateController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 40,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                widget.task.isEmpty ? "Add Contact" : "Update Conatct",
                style: TextStyle(
                  fontSize: 30,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 20.0),
                        child: TextFormField(
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              labelText: "Contact",
                              labelStyle: const TextStyle(
                                  fontSize: 20, color: Colors.blueGrey),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          textInputAction: TextInputAction.next,
                          validator: (val) => (val.toString().isEmpty)
                              ? "Please add a contact"
                              : null,
                          onSaved: (val) => title = val.toString(),
                          initialValue: title,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 20.0),
                        child: TextFormField(
                          style: const TextStyle(color: Colors.blueGrey),
                          decoration: InputDecoration(
                              labelText: "Date",
                              labelStyle: const TextStyle(fontSize: 20),
                              border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.pinkAccent),
                                  borderRadius: BorderRadius.circular(10))),
                          textInputAction: TextInputAction.next,
                          onTap: _datePicker,
                          controller: _dateController,
                          readOnly: true,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 20.0),
                        child: DropdownButtonFormField(
                          iconEnabledColor: Theme.of(context).primaryColor,
                          iconSize: 25,
                          isDense: true,
                          dropdownColor: Colors.white,
                          items: _priorities
                              .map((String priority) => DropdownMenuItem(
                                  value: priority,
                                  child: Text(
                                    priority,
                                    style: const TextStyle(
                                        color: Colors.blueGrey, fontSize: 18),
                                  )))
                              .toList(),
                          icon:
                              const Icon(Icons.arrow_drop_down_circle_outlined),
                          validator: (val) =>
                              (val == null) ? "Please add a priority" : null,
                          onSaved: (val) => priority = val.toString(),
                          decoration: InputDecoration(
                              labelText: "Priority",
                              labelStyle: const TextStyle(fontSize: 20),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          onChanged: (val) {
                            setState(() {
                              priority = val.toString();
                            });
                          },
                          value: priority,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * .07,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0XFF06BAD9),
                            ),
                            borderRadius: BorderRadius.circular(10)),
                        child: IconButton(
                          icon: Icon(
                            widget.task.isEmpty
                                ? Icons.note_add_rounded
                                : Icons.update,
                            size: 40,
                            color: const Color(0XFF06BAD9),
                          ),
                          onPressed: () {
                            _addTask();
                          },
                        ),
                      ),
                    ],
                  )),
              const SizedBox(
                height: 20,
              ),
              widget.task.isEmpty
                  ? Container(
                      height: MediaQuery.of(context).size.height * .07,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0XFF06BAD9),
                          ),
                          borderRadius: BorderRadius.circular(10)),
                      child: IconButton(
                        icon: const Icon(
                          Icons.delete_forever_rounded,
                          size: 40,
                          color: Color(0XFF06BAD9),
                        ),
                        onPressed: () {
                          _delete();
                        },
                      ),
                    )
                  : const SizedBox.shrink()
            ],
          ),
        ),
      ),
    );
  }

  _datePicker() async {
    final DateTime? sdate = await showDatePicker(
        context: context,
        initialDate: date ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2050));

    if (sdate != null) {
      setState(() {
        date = sdate;
      });
      _dateController.text = _dateFormat.format(date!);
    }
  }

  _addTask() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Contact task;

      task = Contact(
        title: title,
        date: date,
        priority: priority,
        id: 1,
      );

      _dbHelper.updateContact(task);

      widget.refreshList();

      Navigator.pop(context);
    }
  }

  _delete() {
    // Assuming widget.task is of type Contact
    if (widget.task is Contact) {
      _dbHelper.deleteContact(widget.task as int);
      widget.refreshList();
      Navigator.pop(context);
    }
  }
}

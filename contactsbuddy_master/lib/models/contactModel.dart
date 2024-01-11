class Contact {
  int?id;
  String? title;
  int? date;
  String? priority;


  Contact({ this.title,  this.date,  this.priority,  int? id, });
  Contact.withId({this.id, this.title, this.date, this.priority, });

  static const tblName = "task_table";
  static const colId = "id";
  static const colTitle = "title";
  static const colDate = "date";
  static const colPriority = "priority";

  get status => null;


  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colTitle: title,
      colPriority: priority,
      colDate: date,

    };
    if (id != null) {
      map[colId] = id;
    }
    return map;
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact.withId(
        id: map[colId],
        title: map[colTitle],
        date: map[colDate],
        priority: map[colPriority],

    );
  }
}

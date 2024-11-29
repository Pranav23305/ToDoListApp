import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';

var database;

class ToDoModelClass {
  int? taskId;
  String title;
  String description;
  String date;
  bool isDone = false;
  ToDoModelClass({
    this.taskId,
    required this.isDone,
    required this.title,
    required this.description,
    required this.date,
  });
  Map<String, Object?> toMap() {
    return {
      'title': title,
      'description': description,
      'date': date,
      "isDone": isDone
    };
  }
}

class ToDoApp extends StatefulWidget {
  ToDoApp({
    super.key,
  });

  @override
  State<ToDoApp> createState() {
    return _ToDoAppState();
  }
}

class _ToDoAppState extends State<ToDoApp> {
  Future<List<ToDoModelClass>> createDatabase() async {
    try {
      database = await openDatabase(
        join(await getDatabasesPath(), 'realNewTodoDB.db'),
        onCreate: (db, version) {
          print("onCreate called");
          db.execute(
            '''CREATE TABLE todos(
              taskId  INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT  NOT NULL,
              description TEXT NOT NULL,
              date TEXT NOT NULL,
              isDone  BOOLEAN )
          ''',
          );
        },
        version: 1,
      );
    } catch (e) {
      print("Error opening database: $e");
    }
    List<ToDoModelClass> initialTodos = await todos();
    return initialTodos;
  }

  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    todoList = await createDatabase();
    setState(() {});
  }

  List todoList = [];

  Future<void> insertToDo(ToDoModelClass todo) async {
    final db = await database;

    await db.insert(
      'todos',
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    todoList = await todos();
    setState(() {});
  }

  Future<List<ToDoModelClass>> todos() async {
    final db = await database;

    final List<Map<String, dynamic>> todoMaps = await db.query('todos');
    // print(todoMaps);

    return List.generate(todoMaps.length, (index) {
      final map = todoMaps[index];
      final taskId = map["taskId"];
      final title = map["title"];
      final description = map["description"];
      final date = map["date"];
      final isDone = map["isDone"] == 0 ? false : true;
      return ToDoModelClass(
          taskId: taskId,
          title: title,
          description: description,
          date: date,
          isDone: isDone);
    });
  }

  Future<void> updateToDo(ToDoModelClass todo) async {
    print("${todo.isDone}");
    final db = await database;

    await db.update(
      'todos',
      todo.toMap(),
      where: 'taskId = ?',
      whereArgs: [todo.taskId],
    );
    todoList = await todos();
    setState(() {});
  }

  Future<void> deleteToDo(ToDoModelClass todo) async {
    print(todo.title);
    final db = await database;

    await db.delete(
      'todos',
      where: 'taskId = ?',
      whereArgs: [todo.taskId],
    );
    todoList = await todos();
    setState(() {});
  }

  ///TEXT EDITING CONTROLLERS
  TextEditingController dateController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  void showBottomSheet(bool doedit, [ToDoModelClass? toDoModelObj]) {
    showModalBottomSheet(
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
        ),
        isDismissible: true,
        context: context,
        builder: (context) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,

                ///TO AVOID THE KEYBOARD OVERLAP THE SCREEN
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Create Task",
                    style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Title",
                        style: GoogleFonts.quicksand(
                          color: const Color.fromRGBO(111, 81, 255, 1),
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          hintText: "Enter Title",
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color.fromRGBO(111, 81, 255, 1),
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.purpleAccent),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Text(
                        "Description",
                        style: GoogleFonts.quicksand(
                          color: const Color.fromRGBO(111, 81, 255, 1),
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      TextField(
                        controller: descriptionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: "Enter Description",
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color.fromRGBO(111, 81, 255, 1),
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.purpleAccent),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Text(
                        "Date",
                        style: GoogleFonts.quicksand(
                          color: const Color.fromRGBO(111, 81, 255, 1),
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      TextField(
                        controller: dateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: "Enter Date",
                          suffixIcon: const Icon(Icons.date_range_rounded),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color.fromRGBO(111, 81, 255, 1),
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.purpleAccent),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onTap: () async {
                          DateTime? pickeddate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2024),
                            lastDate: DateTime(2025),
                          );
                          String formatedDate =
                              DateFormat.yMMMd().format(pickeddate!);
                          setState(() {
                            dateController.text = formatedDate;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 50,
                    width: 300,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(30)),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: const Color.fromRGBO(111, 81, 255, 1),
                      ),
                      onPressed: () {
                        doedit ? submit(doedit, toDoModelObj) : submit(doedit);

                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Submit",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          );
        });
  }

  void submit(bool doedit, [ToDoModelClass? toDoModelObj]) {
    if (titleController.text.trim().isNotEmpty &&
        descriptionController.text.trim().isNotEmpty &&
        dateController.text.trim().isNotEmpty) {
      if (!doedit) {
        setState(() {
          insertToDo(
            ToDoModelClass(
                title: titleController.text.trim(),
                description: descriptionController.text.trim(),
                date: dateController.text.trim(),
                isDone: false),
          );
        });
        setState(() {});
      } else {
        setState(() {
          updateToDo(
            ToDoModelClass(
                taskId: toDoModelObj!.taskId,
                date: dateController.text.trim(),
                title: titleController.text.trim(),
                description: descriptionController.text.trim(),
                isDone: false),
          );
        });
      }
    }
    clearController();
  }

  ///TO CLEAR ALL THE TEXT EDITING CONTROLLERS
  void clearController() {
    titleController.clear();
    descriptionController.clear();
    dateController.clear();
  }

  ///REMOVE NOTES
  void removeTasks(ToDoModelClass toDoModelObj) async {
    await deleteToDo(toDoModelObj);
  }

  void editTask(ToDoModelClass toDoModelObj) {
//ASSIGN THE TEXT EDITING CONTROLLERS WITH THE TEXT VALUES AND
// THEN OPEN THE BOTTOM SHEET
    titleController.text = toDoModelObj.title;
    descriptionController.text = toDoModelObj.description;
    dateController.text = toDoModelObj.date;
    showBottomSheet(true, toDoModelObj);
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    dateController.dispose();
    descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(111, 81, 255, 1),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 100, left: 35),
            child: Text(
              "Good morning",
              style: GoogleFonts.quicksand(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10, left: 35),
            child: Text(
              "Pranav",
              style: GoogleFonts.quicksand(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(top: 20),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(217, 217, 217, 1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    "CREATE TO DO LIST",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(top: 35),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                      ),
                      child: ListView.separated(
                        itemCount: todoList.length,
                        itemBuilder: (context, index) {
                          return Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            // margin: const EdgeInsets.only(top: 10),
                            decoration: const BoxDecoration(
                                color: Color.fromRGBO(255, 255, 255, 1),
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 8,
                                      color: Color.fromRGBO(0, 0, 0, 0.1))
                                ]),
                            child: Container(
                              child: Slidable(
                                closeOnScroll: true,
                                key: const ValueKey(0),
                                endActionPane: ActionPane(
                                  motion: const DrawerMotion(),
                                  extentRatio: 0.25,
                                  dragDismissible: false,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        child: Column(
                                          children: [
                                            const SizedBox(height: 5),
                                            Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                color: Color.fromRGBO(
                                                    111, 81, 255, 1),
                                              ),
                                              child: IconButton(
                                                onPressed: () =>
                                                    editTask(todoList[index]),
                                                icon: const Icon(
                                                  Icons.edit_outlined,
                                                  size: 15,
                                                  shadows: [
                                                    BoxShadow(
                                                        color: Colors.black,
                                                        blurRadius: 15)
                                                  ],
                                                ),
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                color: Color.fromRGBO(
                                                    111, 81, 255, 1),
                                              ),
                                              child: IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    removeTasks(
                                                        todoList[index]);
                                                  });
                                                },
                                                icon: Icon(
                                                  Icons.delete_outline_outlined,
                                                  size: 15,
                                                  shadows: [
                                                    BoxShadow(
                                                        color: Colors.black,
                                                        blurRadius: 15)
                                                  ],
                                                ),
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Color.fromRGBO(0, 0, 0, 0.1),
                                          blurRadius: 6)
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                              color: const Color.fromRGBO(
                                                  217, 217, 217, 1),
                                              borderRadius:
                                                  BorderRadius.circular(50)),
                                          child: const Icon(Icons.image),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                todoList[index].title,
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                todoList[index].description,
                                                style: const TextStyle(
                                                    fontSize: 9,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                todoList[index].date,
                                                style: const TextStyle(
                                                    fontSize: 8,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // const SizedBox(
                                        //   width: 5,
                                        // ),
                                        Container(
                                          height: 30,
                                          width: 30,
                                          decoration: BoxDecoration(
                                            color: todoList[index].isDone
                                                ? Colors.green
                                                : null,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                width: 2,
                                                color: todoList[index].isDone
                                                    ? Colors.green
                                                    : Colors.black),
                                          ),
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 12,
                                              shadows: todoList[index].isDone
                                                  ? []
                                                  : [
                                                      BoxShadow(
                                                          color: Colors.black,
                                                          blurRadius: 25)
                                                    ],
                                            ),
                                            onPressed: () {
                                              todoList[index].isDone =
                                                  !todoList[index].isDone;
                                              updateToDo(todoList[index]);
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return Container(
                            height: 10,
                            color: const Color.fromRGBO(217, 217, 217, 0.04),
                          );
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          clearController();
          showBottomSheet(false);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

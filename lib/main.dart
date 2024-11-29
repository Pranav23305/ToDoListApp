import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:todo_list_application_1/ToDoList.dart';
// void main() {
//   runApp(const MyApp());
// }

var database;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: ToDoApp(),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

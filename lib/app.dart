import 'package:flutter/material.dart';
import 'package:myapp/app/core/widgets/todo_home_page.dart';
import 'app/core/constants/enums/task_filter.dart';
import 'app/core/constants/enums/task_priority.dart';
import './app/core/constants/strings/constant_text.dart';
import './app/core/theme/theme.dart';
class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  StringTextConstant get stringTextConstant => StringTextConstant();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: stringTextConstant.appName,
      debugShowCheckedModeBanner: false,
      theme: TasklyTheme.lightTheme,
      darkTheme: TasklyTheme.darkTheme,
      home: const TodoHomePage(),
    );
  }
}


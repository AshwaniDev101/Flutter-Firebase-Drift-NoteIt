
import 'package:flutter/material.dart';
import 'package:noteit/features/homepage/screens/view/home_page.dart';

void main()
{
  runApp(_MyApp());
}

class _MyApp extends StatelessWidget {
  const _MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,
      title: 'NoteIt',

      home: HomePage()
    );
  }
}



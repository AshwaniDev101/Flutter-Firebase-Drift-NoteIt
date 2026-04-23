
import 'package:flutter/material.dart';
import 'package:noteit/features/home_page/screens/view/home_page.dart';

import 'features/note_page/screens/view/note_page.dart';

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

      home: NotePage()
      // home: HomePage()
    );
  }
}




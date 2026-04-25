import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:noteit/core/routing.dart';

import '../../../../database/app_database.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Note-it'),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.grid_view_rounded)),
          IconButton(onPressed: () async {


          }, icon: Icon(Icons.sync)),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: () async {

        context.go(AppRoutes.edit);
        // await AppDatabase().addNote("Shopping", "Buy milk and bread");
      },child: Icon(Icons.add),),
      body: Column(
        children: [
          SizedBox(height: 4,),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text('Sort by: Name')]),

          SizedBox(height: 4,),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: StreamBuilder<List<Note>>(
                stream: AppDatabase().watchAllNotes(), // Simple and clean!
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const CircularProgressIndicator();
                  final List<Note> data = snapshot.data!;

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: data.length,
                    itemBuilder: (context, index){
                      return _Card(index: index,note:data[index]);
                    },
                  );
                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) => ListTile(title: Text(data[index].title)),
                  );
                },
              ),

            ),
          ),
        ],
      ),
    );
  }
}


class _Card extends StatelessWidget {

  final int index;
  final Note note;
  const _Card({required this.index, required this.note, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(

      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Expanded(child: Container(height: 1,color: Colors.red,)),
          Container(

              decoration: BoxDecoration(
                color: Colors.amber.shade600,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Title $index: ${note.title}"),
              )),
          Expanded(child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Message: ${note.content}"),
          ))
        ],
      ),
    );
  }
}

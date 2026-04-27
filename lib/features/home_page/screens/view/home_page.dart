import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:noteit/core/routing/routing.dart';

import '../../../../database/app_database.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool isSelectMode = false;
  final Set<int> noteIds = {};

  @override
  Widget build(BuildContext context) {
    final localDb = ref.watch(localDbProvider);

    return Scaffold(
      appBar: isSelectMode? AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(onPressed: () {
          setState(() {
            isSelectMode = false;
            noteIds.clear();
          });
        }, icon: Icon(Icons.arrow_back, color:Colors.white)),
        title: Text('${noteIds.length} Selected', style: TextStyle(color: Colors.white),),
        actions: [
          IconButton(onPressed: () async {
            for (final id in noteIds) {
              await localDb.deleteNote(id);
            }
            setState(() {
              isSelectMode = false;
              noteIds.clear();
            });
          }, icon: Icon(Icons.delete, color:Colors.white)),

        ],
      ): AppBar(
        title: Text('Note-it'),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.grid_view_rounded)),
          IconButton(onPressed: () async {

          }, icon: Icon(Icons.sync)),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: () async {

        context.push(AppRoutes.edit);

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
                stream: localDb.watchAllNotes(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Center(child: const CircularProgressIndicator());
                  final List<Note> data = snapshot.data!;
                  if (data.isEmpty) {
                    return const Center(child: Text('No notes yet. Tap + to add one!'));
                  }

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: data.length,
                    itemBuilder: (context, index){
                      return _SelectableCard(
                          onTap: (){
                            if (isSelectMode) {
                              setState(() {
                                if (noteIds.contains(data[index].id)) {
                                  noteIds.remove(data[index].id);
                                  if (noteIds.isEmpty) isSelectMode = false;
                                } else {
                                  noteIds.add(data[index].id);
                                }
                              });
                            } else {
                              context.push(AppRoutes.edit, extra: data[index]);
                            }
                          },
                          onLongPress: (){
                            setState(() {
                              isSelectMode = true;
                              noteIds.add(data[index].id);
                            });
                          },

                          isSelected: noteIds.contains(data[index].id),
                          child: _Card(
                            index: index,
                            note: data[index],
                          ));
                    },
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


class _SelectableCard extends StatelessWidget {

  final Widget child;
  final bool isSelected;
  final void Function() onTap;
  final void Function() onLongPress;

  const _SelectableCard({required this.child, required this.isSelected, required this.onTap, required this.onLongPress, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        children: [
          child,
          if (isSelected)
            const Positioned(
              top: 8,
              right: 8,
              child: Icon(Icons.check_circle, color: Colors.green),
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
      constraints: const BoxConstraints.expand(),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              decoration: BoxDecoration(
                color: Colors.amber.shade200,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Text(note.title, style: TextStyle(fontWeight: FontWeight.bold)),
              )),
          Expanded(
            child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              note.content,
              // overflow: TextOverflow.fade,
            ),
          ))
        ],
      ),
    );
  }
}

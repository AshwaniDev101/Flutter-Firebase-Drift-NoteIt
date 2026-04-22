import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Note-it'),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.grid_view_rounded)),
          IconButton(onPressed: () {}, icon: Icon(Icons.sync)),
        ],
      ),
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
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: 20,
                itemBuilder: (context, index){
                  return _Card(index: index,);
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
  const _Card({required this.index, super.key});

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
                child: Text("Title $index"),
              )),
          Expanded(child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Message"),
          ))
        ],
      ),
    );
  }
}

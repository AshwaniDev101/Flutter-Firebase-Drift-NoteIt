import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noteit/features/edit_note_page/screens/view_model/edit_note_view_model.dart';


class EditNotePage extends ConsumerStatefulWidget {
  const EditNotePage({super.key});

  @override
  ConsumerState<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends ConsumerState<EditNotePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();


  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    final viewModelState = ref.watch(editNoteViewModelProvider);
    final viewModel= ref.read(editNoteViewModelProvider.notifier);



    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            children: [
              const SizedBox(height: 6),

              /// Top Bar
              Row(
                children: [
                  IconButton(
                    onPressed: () async {


                      // editing, check icon
                      if (context.mounted && viewModelState.isEditing)
                        {

                          viewModel.setEditing(false);
                          await viewModel.saveNote(titleController.text, contentController.text);


                        }else //
                          {

                            Navigator.of(context).pop();
                          }

                    },
                    icon: Icon(viewModelState.isEditing?Icons.check:Icons.arrow_back),
                  ),

                  const SizedBox(width: 4),

                  Expanded(
                    child: TextField(
                      readOnly: !viewModelState.isEditing,
                      onTap: () {
                        if (!viewModelState.isEditing) {
                          viewModel.setEditing(true);
                        }
                      },
                      controller: titleController,
                      decoration: const InputDecoration(hintText: "Title", border: InputBorder.none),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),

                  IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert_rounded)),
                ],
              ),

              /// Status Row
              Row(
                children: [
                  Text(viewModelState.isEditing ? "Editing" : "Saved", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  const Spacer(),
                  Text("4/23/26 8:48 AM", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),

              const SizedBox(height: 8),

              /// Note Content
              Expanded(
                child: TextField(
                  readOnly: !viewModelState.isEditing,
                  onTap: () {
                    if (!viewModelState.isEditing) {
                      viewModel.setEditing(true);
                    }
                  },
                  controller: contentController,
                  maxLines: null,
                  expands: true,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(hintText: "Start writing your note...", border: InputBorder.none),
                  style: const TextStyle(fontSize: 15),
                ),
              ),

              /// Bottom Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.undo)),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.redo)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

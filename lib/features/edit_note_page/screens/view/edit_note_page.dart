import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noteit/features/edit_note_page/screens/view_model/edit_note_view_model.dart';

import '../../../../database/app_database.dart';

class EditNotePage extends ConsumerStatefulWidget {
  const EditNotePage({super.key});

  @override
  ConsumerState<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends ConsumerState<EditNotePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  bool isSaved = false;

  @override
  Widget build(BuildContext context) {
    final localDb = ref.watch(localDbProvider);

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

                      await viewModel.saveNote(titleController.text, contentController.text);

                      if(viewModelState.isSaved && context.mounted)
                        {
                          Navigator.of(context).pop();
                        }

                    },
                    icon: Icon(viewModelState.isSaved?Icons.arrow_back : Icons.check),
                  ),

                  const SizedBox(width: 4),

                  Expanded(
                    child: TextField(
                      enabled: !viewModelState.isSaved,
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
                  Text("Editing", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  const Spacer(),
                  Text("4/23/26 8:48 AM", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),

              const SizedBox(height: 8),

              /// Note Content
              Expanded(
                child: TextField(
                  enabled: !viewModelState.isSaved,
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noteit/core/theme/note_theme.dart';
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
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final noteTheme = Theme.of(context).extension<NoteTheme>()!;
    final viewModelState = ref.watch(editNoteViewModelProvider);
    final viewModel = ref.read(editNoteViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: noteTheme.cardBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            children: [
              const SizedBox(height: 6),

              Row(
                children: [
                  IconButton(
                    color: noteTheme.titleText,
                    onPressed: () async {
                      if (context.mounted && viewModelState.isEditing) {
                        viewModel.setEditing(false);
                        await viewModel.saveNote(
                          titleController.text,
                          contentController.text,
                        );
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    icon: Icon(
                      viewModelState.isEditing
                          ? Icons.check
                          : Icons.arrow_back,
                    ),
                  ),

                  const SizedBox(width: 4),

                  Expanded(
                    child: TextField(
                      readOnly: !viewModelState.isEditing,
                      controller: titleController,
                      onTap: () {
                        if (!viewModelState.isEditing) {
                          viewModel.setEditing(true);
                        }
                      },
                      decoration: const InputDecoration(
                        hintText: "Title",
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: noteTheme.titleText,
                      ),
                    ),
                  ),

                  IconButton(
                    color: noteTheme.titleText,
                    onPressed: () {},
                    icon: const Icon(Icons.more_vert_rounded),
                  ),
                ],
              ),

              Row(
                children: [
                  Text(
                    viewModelState.isEditing ? "Editing" : "Saved",
                    style: TextStyle(
                      color: noteTheme.contentText,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "4/23/26 8:48 AM",
                    style: TextStyle(
                      color: noteTheme.contentText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Expanded(
                child: TextField(
                  readOnly: !viewModelState.isEditing,
                  controller: contentController,
                  maxLines: null,
                  expands: true,
                  keyboardType: TextInputType.multiline,
                  onTap: () {
                    if (!viewModelState.isEditing) {
                      viewModel.setEditing(true);
                    }
                  },
                  decoration: const InputDecoration(
                    hintText: "Start writing your note...",
                    border: InputBorder.none,
                  ),
                  style: TextStyle(
                    fontSize: 15,
                    color: noteTheme.contentText,
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    color: noteTheme.actionButton,
                    onPressed: () {},
                    icon: const Icon(Icons.undo),
                  ),
                  IconButton(
                    color: noteTheme.actionButton,
                    onPressed: () {},
                    icon: const Icon(Icons.redo),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
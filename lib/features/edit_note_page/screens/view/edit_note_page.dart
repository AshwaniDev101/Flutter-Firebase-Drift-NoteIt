import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/managers/lock_manger/lock_manager.dart';
import '../../../../shared/widgets/snack_bar_manager.dart';
import '../../../password_page/screens/view/setup_password_page.dart';
import '../view_model/edit_note_view_model.dart';
import 'package:noteit/database/drift/drift_database.dart';

class EditNotePage extends ConsumerStatefulWidget {
  final Note? existingNote;

  const EditNotePage({super.key, this.existingNote});

  @override
  ConsumerState<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends ConsumerState<EditNotePage> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final FocusNode _titleFocusNode;
  final UndoHistoryController _undoController = UndoHistoryController();

  bool _isAutoSyncingTitle = false;
  late bool _isLocked;

  bool _hasTriggeredFinalSave = false; // Prevents double-saving between back button and dispose
  bool _hasCreatedNewNote = false;     // Prevents duplicating a new note if save is clicked multiple times

  // Determines if this is a genuinely new note or a dummy note passed from the Desktop FAB
  bool get _isNewNote {
    if (widget.existingNote == null) return true;
    return widget.existingNote!.title.isEmpty &&
        widget.existingNote!.content.isEmpty &&
        widget.existingNote!.versionCounter == 1 &&
        widget.existingNote!.syncStatus == 0;
  }

  @override
  void initState() {
    super.initState();
    _isLocked = widget.existingNote?.isLocked ?? false;
    _titleController = TextEditingController(text: widget.existingNote?.title ?? '');
    _contentController = TextEditingController(text: widget.existingNote?.content ?? '');
    _titleFocusNode = FocusNode();

    _titleFocusNode.addListener(() {
      setState(() {});
    });

    if (_titleController.text.isEmpty) {
      _isAutoSyncingTitle = true;
    }

    _contentController.addListener(_syncTitleFromContent);
    _titleController.addListener(_onTitleChanged);
  }

  void _syncTitleFromContent() {
    if (_isAutoSyncingTitle) {
      final contentText = _contentController.text;
      final firstLine = contentText.isNotEmpty ? contentText.split('\n').first : '';

      if (_titleController.text != firstLine) {
        _titleController.value = _titleController.value.copyWith(
          text: firstLine,
          selection: TextSelection.collapsed(offset: firstLine.length),
        );
      }
    }
  }

  void _onTitleChanged() {
    if (_titleController.text.isEmpty) {
      _isAutoSyncingTitle = true;
    } else {
      final firstLine = _contentController.text.split('\n').first;
      if (_titleController.text != firstLine) {
        _isAutoSyncingTitle = false;
      }
    }
  }

  @override
  void dispose() {
    // Fire a final save right before the widget is destroyed (auto-save on close)
    _executeSave(isManualSave: false);

    // Clean up resources
    _contentController.removeListener(_syncTitleFromContent);
    _titleController.removeListener(_onTitleChanged);
    _titleFocusNode.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _undoController.dispose();
    super.dispose();
  }

  String _getFormattedDate() {
    final now = widget.existingNote?.updatedAt ?? widget.existingNote?.createdAt ?? DateTime.now();
    if (_isNewNote) return "${now.month}/${now.day}/${now.year}";
    return "${now.month}/${now.day}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}";
  }

  // A synchronous save trigger that fires API requests into the background
  void _executeSave({bool isManualSave = false}) {
    if (_hasTriggeredFinalSave && !isManualSave) return;

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    // Do nothing if the note is completely blank
    if (title.isEmpty && content.isEmpty) return;

    final viewModel = ref.read(editNoteViewModelProvider.notifier);

    if (_isNewNote) {
      // If we already created it, warn the user instead of spawning duplicates
      if (_hasCreatedNewNote) {
        if (isManualSave && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Note created! Select it from the list to update.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      viewModel.saveNote(title, content);
      _hasCreatedNewNote = true; // Mark as created so we don't duplicate on next save

      if (isManualSave && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note Saved!'), behavior: SnackBarBehavior.floating),
        );
      }
    } else {
      // Don't waste DB calls if nothing changed
      if (title != widget.existingNote!.title || content != widget.existingNote!.content) {
        viewModel.updateNote(widget.existingNote!.id, title, content);
      }
      if (isManualSave && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note Updated!'), behavior: SnackBarBehavior.floating),
        );
      }
    }

    if (!isManualSave) {
      _hasTriggeredFinalSave = true;
    }
  }

  // Used strictly for mobile hardware back button or AppBar back button
  void _handleMobileBack() {
    FocusManager.instance.primaryFocus?.unfocus();
    _executeSave(isManualSave: false);
    if (context.mounted) {
      context.pop();
    }
  }

  Widget _buildOptionMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (String value) async {
        if (value == 'toggle_lock') {
          bool isCurrentlyLocked = _isLocked;
          final lockManager = ref.read(lockManagerProvider.notifier);
          bool shouldProceed = false;

          if (!lockManager.hasMasterPassword) {
            final enteredPassword = await showGeneralDialog<String>(
              context: context,
              barrierDismissible: true,
              barrierLabel: 'Dismiss',
              barrierColor: Colors.black45,
              pageBuilder: (context, anim1, anim2) => const SetupPasswordPage(),
            );

            if (enteredPassword != null && enteredPassword.isNotEmpty) {
              await lockManager.setupMasterPassword(enteredPassword);
              if (context.mounted) SnackBarManager.show(msg: 'Master Password Created!');
              shouldProceed = true;
            }
          } else {
            shouldProceed = true;
          }

          if (shouldProceed) {
            final success = await lockManager.togglePersistentLock(
              widget.existingNote!.id,
              '',
              shouldLock: !isCurrentlyLocked,
              ignorePassword: true,
            );

            if (success) {
              if (context.mounted) {
                setState(() { _isLocked = !_isLocked; });
                if (!isCurrentlyLocked) context.pop();
              }
            } else {
              if (context.mounted) SnackBarManager.show(msg: 'Action failed');
            }
          }
        } else if (value == 'discard') {
          _hasTriggeredFinalSave = true; // Mark as saved so dispose() ignores it
          if (context.mounted) context.pop();
        } else if (value == 'delete') {
          if (!_isNewNote && widget.existingNote != null) {
            _hasTriggeredFinalSave = true; // Mark as saved to prevent recreate
            ref.read(editNoteViewModelProvider.notifier).deleteNote(widget.existingNote!.id);
            if (context.mounted) context.pop();
          }
        }
      },
      itemBuilder: (BuildContext context) {
        final colorScheme = Theme.of(context).colorScheme;
        return [
          PopupMenuItem<String>(
            value: 'toggle_lock',
            child: Row(
              children: [
                Icon(_isLocked ? Icons.lock_clock_outlined : Icons.lock_outline, size: 20),
                const SizedBox(width: 12),
                Text(_isLocked ? 'Remove Lock' : 'Lock Note'),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'discard',
            child: Row(
              children: [
                Icon(Icons.close, size: 20, color: colorScheme.onSurface),
                const SizedBox(width: 12),
                Text('Discard Changes', style: TextStyle(color: colorScheme.onSurface)),
              ],
            ),
          ),
          const PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                SizedBox(width: 12),
                Text('Delete Note', style: TextStyle(color: Colors.redAccent)),
              ],
            ),
          ),
        ];
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (isAndroid) _handleMobileBack();
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: isAndroid
              ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _handleMobileBack)
              : null,
          titleSpacing: isAndroid ? 0 : 24,
          title: Container(
            height: 40,
            constraints: const BoxConstraints(maxWidth: 600), // Better scaling for desktop
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5), width: 1.2),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
            child: TextField(
              controller: _titleController,
              focusNode: _titleFocusNode,
              textAlignVertical: TextAlignVertical.center,
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: "Title",
                hintStyle: textTheme.titleMedium?.copyWith(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                suffixIcon: _titleFocusNode.hasFocus
                    ? ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _titleController,
                  builder: (context, value, child) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    return IconButton(
                      icon: const Icon(Icons.close, size: 18, color: Colors.black54),
                      onPressed: () {
                        _titleController.clear();
                        _isAutoSyncingTitle = true;
                      },
                    );
                  },
                )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
          actions: [
            // Explicit Manual Save Button
            IconButton(
              icon: const Icon(Icons.save_outlined),
              tooltip: 'Save Note',
              onPressed: () => _executeSave(isManualSave: true),
            ),
            // Moved Undo/Redo to the Desktop Toolbar
            if (!isAndroid) ...[
              ValueListenableBuilder<UndoHistoryValue>(
                valueListenable: _undoController,
                builder: (context, value, child) {
                  return IconButton(
                    onPressed: value.canUndo ? () => _undoController.undo() : null,
                    icon: const Icon(Icons.undo, size: 20),
                    tooltip: 'Undo',
                  );
                },
              ),
              ValueListenableBuilder<UndoHistoryValue>(
                valueListenable: _undoController,
                builder: (context, value, child) {
                  return IconButton(
                    onPressed: value.canRedo ? () => _undoController.redo() : null,
                    icon: const Icon(Icons.redo, size: 20),
                    tooltip: 'Redo',
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
            if (!_isNewNote) _buildOptionMenu(),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isAndroid ? 18.0 : 24.0, vertical: 8.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _isNewNote ? colorScheme.primaryContainer : colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _isNewNote ? 'New' : 'Updating...',
                        style: textTheme.labelSmall?.copyWith(
                          color: _isNewNote ? colorScheme.onPrimaryContainer : colorScheme.onTertiaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (_isLocked) ...[
                      Icon(Icons.lock_outline, size: 16, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      _getFormattedDate(),
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Expanded(
                // Using Align TopCenter fixes the weird vertical text centering caused by expands:true
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isAndroid ? 20.0 : 24.0, vertical: 16.0),
                  child: TextField(
                    controller: _contentController,
                    undoController: _undoController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top, // Crucial fix for desktop input fields
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(border: InputBorder.none),
                    style: textTheme.bodyLarge?.copyWith(
                      fontSize: 18,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              // Editor tool palette for Mobile Only
              if (isAndroid)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ValueListenableBuilder<UndoHistoryValue>(
                        valueListenable: _undoController,
                        builder: (context, value, child) {
                          return IconButton(
                            onPressed: value.canUndo ? () => _undoController.undo() : null,
                            icon: const Icon(Icons.undo),
                            tooltip: 'Undo',
                          );
                        },
                      ),
                      const SizedBox(width: 24),
                      ValueListenableBuilder<UndoHistoryValue>(
                        valueListenable: _undoController,
                        builder: (context, value, child) {
                          return IconButton(
                            onPressed: value.canRedo ? () => _undoController.redo() : null,
                            icon: const Icon(Icons.redo),
                            tooltip: 'Redo',
                          );
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
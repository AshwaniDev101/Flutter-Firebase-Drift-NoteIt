import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:noteit/core/routing/routing.dart';
import 'package:noteit/database/drift/drift_database.dart';
import 'package:noteit/features/home_page/screens/view/widgets/home_app_bars.dart';
import 'package:noteit/features/home_page/screens/view/widgets/notes_grid_view.dart';
import 'package:noteit/features/home_page/screens/view/widgets/sort_options_bar.dart';
import 'package:noteit/features/password_page/screens/view/password_page.dart';
import 'package:noteit/features/edit_note_page/screens/view/edit_note_page.dart';
import '../../../../shared/managers/lock_manger/lock_manager.dart';
import '../../../../database/sync_manager.dart';
import '../../../drawer_page/homepage_drawer.dart';
import '../core/providers.dart';
import '../viewmodel/home_view_model.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  // Tracks the currently selected note for the desktop/web split view
  Note? _activeNote;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(syncNotifierProvider.notifier).executeFullSync();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _exitSearchMode() {
    _searchController.clear();
    ref.read(searchQueryProvider.notifier).clear();
    ref.read(homeViewModelProvider.notifier).exitSearchMode();
  }

  @override
  Widget build(BuildContext context) {
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;

    // ViewModel State & Notifier
    final homeState = ref.watch(homeViewModelProvider);
    final viewModel = ref.read(homeViewModelProvider.notifier);

    // Forces Riverpod to keep SyncManager awake
    ref.watch(syncNotifierProvider);

    return PopScope(
      canPop: !homeState.isSelectMode && !homeState.isSearchMode,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        if (homeState.isSelectMode) {
          viewModel.clearSelection();
        } else if (homeState.isSearchMode) {
          _exitSearchMode();
        }
      },
      child: Scaffold(
        drawer: const HomepageDrawer(),
        appBar: _buildResponsiveAppBar(isAndroid, homeState, viewModel),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (!isAndroid) {
              final emptyNote = Note(
                id: DateTime.now().millisecondsSinceEpoch,
                title: '',
                content: '',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                isLocked: false,
                isPinned: false,
                color: 0,
                isArchived: false,
                position: 0,
                hasAttachments: false,
                contentType: 'text',
                isShared: false,
                syncStatus: 0,
                versionCounter: 1,
              );
              // Open new note directly in the right panel
              setState(() {
                _activeNote = emptyNote;
              });
            } else {
              context.push(AppRoutes.edit);
            }
          },
          child: const Icon(Icons.add),
        ),
        body: !isAndroid
            ? _buildSplitView(homeState, viewModel, isAndroid)
            : _buildStandardGridView(homeState, viewModel, isAndroid),
      ),
    );
  }

  Widget _buildSplitView(HomePageState homeState, HomeViewModel viewModel, bool isAndroid) {
    return Row(
      children: [
        SizedBox(
          width: 300,
          child: _buildStandardGridView(homeState, viewModel, isAndroid),
        ),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(
          child: _buildRightPanel(),
        ),
      ],
    );
  }

  Widget _buildRightPanel() {
    if (_activeNote == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit_note, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('No note selected', style: TextStyle(color: Colors.grey.shade600, fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              'Select a note from the sidebar or click + to start editing.',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    // ValueKey ensures that Flutter destroys and rebuilds the EditNotePage
    // entirely when the note ID changes, keeping states clean between selections.
    return EditNotePage(
      key: ValueKey(_activeNote!.id),
      existingNote: _activeNote,
    );
  }

  void _handleNoteTap(Note note) {
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;

    if (!isAndroid) {
      // Replace the active note on the right-side panel
      setState(() {
        _activeNote = note;
      });
    } else {
      // Push to new screen on mobile
      context.push(AppRoutes.edit, extra: note);
    }
  }

  Widget _buildStandardGridView(HomePageState homeState, HomeViewModel viewModel, bool isAndroid) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!homeState.isSearchMode && !isAndroid) const SortOptionsBar(),
          Expanded(
            child: NotesGridView(
              isSelectMode: homeState.isSelectMode,
              noteIds: homeState.selectedNoteIds,
              // Pass the currently active note down to the grid for highlighting
              activeNoteId: _activeNote?.id,
              onToggleSelection: viewModel.toggleSelection,
              onEnableSelectMode: viewModel.enableSelectMode,
              onPromptPassword: _promptForPassword,
              onNoteTap: _handleNoteTap,
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildResponsiveAppBar(bool isAndroid, HomePageState state, HomeViewModel viewModel) {
    if (state.isSelectMode) {
      return SelectModeAppBar(
        noteIds: state.selectedNoteIds,
        onClearSelection: viewModel.clearSelection,
        onSelectAll: () {
          final currentNotes = ref.read(filteredNotesProvider).value ?? [];
          final allNoteIds = currentNotes.map((note) => note.id).toList();
          viewModel.toggleSelectAll(allNoteIds);
        },
      );
    }

    if (state.isSearchMode) {
      return SearchModeAppBar(searchController: _searchController, onExitSearchMode: _exitSearchMode);
    }

    return DefaultHomeAppBar(
      isAndroid: isAndroid,
      searchController: _searchController,
      onEnterSearchMode: viewModel.enterSearchMode,
    );
  }

  Future<void> _promptForPassword(BuildContext context, Note note) async {
    final String? enteredPassword = await showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss Password Dialog',
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) => const PasswordPage(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );

    if (enteredPassword != null && enteredPassword.isNotEmpty && context.mounted) {
      final lockManager = ref.read(lockManagerProvider.notifier);

      if (!lockManager.hasMasterPassword) {
        await lockManager.setupMasterPassword(enteredPassword);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('New Master Password Set!')));
      }

      final success = lockManager.verifyAndSessionUnlock(note.id, enteredPassword);
      final isAndroid = defaultTargetPlatform == TargetPlatform.android;

      if (success) {
        if (!isAndroid) {
          setState(() {
            _activeNote = note;
          });
        } else {
          context.push(AppRoutes.edit, extra: note);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incorrect Password')));
      }
    }
  }
}
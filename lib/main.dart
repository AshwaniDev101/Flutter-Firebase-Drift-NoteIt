
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noteit/core/routing.dart';

void main()
{
  runApp(ProviderScope(child: _MyApp(),));
}

class _MyApp extends ConsumerWidget {
  const _MyApp({super.key});

  @override
  Widget build(BuildContext context, ref) {
    
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      title: 'NoteIt',
    );
  }
}




import 'package:flutter/material.dart';

import '../../../../database/app_database.dart';

class NotePage extends StatelessWidget {
  const NotePage({super.key});

  @override
  Widget build(BuildContext context) {
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
                    onPressed: () {},
                    icon: const Icon(Icons.check),
                  ),

                  const SizedBox(width: 4),

                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: "Title",
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_vert_rounded),
                  ),
                ],
              ),

              /// Status Row
              Row(
                children: [
                  Text(
                    "Editing",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "4/23/26 8:48 AM",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              /// Note Content
              Expanded(
                child: TextField(
                  maxLines: null,
                  expands: true,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: "Start writing your note...",
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),

              /// Bottom Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.undo),
                  ),
                  IconButton(
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
import 'package:flutter/material.dart';

@immutable
class NoteTheme extends ThemeExtension<NoteTheme> {
  final Color appBar;
  final Color selectedAppBar;

  final Color cardBackground;
  final Color cardTitle;
  final Color cardContent;

  final Color titleText;
  final Color contentText;

  final Color actionButton;

  const NoteTheme({
    required this.appBar,
    required this.selectedAppBar,
    required this.cardBackground,
    required this.cardTitle,
    required this.cardContent,
    required this.titleText,
    required this.contentText,
    required this.actionButton,
  });

  @override
  NoteTheme copyWith({
    Color? appBar,
    Color? selectedAppBar,
    Color? cardBackground,
    Color? cardTitle,
    Color? cardContent,
    Color? titleText,
    Color? contentText,
    Color? actionButton,
  }) {
    return NoteTheme(
      appBar: appBar ?? this.appBar,
      selectedAppBar: selectedAppBar ?? this.selectedAppBar,
      cardBackground: cardBackground ?? this.cardBackground,
      cardTitle: cardTitle ?? this.cardTitle,
      cardContent: cardContent ?? this.cardContent,
      titleText: titleText ?? this.titleText,
      contentText: contentText ?? this.contentText,
      actionButton: actionButton ?? this.actionButton,
    );
  }

  @override
  NoteTheme lerp(ThemeExtension<NoteTheme>? other, double t) {
    if (other is! NoteTheme) return this;

    return NoteTheme(
      appBar: Color.lerp(appBar, other.appBar, t)!,
      selectedAppBar: Color.lerp(selectedAppBar, other.selectedAppBar, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      cardTitle: Color.lerp(cardTitle, other.cardTitle, t)!,
      cardContent: Color.lerp(cardContent, other.cardContent, t)!,
      titleText: Color.lerp(titleText, other.titleText, t)!,
      contentText: Color.lerp(contentText, other.contentText, t)!,
      actionButton: Color.lerp(actionButton, other.actionButton, t)!,
    );
  }
}
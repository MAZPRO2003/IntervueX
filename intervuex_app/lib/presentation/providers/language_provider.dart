import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ExplanationLanguage { english, tamil, hindi }

class LanguageNotifier extends StateNotifier<ExplanationLanguage> {
  LanguageNotifier() : super(ExplanationLanguage.english);

  void setLanguage(ExplanationLanguage lang) {
    state = lang;
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, ExplanationLanguage>((ref) {
  return LanguageNotifier();
});

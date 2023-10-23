import 'package:flutter/widgets.dart';

/// An abstraction of the language resolver that should have a local implementation
///
abstract class LanguageResolver {
  const LanguageResolver();

  /// Resolve the `Locale`
  Locale? Function(Locale?, Iterable<Locale>) resolution({Locale? fallback});

  /// A callback when the user has selected a Locale
  void onLocaleChanged(Locale? locale);

  /// Gets a list of supported locales
  List<Locale> get supportedLocales;

  /// Translate the supplied key
  String translate(String key);
}

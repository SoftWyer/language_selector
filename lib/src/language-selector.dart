import 'dart:io';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:language_selector/src/language_resolver.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The key used to store the selected locale in Shared Preferences
const String sharedPreferenceLocaleKey = 'locale';

/// The `LanguageSelector` view. This should be used in another view or dialog, e.g.
/// ```
/// await showDialog(
///       context: context,
///       builder: (context) => const Dialog(
///       child: LanguageSelector(
///         resolver: MyLanguageResolver(),
///       ),
///     ),
/// );
///```
///
/// `SharedPreferences` is used to persist and retrieve the `Locale`
///
/// Currently supports:
/// * English (UK)
/// * English (USA)
/// * French
/// * German
/// * Spanish
/// * Italian
///
/// TODO:
/// * Make language selection configurable (based on supported locales??)
/// * Add more languages and flags
/// * More layout configuration
class LanguageSelector extends StatefulWidget {
  final LanguageResolver resolver;

  const LanguageSelector({required this.resolver, super.key});

  @override
  State<StatefulWidget> createState() => _LanguageSelectedState();
}

class _LanguageSelectedState extends State<LanguageSelector> {
  Locale? _selected;
  final Map<String, String> _iconAssets = {
    'en-GB': 'assets/flags/gb.svg',
    'en-US': 'assets/flags/us.svg',
    'fr-FR': 'assets/flags/fr.svg',
    'de-DE': 'assets/flags/de.svg',
    'es-ES': 'assets/flags/es.svg',
    'it-IT': 'assets/flags/it.svg',
  };

  Widget _renderLanguages(
    BuildContext context,
    _SupportedLocales supportedLocales,
  ) {
    _selected = supportedLocales.selected;
    return ListView.builder(
      shrinkWrap: true,
      itemCount: supportedLocales.supported.length,
      itemBuilder: (context, index) {
        final Locale l = supportedLocales.supported[index];
        return InkWell(
          onTap: () => _localChanged(l.toLanguageTag(), supportedLocales),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Radio(
                groupValue: _selected!.toLanguageTag(),
                value: l.toLanguageTag(),
                onChanged: (String? s) {
                  if (s != null) {
                    _localChanged(s, supportedLocales);
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: SvgPicture.asset(
                  _iconAssets[l.toLanguageTag()]!,
                  width: 70,
                  // height: 40,
                  package: 'language_selector',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _localChanged(
    String s,
    _SupportedLocales supportedLocales,
  ) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString(sharedPreferenceLocaleKey, s);

    setState(() {
      _selected = supportedLocales.supported
          .firstWhereOrNull((e) => e.toLanguageTag() == s);
      widget.resolver.onLocaleChanged(_selected);
    });
  }

  String get _platformLocale => kIsWeb ? 'en' : Platform.localeName;

  Future<_SupportedLocales> _getLanguagePreference(BuildContext context) async {
    // Get the language from Shared Preferences
    final sp = await SharedPreferences.getInstance();
    String localeString = _platformLocale;
    try {
      localeString = sp.getString(sharedPreferenceLocaleKey) ?? _platformLocale;
    } catch (e) {
      debugPrint('ERROR: Locale lookup from shared preferences: $e');
    }

    final localeParts = localeString.split('-');

    final selected = widget.resolver.resolution()(
      Locale(localeParts.first, localeParts.last),
      widget.resolver.supportedLocales,
    );
    return _SupportedLocales(selected, widget.resolver.supportedLocales);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getLanguagePreference(context),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return Center(child: Text(widget.resolver.translate('Loading...')));
        }
        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  widget.resolver.translate('Select a language'),
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ),
              Flexible(
                child: Container(
                  child: _renderLanguages(context, snapshot.data!),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(widget.resolver.translate('OK')),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class _SupportedLocales {
  final Locale? selected;
  final List<Locale> supported;
  const _SupportedLocales(this.selected, this.supported);
}

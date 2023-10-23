# Language Selector
An opinionated Language Selector that is primarily for SoftWyer internal use.

## Features

Shows country flags in a column with selected callbacks.

Maintains the last selection in `SharedPreferences`

## Getting started

Import the package

## Usage

Implement a `LanguageResolver` and pass it into the `LanguageSelector`

```dart
await showDialog(
      context: context,
      builder: (context) => const Dialog(
      child: LanguageSelector(
        resolver: MyLanguageResolver(),
      ),
    ),
);
```

## Additional information

Read the source...

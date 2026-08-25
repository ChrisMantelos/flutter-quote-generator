# Flutter Quote Generator

![Flutter](https://img.shields.io/badge/Flutter-Dart-02569B)
![Material 3](https://img.shields.io/badge/design-Material%203-6750A4)

A single-screen Flutter app that shows a random quote each time you press
a button. Built as a clean exercise in Flutter's state management using
`StatefulWidget`.

## Why I built this

I wanted a minimal project to practice how Flutter rebuilds the UI in
response to state changes, without any extra complexity from networking,
storage, or navigation getting in the way.

## Setup and run

Requires the Flutter SDK installed.

```bash
flutter pub get
flutter run
```

To run in a browser without an emulator:

```bash
flutter run -d chrome
```

## How it's structured

All logic lives in `lib/main.dart`:

- `QuoteApp` - the root `StatelessWidget`. Sets up the Material 3 theme and points to the home screen.
- `QuoteScreen` - the main `StatefulWidget`. Calls `setState()` inside `_showRandomQuote()` to trigger a UI redraw whenever a new quote is picked from the list.

## Possible extensions

- Pull quotes from a public API instead of a static list
- Add a fade or slide animation when the quote changes
- Add a "favorite" button that saves quotes locally
- Add a dark mode toggle

## Tech stack

Flutter, Dart, Material 3

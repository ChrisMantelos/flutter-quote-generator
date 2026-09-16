# Flutter Quote Generator

![Flutter](https://img.shields.io/badge/Flutter-Dart-02569B)
![Material 3](https://img.shields.io/badge/design-Material%203-6750A4)

A quote generator that fetches real quotes from a public API, with
category filtering, favorites you can save and revisit, and a graceful
offline fallback when the network is unavailable.

## Why I rebuilt this

The original version was a single screen with a static, hardcoded list
of quotes - fine as a first Flutter exercise, but it didn't touch
networking, error handling, or persistence. This version does all three,
while keeping the same core idea.

## Features

- **Live quotes** from the [Quotable API](https://api.quotable.io), filterable by category (wisdom, inspirational, life, success, happiness)
- **Offline fallback**: if the network request fails, the app falls back to a small built-in quote collection instead of crashing or showing a blank screen - and says so clearly, rather than pretending the fallback quote came from the API
- **Favorites**: save quotes with a tap, view them on a separate screen, remove them individually - persisted with `shared_preferences` so they survive closing the app
- **Copy to clipboard** for sharing a quote elsewhere
- **Smooth fade transition** when a new quote loads, instead of an instant swap

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

```
lib/
    main.dart              home screen: tag filter, quote card, actions
    quote_model.dart        Quote data class
    quote_service.dart      API call to Quotable, with local fallback data
    favorites_storage.dart  persistence layer using shared_preferences
    favorites_screen.dart   list of saved favorites
    theme.dart              colors and typography used throughout
```

`QuoteService.fetchRandomQuote()` tries the live API first; if it fails
for any reason (no connection, timeout, non-200 response), it falls back
to a small bundled list of quotes filtered by the same tag, so the app
always shows something instead of an error screen.

## Testing status

`flutter analyze` reports no issues. The structure of every file was
also checked independently (balanced brackets, no truncated strings).
The live API call and the favorites persistence have not been run
against the real Flutter SDK in this environment - run `flutter run`
yourself as the real test, and check that tapping the heart icon on a
quote still shows it in Favorites after fully closing and reopening the
app (that's the actual proof persistence works, not just that the icon
changes color).

## Possible extensions

- Search favorites by author or keyword
- Share button (share_plus) to send a quote to another app
- Daily quote notification
- Dark mode toggle

## Tech stack

Flutter, Dart, Quotable API, shared_preferences

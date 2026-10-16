# FlorglassAluminum

A Flutter and Dart mobile application concept for a glass and aluminum works business. It uses the supplied FlorglassAluminum logo and an orange, black, and cream visual theme.

## Features

- Home dashboard with service summaries
- Service list displayed with `ListView.builder`
- Add service form with basic validation
- Delete service with a confirmation dialog
- Glass, aluminum and steel demo items fetched from a custom DummyJSON API
- Loading, error, retry, and empty-state handling for the API
- Reusable custom widgets
- `StatelessWidget`, `StatefulWidget`, navigation, state updates, and responsive scrolling layouts

## Requirements

- Flutter SDK installed
- Internet access for the online items API

## Run in VS Code

1. Extract the ZIP file.
2. Open the `florglassaluminum` folder in VS Code.
3. Open Terminal > New Terminal.
4. Run:

   ```bash
   flutter pub get
   flutter run
   ```

5. Choose an available emulator or connected device.

## API

The Online items page requests:

`https://dummyjson.com/c/0050-66a2-4330-bd48`

The API serves a hosted sample glass, aluminum and steel catalog with prices authored in Philippine pesos (PHP). These are illustrative prices, not supplier quotations. Services are saved locally using shared_preferences: additions and confirmed deletions survive refresh/restart in the same browser profile and origin. Initial services appear only when no saved snapshot exists; an intentionally empty list stays empty. Corrupt/unavailable storage shows an error and retry without overwriting saved data.

For a consistent Chrome origin, run `flutter run -d chrome --web-port=7357`. Add a service, refresh the same tab, and open Services to verify restoration. Delete it with confirmation, refresh again, and verify it stays deleted. Browser data belongs to the current profile and origin (including port); clearing site data or using a different/temporary debug profile starts separate storage. No server account or database is used.

Browser API requests include a `clientOrigin` query parameter to avoid the API cache reusing another localhost origin's CORS header. The API host/path is unchanged and browser security remains enabled.

## Project structure

```text
florglassaluminum/
â”œâ”€â”€ assets/
â”‚   â””â”€â”€ images/
â”‚       â””â”€â”€ florglassaluminum_logo.png
â”œâ”€â”€ lib/
â”‚   â””â”€â”€ main.dart
â”œâ”€â”€ analysis_options.yaml
â”œâ”€â”€ pubspec.yaml
â””â”€â”€ README.md
```

## Before presentation

- Run `flutter pub get` and `flutter run`.
- Test the API while internet is available.
- Demonstrate adding a service and deleting it after confirming the dialog.
- Explain that services are stored locally with shared_preferences, while Online items are fetched from the API and the offline catalog is explicitly labeled demo data.
- Run `flutter analyze` and fix any issues reported by your installed Flutter version.

## CC 302 review

See [REQUIREMENTS_REVIEW.md](REQUIREMENTS_REVIEW.md) for the requirement mapping, demo sequence and remaining submission steps.

Online products use a real HTTP request with a 15-second timeout. API prices are PHP sample prices. If the first request fails, users can explicitly open the bundled offline glass, aluminum and steel catalog (PHP prices); this fallback is labeled and does not count as live API data. Refresh retries the API.

Run `flutter test` to verify API success, loading, errors, fallback, empty results, input validation, adding and confirmed/canceled deletion.

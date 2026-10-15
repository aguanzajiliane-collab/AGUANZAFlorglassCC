# FlorglassAluminum

A Flutter and Dart mobile application concept for a glass and aluminum works business. It uses the supplied FlorglassAluminum logo and an orange, black, and cream visual theme.

## Features

- Home dashboard with service summaries
- Service list displayed with `ListView.builder`
- Add service form with basic validation
- Delete service with a confirmation dialog
- Online items fetched from the DummyJSON API
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

`https://dummyjson.com/products?limit=12`

The API is used as a sample remote product feed to demonstrate fetching and displaying JSON data. The service list and add/delete actions are local in-memory demo data and reset when the app restarts.

## Project structure

```text
florglassaluminum/
├── assets/
│   └── images/
│       └── florglassaluminum_logo.png
├── lib/
│   └── main.dart
├── analysis_options.yaml
├── pubspec.yaml
└── README.md
```

## Before presentation

- Run `flutter pub get` and `flutter run`.
- Test the API while internet is available.
- Demonstrate adding a service and deleting it after confirming the dialog.
- Explain that the sample service list is stored in memory, while the Online items page is loaded from an API.
- Run `flutter analyze` and fix any issues reported by your installed Flutter version.

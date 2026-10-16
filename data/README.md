# Demo materials API

`materials_catalog.json` is the source for the hosted sample catalog. Prices are illustrative PHP amounts, not supplier quotes or converted USD prices. Local image paths use the app's existing assets; steel images are labeled remote placeholders.

The app fetches https://dummyjson.com/c/0050-66a2-4330-bd48 with HTTP GET and parses the returned JSON. Verified: HTTP 200, nine products. The server reports expiration on January 14, 2027 (UTC).

DummyJSON custom responses expire after 90 days: https://dummyjson.com/docs/tools

To renew, POST to `https://dummyjson.com/c/generate` with Content-Type `application/json` and body `{ "json": <contents of materials_catalog.json>, "method": "GET" }`. Update the default URL in `lib/main.dart` and its test, or supply the replacement at launch:

```sh
flutter run --dart-define=CATALOG_API_URL=https://your-server.example/catalog
```

A replacement endpoint must return `{ "products": [...] }` with `title`, `description`, numeric PHP `price`, and `thumbnail` fields. Failed requests retain retry and the explicitly labeled offline catalog.

Requirement checking used the existing `REQUIREMENTS_REVIEW.md`; the original instruction PDF was not present in the workspace.

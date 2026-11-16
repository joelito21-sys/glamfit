# elegance_gowns

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Shared Laravel backend

The app loads gown listings and categories from `glamfit-web` at `/api/v1`.
The Laravel website and API use the same Laravel database connection, so gowns
created or updated in the owner dashboard are served to the app from that same
database.

The local API URL defaults to `http://127.0.0.1:8000/api/v1` for Windows and
Flutter Web, and `http://10.0.2.2:8000/api/v1` for the Android emulator. For a
physical Android phone, `10.0.2.2` will not work: set `API_BASE_URL` to the
computer's LAN address and rebuild the app. For example, if the computer is
`192.168.1.20`, run from `customer_app`:

```sh
flutter run --dart-define=API_BASE_URL=http://192.168.1.20:8000/api/v1
```

Keep the phone and computer on the same Wi-Fi network, start Laravel so it
listens on the network interface (for example,
`php artisan serve --host=0.0.0.0 --port=8000`), and allow inbound connections
to port 8000 in the computer's firewall. Replace the example IP with the
computer's current LAN address. Use HTTPS for deployed environments.

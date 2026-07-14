# marverick

**A Flutter app for digitizing flight-training and check-ride paperwork.**

Pilots and check examiners fill out, sign, and submit official check-ride and
training forms from an iPad or iPhone, in place of paper — the app produces
the same signed PDF a paper form would, but with a guided input flow, offline
autosave, and automatic submission.

## What it does

- Presents a menu of check/training form types; creating one opens a guided
  input screen built from that form's field definitions.
- Autosaves as the user fills each field, entirely to a local SQLite database
  — the app works fully offline (e.g. in flight or with no signal), and
  nothing requires a network connection to keep working on a draft.
- Captures handwritten signatures (via a signature pad) and overlays them,
  along with every field's value, onto the form's real PDF template.
- On submit: generates the final PDF, uploads it to Firebase Storage, and
  posts the filled data to the form type's Google Sheet (via a Google Apps
  Script endpoint) for record-keeping.
- Signs in with Firebase Auth (company email/password); an admin account can
  bypass required-field validation, and a hardcoded sample/demo account
  exercises the UI without touching any real backend.

### Supported forms

| Status | Form types |
|---|---|
| Active (in main menu) | Line Check, Line Check (rev 5), PPC (rev 6 / rev 8), RT3, RT4, Line Train, Standard LOFT, FCSS, Sample (signature verification) |
| Retired (data model + DB table kept, no menu entry) | RT1, RT2, RT2.2, RT5, RT6, PPC5, CCC, PSC |

Adding a new form type is mostly mechanical: add a case to `FormType`, create
a file under `lib/services/forms/` defining its fields and payload mapping,
and register it in `form_type_config.dart`.

## Project structure

```
lib/
  models/            Form and Field data models (FormType enum, validation helpers)
  services/
    forms/            One file per form type — each defines its field layout
                       (init()) and its submission payload mapping (toMap())
    form_service.dart  Orchestrates create/save/delete/submit for the active form list
    database.dart      Local SQLite schema, migrations, and queries
    pdf.dart            Fills a form's PDF template with field values + signatures
    form_submission.dart  Submit pipeline: PDF -> Firebase Storage -> Google Sheet
    firestore_sync.dart    Optional Cloud Firestore sync layer (see below)
    authen.dart         Firebase Auth wrapper
  ui/views/           Landing / Login / MainMenu / FileList / Input screens
assets/forms/         PDF templates used as the base for each form type
integration_test/     Code-level test(s) exercising the submission pipeline
```

## Data & sync model

The local SQLite database is the source of truth — every read and write in
the app goes through it first, and it never depends on network access.

A Cloud Firestore sync layer (`firestore_sync.dart`) exists to let a signed-in
user's forms follow them across devices: it pushes local changes up (debounced,
so it doesn't fire on every keystroke), pulls down anything missing locally,
and resolves conflicts by whichever side was modified more recently. All
Firestore/Storage calls are timeout-bounded so a spotty or absent connection
never blocks the app. **This sync path is currently disabled** (call sites
commented out in `form_service.dart`, and the related UI hidden) pending
Firestore being enabled and its security rules applied — see `firestore.rules`
and `storage.rules` for what needs to be pasted into the Firebase console
before re-enabling it.

## Getting started

1. Install [Flutter](https://docs.flutter.dev/get-started/install) (this
   project targets Flutter 3.x / Dart 2.17+).
2. Firebase config is already bundled (`ios/Runner/GoogleService-Info.plist`,
   `android/app/google-services.json`) — no extra setup needed to build.
3. Install dependencies and iOS pods:
   ```
   flutter pub get
   cd ios && pod install && cd ..
   ```
4. Run on a connected device or simulator:
   ```
   flutter run
   ```

Each form type's Google Sheet submission URL and SQLite table name are
declared in `lib/utils/constants.dart` / `lib/services/form_type_config.dart`.

## Versioning

The app's displayed version and changelog live in `kVersion` at the top of
`lib/utils/constants.dart` — bump it and add a dated changelog line there for
any release-worthy change (this is independent of `pubspec.yaml`'s
build-number field, which tracks App Store/Play Store submissions).

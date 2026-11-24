# Week 6 · Local storage

## Done
- **Tip cache** (`lib/data/caching_tip_repository.dart`): wraps any `TipRepository`. It saves the last loaded tips on the device and shows that copy when the server cannot be reached.
- **Vote cache**: the signed-in user's votes are saved per user, so the highlighted Helpful / Not helpful button is still right after a restart without network.
- **Drafts** (`lib/data/draft_store.dart`): an unfinished "share a tip" form is saved per user and removed when the form is empty or sent. The share form itself is not in the app yet (Yusuf), so drafts are not connected to a screen.
- **Storage** (`lib/data/local_store.dart`): `SharedPreferences` for the real app, an in-memory version for tests.
- **Failed votes**: `GuideViewModel.vote` returns `VoteOutcome.failed` instead of throwing; the tip screen shows "Could not save your vote. Check your connection."
- Firebase base merged into main: sign-in service, Firestore repository with a transactional `vote()`, and security rules (public read, verified TUL e-mail for writes, vote counters tied to the user's own vote).

## Temporary state or saved state
| State | Where it lives | Survives a restart |
|---|---|---|
| Search text, sort choice, open screen | The screen (`State`) | No, on purpose |
| Tips, loading and error state | `GuideViewModel` (memory) | No, loaded again; last copy comes from the tip cache |
| Last loaded tips | Device (`CachingTipRepository`) | Yes |
| My votes | Device, per user | Yes |
| Unfinished tip draft | Device, per user (`DraftStore`) | Yes |

## Decisions
- A vote needs the network. Votes are counted on the server (one vote per user), so a vote saved only on the phone and sent later could conflict. The user sees a clear message instead.
- The cache is a wrapper around the repository, so the screens and the view model stay the same when the data source changes.

## Evidence
- `test/local_storage_test.dart` (16 tests): restart without network shows the saved tips; category filter on the saved copy; nothing saved and no network still fails; damaged saved data is ignored; back online refreshes the copy; votes survive a restart; votes of another user are not shown; removing a vote; a vote without network fails and saves nothing; drafts survive a restart, are per user, and are cleared.
- `flutter test`: 69 tests pass. `flutter analyze`: one old warning (`city_places_screen.dart`).

## Still open for week 6
- About 8 real tips each for Firestore (Engin: Dormitories and First weeks). Not written yet.
- Evidence that votes and drafts survive closing the app and rotation, on a device or emulator.
- Share form with draft save, continue and delete (Yusuf).

## Limitations
- `lib/main.dart` still uses `InMemoryTipRepository` and `FakeAuthService`. The cache and Firebase are not connected to the running app yet (Aldiyar: sign-in screen and switch).
- Restarting the app is simulated in tests with two storage objects; it was not tried on a real device or emulator.
- The Firestore rules were not tested in the Firebase emulator or Rules Playground yet.
- No "showing saved copy" banner on screen; `GuideViewModel.showingSavedCopy` is ready for it.

# Week 7 · Requests, responses and offline behaviour (Engin's part)

## Requests the app sends to Firestore
Defined in `lib/data/firestore_tip_repository.dart`; the screens never call them directly.

| Action | Request | Response | If it fails |
|---|---|---|---|
| Load tips | Read the `tips` collection (optionally one category) | A list of tip documents; the app sorts them by date | The tip cache shows the last saved copy and the banner "Showing saved offline copy". With no saved copy the screen shows "Could not load tips". |
| Share a tip | Create `tips/{id}` with title, text, category, author and both counters at 0 | The created tip | The error reaches the share screen; nothing is added to the list. |
| My vote | Read `tips/{id}/votes/{uid}` | `helpful`, `notHelpful` or no document | The saved copy of my votes is used; with none, no vote is shown. |
| Vote | One transaction: read the tip and my vote document, compute the new counters with `applyVote`, update `tips/{id}` and write or delete `tips/{id}/votes/{uid}` | The updated tip | `GuideViewModel.vote` returns `VoteOutcome.failed`; the counts and the highlighted button stay as they were and the screen shows "Could not save your vote. Check your connection." |

A vote needs the network on purpose: the server counts one vote per user, so a vote kept only on the phone and sent later could conflict.

## Unexpected responses
- Tip no longer exists when voting: the repository throws, the vote ends as `failed`, nothing is changed.
- A saved copy that cannot be read (broken JSON, unknown category): it is ignored and treated as "no copy".
- Missing fields in a Firestore document get safe defaults (empty text, 0 votes, category Daily life) instead of crashing.

## Evidence
`test/vote_failure_test.dart` (8 tests):
- failed request: no count changes, no highlighted button, no change notification; removing a vote that fails keeps the old vote
- unexpected response: unknown tip gives a failure, not a crash; a saved copy with an unknown category is ignored
- lost connection: the same vote succeeds once after the connection returns; a connection lost between two votes keeps the first one
- screen: a failed vote shows the connection message and keeps the count

## Limitations
- The tests use a repository that fails on request, not the real `FirestoreTipRepository`. Testing that class directly needs the Firebase emulator or a fake Firestore package, which the project does not use yet.
- Real network loss on a device or emulator is not tried yet.

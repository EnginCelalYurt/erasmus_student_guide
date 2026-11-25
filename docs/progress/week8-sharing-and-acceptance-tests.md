# Week 8 · System sharing and acceptance tests

**Selected capability:** sharing a tip to other apps through the system share sheet. Our users already pass advice on in Erasmus chat groups, and the feature needs no permission. If the share sheet is not available, the tip text is copied to the clipboard and the screen says so (`lib/utils/share_tip.dart`).

**What was tested:** all acceptance criteria of the guide, by hand, in Chrome on Windows with the in-memory sample data (labelled as fictional in the app). The automated suite (90 tests) passes as well.

## Manual acceptance test (Chrome on Windows, in-memory sample data)
| Test | Result |
|---|---|
| T1 Reading without signing in, sample data labelled | Passed |
| T2 "Most helpful" order follows the Wilson score | Passed |
| T3 "Newest" order | Passed |
| T4 The hidden tip does not appear | Passed |
| T5 Category filter and tip count | Passed |
| T6 Search with a match and with no match | Passed |
| T7 "Share tip" is hidden when signed out | Passed |
| T8 Non-TUL e-mail shows an error | Passed |
| T9 TUL e-mail signs in, "Share tip" appears | Passed |
| T10 Voting while signed out asks to sign in (the vote buttons are visible) | Passed as described; differs from the criterion wording |
| T11 Vote and remove a vote | Passed |
| T12 Text under 15 characters shows a message | Passed |
| T13 A valid tip is published and shows in the list | Passed (same device only) |
| T14 Draft is kept after leaving the form | Passed |
| T15 Share button | System share window opened |
| T16 Clipboard fallback | Not reached by hand because the share window opened; covered by the automated test only |

## Not tested yet
- Sharing on a phone or an Android emulator (Aldiyar), and text size 200% and contrast on a phone.
- A tip published by one user showing for another user: needs Firebase connected to the running app.

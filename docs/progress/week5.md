# Week 5 · First complete user journey

## Done
- Main flow with sample data: guide home → category → tip detail → vote. Search and "Most helpful / Newest" sorting on the home and category screens.
- Separation of interface, application state and data access:
  - **Interface** (`lib/screens/`): draws the screens and keeps only temporary state such as the search text and the sort choice.
  - **Application state** (`lib/viewmodels/guide_view_model.dart`): the tips, loading and error state, and the signed-in user's votes. Screens listen to it with `ListenableBuilder`.
  - **Data access** (`lib/data/tip_repository.dart`): the screens never call it directly. For now it is `InMemoryTipRepository` with fictional sample tips, chosen in one place in `lib/main.dart`.
- AI review recorded in `AI_USE.md`.

## How a user action changes the displayed state (voting)
1. The user taps **Helpful** on the tip detail screen.
2. The screen calls `GuideViewModel.vote(tipId, VoteValue.helpful)`.
3. The view model checks sign-in. Signed out: it returns `signInRequired` and the screen shows "Sign in with your TUL e-mail to vote."
4. Signed in: it decides the new vote (tapping the same button again removes the vote) and calls `TipRepository.vote`, which updates the helpful and not-helpful counts.
5. The view model stores the updated tip and the user's vote, then calls `notifyListeners()`.
6. Every screen listening to the view model is rebuilt: the button is highlighted, the counts and the Wilson score change, and the order on the home and category screens updates. If a tip now has at least 5 votes and more not-helpful than helpful votes, it disappears from the lists and the category counts.

## Evidence
- `test/guide_view_model_test.dart`: loading, search and sort, voting signed in and out, changing and removing a vote, hiding low-rated tips, sharing needs sign-in, failed loading.
- `test/tip_detail_screen_test.dart`: tapping Helpful while signed out shows the sign-in message; while signed in the count goes up.
- `flutter test`: 53 tests pass.
- Checked by hand in the browser: category tiles show only visible tips ("Daily life: 0 tips", "1 tip"), an empty category says "No tips in this category yet."

## Limitations
- The share-tip form is not in the app yet (Yusuf, W5). `GuideViewModel.addTip` is ready for it.
- Sign-in is a fake service (`FakeAuthService`); Firebase sign-in comes next (Aldiyar).
- Sample data lives in memory and resets when the app restarts. Local storage is week 6.

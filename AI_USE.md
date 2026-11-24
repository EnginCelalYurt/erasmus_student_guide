# AI use log

AI-generated changes we reviewed, with what we accepted or corrected.

## 2026-11-19 · Wilson score ranking · reviewed by Engin Yurt

**Change:** AI-generated `wilsonScore` function (`lib/logic/tip_ranking.dart`), the lower bound of the Wilson score interval with 95% confidence.

**Check:** Unit tests in `test/tip_ranking_test.dart`: 30 helpful / 1 not helpful (≈ 0.84) ranks above 1 / 0 (≈ 0.21), and no votes gives 0.

**Result:** Accepted without changes.

## 2026-11-20 · Firestore rules and local storage · reviewed by Engin Yurt

**AI used for:** the security rules, the tip/vote cache, drafts and their 16 tests.

**Engin:** decided the behaviour (reading tips stays public, writing needs a verified TUL e-mail, a vote needs the network), ran `flutter analyze` and the 69 tests, reviewed the code, opened and merged the pull requests.

**Not tested yet:** the rules (Firebase emulator) and a restart on a real device.

**Result:** Accepted without changes.

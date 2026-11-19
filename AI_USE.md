# AI use log

AI-generated changes we reviewed, with what we accepted or corrected.

## 2026-11-19 · Wilson score ranking · reviewed by Engin Yurt

**Change:** AI-generated `wilsonScore` function (`lib/logic/tip_ranking.dart`), the lower bound of the Wilson score interval with 95% confidence.

**Check:** Unit tests in `test/tip_ranking_test.dart`: 30 helpful / 1 not helpful (≈ 0.84) ranks above 1 / 0 (≈ 0.21), and no votes gives 0.

**Result:** Accepted without changes.

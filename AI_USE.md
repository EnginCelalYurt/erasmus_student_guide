# AI Usage & Peer Review Log (Week 5)

## 1. Context & Task
For Week 5 ("Building the First Complete User Journey"), the goal was to implement the essential screens, input validations, clear user feedback, and clean separation between UI, Application State (ViewModel), and Data Access layers.

---

## 2. AI-Generated Changes Reviewed

### A. Wilson Score Interval for Tip Ranking (`lib/logic/tip_ranking.dart`)
* **Prompt/Origin:** The team requested a robust community ranking mechanism so that low-sample posts (e.g., 1 helpful / 0 not helpful) do not rank higher than well-established helpful guides (e.g., 30 helpful / 1 not helpful).
* **AI Proposal:** Generated the Wilson score lower bound formula with 95% confidence interval ($z = 1.96$):
  $$\text{score} = \frac{p + \frac{z^2}{2n} - z \sqrt{\frac{p(1-p) + \frac{z^2}{4n}}{n}}}{1 + \frac{z^2}{n}}$$
* **Behavior Check & Testing:** Tested with unit tests in `test/tip_ranking_test.dart` and `test/widget_test.dart`.
  - `wilsonScore(30, 1)` yields $\approx 0.86$.
  - `wilsonScore(1, 0)` yields $\approx 0.20$.
* **Decision:** **Accepted.** The mathematical logic works reliably without external dependencies.

---

### B. Shared Contract Alignment (`lib/models/tip.dart`)
* **Initial AI Output:** An earlier prototype implementation defined a custom `Tip` model with local fields (`helpfulCount`, `isMarkedHelpful`, `tags`).
* **Problem Identified:** During git merge with `origin/main`, this created merge conflicts with the shared team contract created by teammates.
* **Correction:** **Corrected.** Rolled back the local tip model and strictly aligned with the shared `Tip` contract:
  - `TipCategory` enum (`firstWeeks`, `dormitories`, `transport`, `emergency`, `studentLife`, `dailyLife`).
  - Dual voting fields (`helpful` and `notHelpful`).
  - Added vote casting via `TipRepository.vote()` with Wilson score recalculation.

---

### C. Input Validation for Sharing Experience (`NewTip.validateBody`)
* **AI Proposal:** Client-side validation enforcing non-empty title and at least 15 characters for advice body to prevent spam or empty submissions.
* **Behavior Check:** Form validation was tested on `ShareScreen`:
  - Inputting 5 characters triggers: *"Write at least 15 characters."*
  - Inputting non-TUL email triggers: *"Only TUL e-mails (@p.lodz.pl or subdomains) are allowed."*
* **Decision:** **Accepted.** Meets Acceptance Criteria for User Story 2.

---

### D. Architectural Separation via ViewModel (`lib/viewmodels/guide_view_model.dart`)
* **AI Proposal:** Encapsulated state (active category, search query, sort mode, loading state, user authentication, and cached tips) into `GuideViewModel` extending `ChangeNotifier`.
* **Behavior Check:** UI widgets now observe the ViewModel rather than directly calling async repository methods.
* **Decision:** **Accepted.** Satisfies the requirement: *"Separate interface code, application state and data access. Use a ViewModel or an equivalent mechanism."*

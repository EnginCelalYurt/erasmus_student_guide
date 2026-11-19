# Yusuf — Task Checklist (W5–W9)

> **Rule:** Start every task from `main`, use a new branch, open a small PR (one task per PR). No force push.
> Tell Engin before changing the contract (`Tip`, `TipRepository`, `AuthService`).
> Demo data must be fictional and labelled. No real personal data.

---

## W5: First Complete User Journey (Sample Data)

- [ ] **Share-tip form** — Create a tip submission form with input validation and user feedback (success/error messages)
- [ ] **Vote buttons** — Add vote (upvote/downvote) buttons that visually highlight the user's current vote
- [ ] **Fix category counts** — Ensure the category list shows the correct number of tips per category
- [ ] **Fix empty messages** — Show appropriate empty-state messages when a category or list has no tips
- [ ] **Remove placeholder tabs** — Delete the unused Campus, Places, and Saved tabs from navigation
- [ ] *(Shared)* **Widget test** — Contribute to the end-to-end widget test: browse → open tip → vote → share a tip that appears in the list

**Evidence:** A user can browse → open a tip → vote → share a new tip that appears in the list, verified by a widget test.

---

## W6: Local Storage and App State

- [ ] **Draft save/continue/delete** — Allow users to save a tip draft in the share form, continue editing it later, and delete it
- [ ] **Keep state on rotation** — Preserve form data and UI state when the device is rotated
- [ ] **Clear empty/invalid-input messages** — Properly clear validation error messages when input is corrected
- [ ] **Write ~8 tips** — Write approximately 8 realistic (but fictional and labelled) tips for categories: **Student life** and **Emergency**. Hand off to Aldiyar for Firestore loading.
- [ ] *(Shared)* **Evidence** — Demonstrate that drafts and votes survive app close and device rotation

---

## W7: API (Firebase) and Offline Reliability

- [ ] **Non-blocking loading states** — Implement loading, success, empty, and error UI states without blocking the main thread
- [ ] **Offline banner with retry** — Show an "Offline, data may be outdated" banner when there is no connection, with a retry button
- [ ] **Accessibility pass** — Verify and fix colour contrast ratios; add TalkBack/screen-reader labels to all interactive elements
- [ ] *(Shared)* **Evidence** — Real tips load from Firebase; predictable behaviour when connection is lost

---

## W8: Mobile Capability (System Sharing)

- [ ] **Share tip to other apps** — Use the platform share sheet to share a tip's content to other installed apps
- [ ] **Fallback: copy to clipboard** — If the share sheet is unavailable or the user prefers, provide a "copy to clipboard" fallback
- [ ] *(Shared)* **Evidence** — Sharing works on emulator and real device; fallback tested and documented

---

## W9: M2 Working MVP (25 Points)

- [ ] **Demo build (APK + web)** — Produce a release APK and a web build for the demo
- [ ] **Main journey demo** — Walk through the main user journey in the running app with fictional labelled data
- [ ] **Fictional data labelled** — Verify all demo/sample data is clearly marked as fictional
- [ ] *(Shared)* **Agree on critical fixes** — With the team, identify and prioritise the most important fixes before adding new features

---

## Weekly Progress Reminders

Each week, add a short `docs/progress/weekN.md`:
1. What was done
2. Evidence (test result or screenshot)
3. Limitations

No long reports. No claims without evidence.

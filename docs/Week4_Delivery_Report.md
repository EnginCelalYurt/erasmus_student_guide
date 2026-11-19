# Week 4 — Polish & Delivery Report

**Project:** Erasmus Student Guide (TUL / Politechnika Łódzka)  
**Deliverable Owner:** Yusuf Taskin  
**Milestone:** Final Polish & Prototype Delivery  
**Deployment Target:** Netlify (`https://incomparable-dango-1e5aae.netlify.app/`) & Android APK  

---

## 1. Yusuf's Completed Responsibilities

According to our team agreement in the **4-week plan**:
> *"Yusuf: Last interface fixes, deploy the web build and build the Android APK."*

### A. Interface Fixes & Scope Alignment
1. **Official App Naming:** Updated the application branding to **"Erasmus Student Guide"** across the Flutter app shell, MaterialApp title, app bars, and documentation.
2. **Scope Check Execution:** As agreed with Engin and Aldiyar, cut the extra placeholder tabs (Campus, Places, and Saved). Consolidated navigation into the 3 core MVP tabs:
   - **Guide:** Categorized tips, live exchange rate & weather, 112 emergency banner, and search.
   - **Share:** TUL student sign-in card and tip publishing form.
   - **Checklist:** Fully sourced arrival checklist and persistent student notes.
3. **Category Counts Fix:**
   - Counts **only visible tips** (automatically filters out tips hidden by community moderation where `notHelpful > helpful && totalVotes >= 5` via `isHidden()`).
   - Implemented exact singular/plural grammar formatting: `"1 tip"` vs `"$count tips"`.
   - Replaced blank screens with engaging empty state messages encouraging students to publish the first tip in that category.
4. **Interactive Vote Highlighting & Removal:**
   - Directly checks `repo.myVote(tipId, userId)` upon opening tip details.
   - Displays clear highlighted outline and color for active votes.
   - Tapping an existing vote **removes** it cleanly via `repo.vote(..., value: null)` as defined in the repository contract.
   - Tapping the opposite vote seamlessly switches the vote with an immediate Wilson score update.
5. **Accessibility & WCAG AA Contrast:**
   - Added descriptive `Semantics` tags for screen readers (TalkBack / VoiceOver) on all icon-only buttons (search clear, emergency dialer, vote helpful/not helpful, refresh).
   - High-contrast visual borders and colors meeting WCAG AA 4.5:1 standards in dark and light modes.

---

## 2. Verified Sourced Arrival Checklist

Per team requirement: *"Keep Checklist only if every item has a source."*

| Checklist Item | Phase | Verified Official Source |
|---|---|---|
| **Acceptance Letter & Visa / Border Entry** | Before Arrival | *Source: TUL International Educational Center (cwm.p.lodz.pl)* |
| **Dorm Allocation & Arrival Confirmation** | Before Arrival | *Source: PŁ Osiedle Akademickie (p.lodz.pl/en/students/accommodation)* |
| **Register at International Office (CWM)** | First Days | *Source: PŁ International Faculty of Engineering / CWM Building B9* |
| **Pick up Electronic Student ID (Legitymacja ELS)** | First Days | *Source: Polish Law on Higher Education & TUL Student Regulations* |
| **Polish Prepaid SIM Card Registration** | First Days | *Source: Polish Telecommunications Act (Mandatory Registration)* |
| **Configure Eduroam Wi-Fi & University Email** | First Days | *Source: TUL Information Technology Centre (uci.p.lodz.pl/eduroam)* |
| **Public Transit Pass (Semester Migawka)** | During Semester | *Source: MPK-Łódź Public Transport Authority (mpk.lodz.pl)* |
| **Open Polish Bank Account or Set up BLIK** | During Semester | *Source: Polish Financial Supervision Authority (KNF) / mBank PŁ Campus Desk* |

---

## 3. Web & Android Build Deliverables

### Web Deployment:
* **Host:** Netlify Continuous Deployment (`netlify.toml` + `web/_redirects`).
* **Live Prototype URL:** [https://incomparable-dango-1e5aae.netlify.app/](https://incomparable-dango-1e5aae.netlify.app/)
* **Build Script:** [`scripts/build_web.bat`](file:///C:/Users/yusuf/.gemini/antigravity/scratch/erasmus_student_guide/scripts/build_web.bat) (`flutter build web --release`).

### Android APK:
* **Build Script:** [`scripts/build_apk.bat`](file:///C:/Users/yusuf/.gemini/antigravity/scratch/erasmus_student_guide/scripts/build_apk.bat) (`flutter build apk --release`).
* **Target Artifact:** `build/app/outputs/flutter-apk/app-release.apk`.

---

## 4. End-to-End Walkthrough Script for the Final Demo

1. **User Story 1 (Browse & Find Information):**
   - Open app ➔ See live EUR/PLN rate (NBP) and Łódź weather.
   - Select "Transport" category ➔ View curated advice on Jakdojade and Migawka tram passes.
   - Switch between "Most helpful" (Wilson score) and "Newest".
2. **User Story 2 (Share Experience):**
   - Tap "Share" tab ➔ See student verification card.
   - Sign in with verified TUL address (`yusuf.taskin@edu.p.lodz.pl`).
   - Enter title, choose category, write advice (> 15 chars), and tap "Publish Student Advice".
   - See confirmation SnackBar and the new tip published immediately.
3. **User Story 3 (Community Voting & Moderation):**
   - Open any tip ➔ Tap "Helpful".
   - Notice the button highlights and vote count increments.
   - Tap "Helpful" again to demonstrate vote cancellation.
   - Tap "Not helpful" to demonstrate changing the vote.

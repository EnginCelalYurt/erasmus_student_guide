# Week 6 — Local Data Storage & Application State Report

**Project:** Erasmus Student Guide (Lodz University of Technology)  
**Author:** Yusuf Taskin  
**Technology:** Flutter / Dart · SharedPreferences Persistent Storage  

---

## 1. Data Model & State Lifecycle

We explicitly separate **temporary interface state** from **persistent application state** that must survive an application restart:

| State Type | Scope | Storage Mechanism | Examples in App |
|---|---|---|---|
| **Temporary Interface State** | Current screen / transient session | Flutter Widget State / Memory | • Text entered into search fields before submitting<br>• Active category filter tab selection<br>• Loading indicators and animation progress<br>• Open dialogs, dropdowns, and expansion states |
| **Persistent Application State** | Survives app restarts & device reboots | Local Storage (`SharedPreferences` + JSON) | • **User-created tips & guides** (`erasmus_guide_local_tips_v2`)<br>• **User votes** (`helpful` / `notHelpful`) mapped per user and tip ID (`erasmus_guide_local_votes_v2`)<br>• **Active authenticated student session** (`erasmus_guide_auth_email_v2`)<br>• **Saved bookmarks & orientation checklist progress** (`uniguide_v2_prefs`)<br>• **Theme preferences** (Dark / Light / System) |

---

## 2. Local Storage Implementation

We implemented two primary persistent services conforming to our shared contracts:

1. **`LocalTipRepository` ([`lib/data/local_tip_repository.dart`](file:///C:/Users/yusuf/.gemini/antigravity/scratch/erasmus_student_guide/lib/data/local_tip_repository.dart)):**
   - Automatically initializes on app start.
   - Combines default seed data with user-published tips loaded from local JSON.
   - Restores user voting records across restarts so a student cannot double-vote after reopening the app.
   
2. **`PersistentAuthService` ([`lib/data/persistent_auth_service.dart`](file:///C:/Users/yusuf/.gemini/antigravity/scratch/erasmus_student_guide/lib/data/persistent_auth_service.dart)):**
   - Restores the student's signed-in status across app restarts.
   - Enforces the student verification rule: only `@p.lodz.pl` and `@edu.p.lodz.pl` email addresses are accepted.

---

## 3. CRUD Operations Supporting Main User Task

| Action | Function | Persistent Behavior |
|---|---|---|
| **Create** | `addTip(NewTip tip, {userId})` | Serializes new advice to JSON and appends to persistent local list. |
| **Read** | `fetchTips({category})` | Reads and deserializes cached + user tips; sorts by Wilson score. |
| **Update** | `vote({tipId, userId, value})` | Updates vote counts on the tip and records the user's vote mapping. |
| **Delete** | `deleteTip(tipId, {userId})` | Removes custom tip from persistent storage and cleans associated vote records. |
| **Session Clear**| `signOut()` | Clears the persistent authentication key upon sign-out. |

---

## 4. Reopening, Configuration Changes & Empty States

* **Reopening the App:** Tested via automated unit test `LocalTipRepository persists and restores created tips across app restarts`. Tips, votes, and sign-in credentials remain intact.
* **Empty Data & Search Fallbacks:** If a search query yields no matches or a category has no items, the app renders an informative `EmptyState` with actionable text instead of blank screens or errors.
* **Input Validation:** Submitting text shorter than 15 characters or invalid non-TUL emails triggers immediate inline error feedback before data persistence.
* **Fault Tolerance:** If stored JSON is ever corrupted or cleared, the repository falls back safely to default campus sample tips.

---

## 5. Privacy & Demonstration Records

* No passwords or sensitive personal records are stored in plain text.
* The local authentication service stores only demonstration student identity (`yusuf.taskin@edu.p.lodz.pl`).

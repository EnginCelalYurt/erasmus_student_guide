# Project Brief – Erasmus Student Guide (TUL)

**Team:** Aldiyar Kairolla · Yusuf Taskin · Engin Yurt
**Technology:** Flutter (Dart) · Android Studio / VS Code
**Prototype:** https://incomparable-dango-1e5aae.netlify.app/

## 1. Problem

**User group:** Incoming Erasmus students at Lodz University of Technology (TUL),
from acceptance until their first weeks in Łódź.

**Task:** Settle in: complete the arrival steps, find their way around the city,
and choose courses for the Learning Agreement.

**Obstacle:** Practical information is spread across many places (university pages,
USOS, ESN, social media groups), partly in Polish, and it is not clear what to do first.
Students who already went through this have the knowledge, but it is lost when they leave.

**Our idea:** A student-powered guide. Current TUL students share course reviews,
guides and experiences; incoming students read them before and after arrival.

## 2. Existing solutions

| Solution | Strength | Gap for our users |
|---|---|---|
| TUL / International Office web pages | Official and reliable | Formal rules, not student experience (exam style, workload, daily life) |
| Erasmus social media groups (Facebook / WhatsApp) | Fast answers from real students | Not structured; good answers get buried and are hard to find later |

**Difference:** Structured by topic and by course, written by students, ranked by helpfulness.

## 3. Evidence vs. assumptions

**Evidence**
- Peer prototype review by another team (Efe, Antonio, Diego), see
  `docs/Erasmus_Prototype_Feedback_Report.docx`: the arrival checklist and local
  information were rated as useful; search scope, action feedback and data errors were reported as problems.

**Assumptions (not verified yet)**
- Current students are willing to write reviews and guides voluntarily.
- Student reviews help more than official course descriptions when choosing courses.


## 4. User stories

### US-1: Find guides and experiences
As an incoming Erasmus student, I want to browse guides and experiences shared by
other TUL students, so that I can prepare for my first weeks without searching many sources.

**Acceptance criteria**
- [ ] Content can be filtered by category (e.g. Dormitories, Transport, Emergency, Student Life).
- [ ] Posts can be sorted by "Most helpful" (Wilson score) and "Newest".
- [ ] A post with 30 helpful / 1 not helpful ranks above one with 1 helpful / 0 not helpful.
- [ ] Reading does not require signing in.

### US-2: Share my experience
As a current TUL Erasmus student, I want to sign in with my TUL e-mail and share a
review, guide or tip, so that future students benefit from what I learned.

**Acceptance criteria**
- [ ] Only TUL e-mail addresses can sign in; other addresses see an error message.
- [ ] Signed-out users can read but do not see "Share" or voting buttons.
- [ ] Submitting text shorter than 15 characters shows a validation message.
- [ ] A published post appears for other users.

### US-3: Course reviews
As an incoming Erasmus student, I want to read other students' reviews of TUL courses,
so that I can choose my Learning Agreement courses with more confidence.

**Acceptance criteria**
- [ ] Searching "mobile" shows only courses whose name or code contains "mobile".
- [ ] A search with no results shows "No courses found" and a "Reset filters" button.
- [ ] Tapping a course shows its reviews and average rating.
- [ ] A signed-in user can vote a review helpful / not helpful once.

## 5. MVP scope

**User journey:** A current student signs in → shares a course review or guide →
an incoming student finds it through search or category → votes it helpful → helpful content rises to the top.

**Main screens**
1. Courses (search, faculty filter, sorting)
2. Course detail (reviews, rating, voting)
3. Łódź guide (categories, emergency info, city spots)
4. Share (review / guide form, sign-in required)
5. Planner (saved courses, ECTS count, arrival checklist)

**Out of scope**
- Universities other than TUL
- Official TUL single sign-on (USOS); we verify by TUL e-mail instead
- Automatic content filtering and an admin panel (moderation = report button + manual review)
- Push notifications, offline mode
- Optimised desktop layout (mobile first)

## 6. Challenging our assumptions

| Source | What changed |
|---|---|
| AI review | Simple "likes − dislikes" ranking is misleading (1/0 beats 30/1) → we use the Wilson score, which needs both helpful and not-helpful votes. |
| AI review | Scope was first course-only → clarified as a full newcomer guide; sign-in added so only TUL students can post. |
| Peer feedback | Arrival checklist kept (rated useful). Planned fixes: confirmation message when a course is saved, clearer search hint, correct faculty tags, higher-contrast buttons. Desktop layout moved out of scope. |

## 7. Accessibility requirements

1. **Readable text and contrast:** All text and buttons meet WCAG AA contrast (4.5:1) in the dark theme, and screens remain usable when the system font size is increased to 200%.
2. **Meaningful labels:** Every icon-only button (bookmark, clear search, vote, map) has a descriptive label for TalkBack / VoiceOver (e.g. "Bookmark Mobile Systems & Applications").

## 8. Main risks

| Risk | Mitigation |
|---|---|
| Not enough students write content (cold start) | Team writes the first content from its own experience |
| TUL e-mail sign-in not possible / unclear domain | Verify early; fallback: any e-mail + manual approval |
| Backend (Firebase) is new for the team | Build sign-in + one shared collection first, then extend |
| Wrong or outdated information | Helpful / not-helpful voting + report button |

## 9. Team responsibilities and initial tasks 

| Member | Responsibility | First task |
|---|---|---|
| Yusuf Taskin | Flutter UI and prototype | Push the prototype version to the repo; apply peer-feedback fixes |
| Engin Yurt | Documentation, repository, testing | Project brief, acceptance-criteria tests, branch + pull-request workflow |
| Aldiyar Kairolla | Backend and research | Firebase sign-in prototype; confirm TUL e-mail domain; verify guide content |

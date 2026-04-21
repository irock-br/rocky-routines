---
name: pre-meeting-brief
description: >
  Generates an adaptive, intelligence-rich Pre-Meeting Brief calibrated to the banker running it,
  the type of meeting, and the stage of the deal or relationship. Use this skill whenever anyone
  says "prep me for my meeting", "brief me before my call with X", "prepare for today's meetings",
  "what do I need to know before meeting Y", "run morning briefs", "quick brief on X",
  "what's the context for my call", or any variation of meeting preparation. The skill is
  persona-agnostic — it reads the caller's own calendar, email, Asana, Drive, Attio, and contacts
  to build a brief tailored to that banker's relationship and deal context. Always use this skill
  for meeting prep — it orchestrates across 8+ data sources and applies deal-stage intelligence
  that cannot be replicated inline.
---

# Pre-Meeting Brief — Adaptive Intelligence Skill

This skill generates a CEO-grade meeting brief for whichever BugleRock banker invokes it.
It is **persona-agnostic** — it reads YOUR calendar, YOUR email, YOUR tasks, and YOUR CRM data.
It is **adaptive** — the brief it produces changes based on what type of meeting this is and
how far along the relationship or deal is.

**The brief is never generic. Every output is a bespoke intelligence document.**

---

## Step 0 — Establish user context

Before any data fetching, establish who is running this skill:

```
tool: Google Calendar → get current user identity
tool: Gmail → get authenticated account email
tool: Asana → get_me (returns name, email, workspace)
```

From this point forward, all data fetches are scoped to the invoking user's accounts.
Never assume a fixed name, email, or set of relationships.

---

## Step 1 — Determine run mode

**A — Scheduled / batch** ("run morning briefs" / automated 5am trigger):
→ Fetch ALL of today's calendar events for the invoking user
→ Filter: external attendees only (exclude all-internal meetings unless explicitly requested)
→ Sort by meeting time
→ Run Steps 2–5 in parallel for each meeting → deliver all briefs
→ **Ambiguous classification in scheduled mode:** if meeting type signals conflict and cannot
  be resolved from data alone (e.g. invite says "catch-up" but a Drive deck + term sheet both
  exist), do NOT pick one and silently proceed. Instead, generate a **dual-scenario brief**:
  write the Quick Strip, Sections 1–4, and Section 9 once (shared intelligence), then produce
  two clearly labelled scenario blocks — Scenario A and Scenario B — each with its own
  meeting type badge, talking points, and desired outcome. Label them plainly:
  > `SCENARIO A — If this is a RELATIONSHIP check-in`
  > `SCENARIO B — If this is a NEGOTIATION / deal-advance meeting`
  The reader decides which scenario applies before walking in.
→ **After all briefs complete:** produce a one-line batch summary in chat:
  `"[N] briefs ready. Confidence: [Meeting 1: HIGH] [Meeting 2: MEDIUM ⚠️] [Meeting 3: LOW ❌]"`
  Flag any LOW-confidence or DUAL-SCENARIO brief explicitly.
→ **No interactive questions in scheduled mode.** Gaps declared in Section 9. Silent run only.

**B — On-demand chat** ("prep me for my 3pm" / "brief me on [Company]"):
→ This is an interactive run. Follow the full protocol in **Step 1B** below.
→ Never silently accept gaps — ask the user when data sources can't answer.

**C — Pre-emptive / speculative** ("I'm reaching out to X tomorrow" / "I want to pitch Y"):
→ No calendar event exists yet — interactive run, follow Step 1B.
→ Output format: FIRST_CONTACT_BRIEF

**D — Rapid / last-minute** ("quick brief", meeting in < 30 mins):
→ Flag as ⚡ RAPID BRIEF
→ **Minimal interaction** — ask at most one clarifying question if the meeting identity is ambiguous.
→ Prioritise speed: run all sources in parallel, truncate output to essentials.
→ Gaps are noted inline, not resolved interactively.

---

## Step 1C — Data source failure handling (scheduled runs)

If any data source returns an error (API down, authentication expired, timeout, rate limit)
during a scheduled run, apply this protocol — do not silently proceed with incomplete data.

### Failure classification

**Partial failure** — one or two non-critical sources fail (e.g. web search, Drive):
→ Continue the run for that meeting using available sources
→ Mark failed dimensions as ❌ GAP (source error) in Section 9 — distinguish from "returned empty"
  by noting: `❌ GAP — source error: [error type]` vs `❌ GAP — no records found`
→ Include the source error in the in-chat batch summary

**Critical failure** — a core source fails (Calendar, Gmail, Attio, or Asana):
→ **Pause the entire run immediately** — do not generate any briefs
→ Wait 20 minutes, then retry automatically (single retry attempt)
→ Notify the user immediately via in-chat message:

> "⚠️ Morning brief run paused.
> [Source name] returned an error at [HH:MM] SGT: [error description in plain language].
> I'll retry automatically at [HH:MM + 20 mins] SGT.
> If the retry fails, you'll need to run the brief manually or check the connection."

**Retry failure** — the 20-minute retry also fails:
→ Abandon the scheduled run for this cycle
→ Notify the user:

> "❌ Morning brief run failed — could not complete after retry.
> Source: [name] · Error: [description]
> Manual brief available — just ask me to prep for a specific meeting."

### Error message format

Always state in plain language:
- Which source failed
- What the error means (not a raw API error code — translate it)
- What will happen next (retry time, or manual fallback)

Plain language error translations:
- `401 / auth error` → "Authentication expired — the [source] connection needs to be re-authorised"
- `429 / rate limit` → "[Source] rate limit reached — too many requests in a short window"
- `503 / unavailable` → "[Source] is currently unavailable — likely a temporary outage"
- `timeout` → "[Source] did not respond in time — connection may be slow or intermittent"

---

## Step 1B — Interactive gap resolution (chat runs only: modes B and C)

This step governs the interactive dialogue before and during data ingestion.
**The goal is not to interrogate the user. It is to fill the specific gaps that data sources can't.**

### Phase 1 — Meeting identification (before any data fetching)

First, identify which meeting this is for. Check the calendar silently.

**If the meeting is unambiguous** (only one upcoming external meeting, or user named a specific person/company):
→ Confirm in one line and proceed immediately to data ingestion:
  > "Got it — prepping your brief for [Name] at [Company], [Time]. Pulling data now."

**If ambiguous** (multiple meetings today, or user was vague):
→ Show the list, let them pick. One question, no more:
  > "I see [N] meetings today with external attendees:
  > · [Time] — [Name/Company] ([invite title])
  > · [Time] — [Name/Company] ([invite title])
  > Which one?"

**If no calendar event exists** (pre-emptive mode C):
→ Ask for the minimum needed to start:
  > "No calendar event found. Who are you meeting, and what's the context in one line?"

### Phase 2 — Silent data ingestion

Once the meeting is identified, run ALL of Step 3 (data ingestion) silently and in parallel.
Do not narrate the process. Do not say "searching Gmail now..." or "checking Attio...".
Just work. The user will see a thinking indicator.

While ingesting, build the gap register (from Step 4D) internally.

**Data source failures in chat runs:**
If a source returns an error during ingestion (not just empty results — an actual error):

- **Non-critical source failure** (web search, Drive): continue silently, mark as
  `❌ GAP — source error` in the confidence register, surface in Section 9.

- **Critical source failure** (Gmail, Attio, Asana, Calendar): pause ingestion and
  notify the user immediately — do not silently proceed:
  > "⚠️ Hit an issue fetching from [source]: [plain-language error description].
  > I'll retry in 20 minutes if you'd like, or I can proceed with the data I have —
  > just let me know."
  Wait for the user's response before continuing. If they say proceed, treat the
  failed source as ❌ GAP and continue. If they say retry, wait 20 minutes and try once more.
  Apply the same plain-language error translations as Step 1C.

### Phase 3 — Adaptive questioning (after ingestion, before writing)

Once ingestion is complete, review the gap register.

**Do not ask about gaps that don't materially affect the brief.**
The threshold for asking: would filling this gap change the meeting type classification,
the angle, the talking points, or the watch-outs? If yes → ask. If no → note it in Section 9.

**Batch all questions into a single message.** Never ask one question, wait, then ask another.
If there are 3 gaps worth asking about, ask all 3 at once. Maximum 4 questions in one pass.

**Question triggers and exact wording:**

| Gap detected | Ask if... | Question to ask |
|---|---|---|
| No calendar agenda | Invite description is blank | "The invite has no agenda — what's the main purpose of this meeting?" |
| Meeting type ambiguous | Signals conflict (e.g. DISCOVERY vs PITCH unclear) | "Is this more of an exploratory conversation or are you presenting something specific?" |
| Deal stage unclear | Attio absent + email history is thin or ambiguous | "Where would you say this relationship stands — first real conversation, actively exploring a mandate, or further along?" |
| Key attendee unknown | Web search + LinkedIn returned nothing | "I couldn't find much on [Name] online — do you know their background or how they came to be in this meeting?" |
| Your history context | Attio absent + Gmail returned no prior threads | "Any prior conversations with [Company] I should know about, or is this genuinely the first touchpoint?" |
| Your objective unclear | Meeting is a catch-up or relationship type with no obvious next step | "What would a good outcome look like for you from this meeting?" |
| Internal context | Meeting is high-stakes (NEGOTIATION/CLOSE) and term sheet not found in Drive | "Is there a term sheet or open points list I should know about? If so, can you paste the key open items?" |
| Referral/intro source | FIRST_CONTACT with no intro context in email | "How is this meeting happening — warm intro, cold outreach, event?" |

**Format for the question block:**
Keep it conversational and specific to what was found. Never list all possible questions
as a template — only ask what's actually missing for this specific meeting.

Good example:
> "Got most of what I need. Two things that would sharpen the brief:
> 1. The invite just says 'catch-up' — is there anything specific you're hoping to cover or advance?
> 2. I found some email history from 2024 but nothing recent — has there been any conversation since then that I should factor in?"

Bad example (never do this):
> "Before I proceed, could you tell me: (1) the agenda, (2) the deal stage, (3) your relationship history, (4) your objective, (5) the attendee's background..."

### Phase 4 — Contextual enrichment (after user responds)

Take the user's answers and fold them directly into the brief as **verified context** (not inferences).
Tag them as `[User-provided]` in the confidence register so the reader knows the source.

If the user's answer changes the meeting classification (e.g. they reveal it's actually a PITCH
not a DISCOVERY), rerun Step 2 with the new information before writing.

If the user says "just go ahead, I don't have more context" — proceed immediately.
Don't ask again. Use what you have, note the gaps in Section 9.

### Phase 5 — Progress signal before writing

Once all questions are answered (or skipped), give a one-line signal before generating:
> "All set. Generating your [TYPE] brief for [Name / Company] now."

Then generate the full brief without further interruption.

---

## Step 2 — Meeting classification (the most important step)

The entire structure and tone of the brief depends on correct classification.
Read the calendar invite (title, description, attendees, organiser) AND cross-reference
Attio + Asana before assigning a type.

### 2A — Meeting type

**Deal-track types:**

| Code | Signals | Primary intent |
|---|---|---|
| `FIRST_CONTACT` | No Attio/email history, new intro, cold outreach | Establish credibility, qualify fit |
| `DISCOVERY` | Early Attio stage, exploratory agenda, limited history | Understand their world, find the angle |
| `PITCH` | Deck/proposal in Drive, "presentation" in title, qualified interest | Land the narrative, handle objections |
| `DILIGENCE` | "DD", "data room", "review", term sheet in Drive | Defend numbers, manage process |
| `NEGOTIATION` | Term sheet or NDA pending, "terms", "pricing", "structure" | Advance to close, handle friction |
| `CLOSING` | "Signing", "execution", "mandate", docs circulating | Eliminate final blockers |
| `RELATIONSHIP` | No open deal, periodic check-in, "catch up", "coffee" | Deepen trust, surface new needs |
| `PORTFOLIO_REVIEW` | Post-mandate, "update", "reporting", existing client | Demonstrate value, retain mandate |

**Strategic types:**

| Code | Signals | Primary intent |
|---|---|---|
| `PARTNER_INTRO` | Co-investor, co-advisor, intermediary, referral source | Assess alignment, explore deal flow sharing |
| `INVESTOR_MEETING` | LP, family office, institutional investor → BugleRock is selling | Raise capital or maintain LP |
| `REGULATORY` | MAS, legal, compliance, auditor | Manage risk, document positions |
| `MEDIA_PRESS` | Journalist, podcast, publication | Narrative control, soundbite readiness |
| `TALENT` | Candidate, recruiter | Culture and capability assessment |

Assign **1 primary type** + up to **2 secondary tags** (e.g. DISCOVERY + PARTNER_INTRO).

### 2B — Deal stage (for deal-track meetings)

Pull from Attio + Asana + Drive email to score:

```
Stage 0 — Cold: no prior contact, no history found anywhere
Stage 1 — Introduced: first conversation had, interest unconfirmed
Stage 2 — Qualified: interest confirmed, scope being discussed
Stage 3 — Proposed: IC note / proposal / deck sent
Stage 4 — Negotiating: term sheet / pricing in discussion
Stage 5 — Executing: mandate signed, in delivery
```

**Recency modifier** (note alongside stage):
`ACTIVE` = last touchpoint < 14 days | `WARM` = 14–45 days | `COOLING` = 45–90 days | `LAPSED` = > 90 days

**Combined output of Step 2:**
```
Meeting type:   [e.g. PITCH]
Secondary tags: [e.g. + PARTNER_INTRO]
Deal stage:     [e.g. Stage 3 — Proposed]
Recency:        [e.g. WARM — last contact 22 days ago]
Brief format:   [auto-selected from references/brief-formats.md]
```

---

## Step 3 — Data ingestion (run ALL sub-steps in parallel)

### 3A — The People (per external attendee)

**Identity and background:**
```
web_search: "[Full Name] [Company] LinkedIn"
web_search: "[Full Name] background career [Company]"
web_search: "[Full Name] interview OR podcast OR article OR keynote"
```
Extract: career arc (distilled, not listed), education if notable, what they're known for.
**Extract and record the LinkedIn profile URL** — include it directly in Section 1.

**Recent signals and public persona:**
```
web_search: "[Full Name] 2025 2026"
web_search: "[Full Name] Twitter OR X.com"
web_search: "[Full Name] blog OR Substack OR Medium OR newsletter"
```
Extract: recent public statements, expressed opinions, interests, anything that reveals
what they care about right now — this feeds talking point personalisation and Watch-Outs.

**Power map** (if 2+ attendees):
Classify each attendee's likely role in the room:
- `DECISION_MAKER` — signs off, has budget or board authority
- `CHAMPION` — wants this to happen, internal advocate
- `EVALUATOR` — assessing technical / commercial fit
- `GATEKEEPER` — controls access, may be resistant
- `OBSERVER` — present but not a decision factor
If unknown, mark as `UNKNOWN` and note what signals suggest.

### 3B — The Company / Organisation

**Fundamentals:**
```
web_search: "[Company Name] overview business model sector"
web_search: "[Company Name] funding investors valuation"
web_search: "[Company Name] employees revenue scale"
web_fetch: [Company website — establish URL from web search, fetch homepage and About/Team pages]
web_search: "[Company Name] LinkedIn company page"
web_fetch: [LinkedIn company page URL if found]
```
**Record both the company website URL AND the LinkedIn company page URL** — include both directly in Section 2.
LinkedIn company page: extract current headcount, recent posts/announcements, and any current openings
that signal strategic direction (e.g. hiring a CFO signals growth or exit prep).

**PE / VC / IB portfolio — MANDATORY deep search:**
Classify the company type first:
- PE fund, VC fund, family office, or investment bank → signals: "capital", "ventures", "partners",
  "investments", "fund", "equity", "asset management" in name; "portfolio" on website.

**If PE / VC / IB: this is NON-NEGOTIABLE — always run, never skip, never truncate to 5–8 names.**
```
web_fetch: [Company website /portfolio page]
web_fetch: [Company website /investments page]
web_search: "[Company Name] complete portfolio companies list"
web_search: "[Company Name] all portfolio investments"
web_search: "[Company Name] fund portfolio site:[company domain]"
web_search: "[Company Name] investments deals 2023 2024 2025 2026"
web_search: "[Company Name] notable exits acquisitions"
```
Extract the **full portfolio** — not a curated sample. Include:
- All identifiable portfolio companies with sector and stage
- Notable exits (IPOs, trade sales, write-offs)
- Stage preference across the portfolio (seed / growth / late-stage / buyout)
- Sector thesis (what do they consistently back?)
- Geography concentration
- Fund size and vintage if available
- Any portfolio overlap with BugleRock's client base or prospects_IB pipeline

**Flag explicitly** if the portfolio could not be fully sourced:
`[Portfolio: partial — [N] companies identified, full list may not be public]`
Do not present an incomplete list as complete.

**Traxcn or research report from Drive (always check):**
```
Google Drive: search fullText contains "[Company Name]", name contains
"Traxcn" OR "report" OR "research" OR "profile" OR "company brief"
```
If found, extract: sector, stage, financials, cap table, investors, valuation, key metrics.
Traxcn data takes priority over web estimates. Flag as `[Traxcn verified]`.

**Recent news (last 90 days):**
```
web_search: "[Company Name] news 2026"
web_search: "[Company Name] funding OR acquisition OR expansion OR layoffs OR regulatory OR lawsuit"
```
Flag anything materially significant — this often feeds Watch-Outs directly.

**Competitive landscape (for PITCH / DILIGENCE):**
```
web_search: "[Company Name] competitors"
web_search: "[Company sector] advisor OR investment bank OR deal 2026"
```

**Sector macro (for FIRST_CONTACT / PITCH):**
```
web_search: "[sector] market outlook 2026"
web_search: "[sector] M&A deal flow investment 2026"
```

### 3C — Your relationship history

**Gmail — correspondence:**
```
Gmail: search "[attendee email]" → read top 10 most recent threads
Gmail: search "[company name] transcript OR summary OR notes OR recap OR meeting"
Gmail: search "[company name] proposal OR mandate OR NDA OR term sheet OR deck"
```
Extract: first contact date, last contact, topics discussed, tone, commitments made.

**Attio CRM — authoritative source:**
```
Attio: search companies "[company name]"
Attio: search people "[attendee name]" OR email "[attendee email]"
Attio: list notes for company/person record
Attio: get deal stage and opportunity record
```
**Attio always overrides email-inferred stage.**
See `references/attio-query-patterns.md` for query patterns and interpretation logic.

**Google Drive — documents:**
```
Drive: search fullText contains "[company name]", type = document OR presentation
Drive: search name contains "[company name]", includes "NDA" OR "proposal" OR "deck"
       OR "IC note" OR "term sheet" OR "mandate" OR "IC gating"
```
List all found files with last-modified date. Note which is most recent and most material.

**Staleness protocol — apply to every Drive document found:**

Documents **older than 6 months**: flag inline wherever their data is used in the brief:
→ Append `[⚠️ Source dated [Month Year] — verify current]` directly after any fact drawn from it.
→ Do not suppress the data — surface it with the flag so the reader can judge.

Documents **older than 9 months**: flag AND validate before using:
→ Run a web search to check whether the key facts are still current:
  ```
  web_search: "[company name] [specific fact to validate] 2026"
  ```
  Examples: validate funding stage, leadership, headcount, product status.
→ If web search **confirms** the fact → mark as `✅ Web-validated [Month Year]`
→ If web search **contradicts** the fact → do not use the stale data; use the web-sourced update instead and note: `[Updated: Drive doc superseded by web search — original dated [Month Year]]`
→ If web search **cannot confirm either way** → use the Drive data but mark: `[⚠️ Unvalidated — Drive doc [Month Year], could not confirm via web]`
→ If the document is a **Traxcn report** older than 9 months: always flag as stale and always run validation. Traxcn financials shift materially in under a year.

### 3D — Asana pipeline intelligence

**Always check `prospects_IB` regardless of meeting type.**
Cross-reference is non-negotiable — connections that aren't obvious from the invite often exist.

```
Asana: get_projects → locate 'prospects_IB'
Asana: get_tasks, project = prospects_IB, completed = false
  → Scan task names, descriptions, comments for [company name] OR [attendee name]
  → Also scan for sector/geography matches

Asana: search_objects "[company name]" across all projects
Asana: search_objects "[attendee name]" across all projects
Asana: get_my_tasks, filter for [company name] OR [attendee name]
```

**Classify the match:**
- `DIRECT MATCH` — task explicitly names this company → active prospect
- `NETWORK MATCH` — task mentions this person as contact/referral → they're in the deal network
- `SECTOR MATCH` — no company match but same sector → indirect relevance
- `NO MATCH` — not found → state clearly, don't fabricate

**For each matched task:** extract name, due date, assignee, status, last comment.
Flag overdue tasks ⚠️ — these require explanation or action before/during the meeting.

**BRCS strategy fit** (if applicable):
Does this company or sector map to an active BRCS strategy?
IXO · VOLHAWK · RAMP D+ · QLQSM · AD+ ensemble · QCA ensemble
If yes, note which strategy and what the deal opportunity would look like.

---

## Step 4 — Intelligence synthesis

### 4A — Opportunity scoring

Rate on three axes before writing:

```
DEAL POTENTIAL     High / Medium / Low / Unknown
  → Could this lead to a fee-generating mandate in < 12 months?

RELATIONSHIP VALUE  High / Medium / Low
  → Does this person/company have strategic value beyond the immediate deal?
  → (Referral network, LP potential, co-investment partner, market access)

URGENCY             High / Medium / Low
  → Is there a live process, competitive risk, or time-bound window?
```

This score calibrates how direct the talking points are and how hard the CTA is.
- H/H/H → go direct, strong CTA, names specific deliverable
- H/H/L → nurture mode, plant the seed, no hard sell
- Unknown → discovery mode, ask more than tell

### 4B — The Angle (the creative heart of the brief)

This is the single most important synthesis output. Before writing the brief,
identify THE ANGLE — the one insight, position, or connection that, if surfaced well,
shifts the meeting in your favour.

**The Angle is always specific. It is never "establish credibility" or "discuss our services."**

**Angle archetypes to consider:**

`THE INSIGHT ANGLE`
You know something about their sector, a comparable deal, a regulatory shift, or a competitive
move that they don't expect you to know. Surfacing it earns instant credibility.
→ "The fact that [Comp X] just closed at 8x despite market softness tells us the window is open
   if they move in Q3."

`THE MIRROR ANGLE`
Reflect their own stated priority back with a concrete solution.
Find a quote, post, interview, or statement where they articulated a problem — then show up
with the answer before they ask.
→ "You said in the TechIn Asia panel that finding an advisor who understood both the SEA LP
   dynamics and the US structure was the hardest part. That's the exact gap we're designed for."

`THE NETWORK ANGLE`
You have a connection, a co-investor, a prior client, or a reference that is directly relevant
to their current situation and that they don't know you have.
→ "We closed an almost identical mandate for [reference company] last year — that founder
   is happy to take a call."

`THE TIMING ANGLE`
Something has just happened (a funding round, a competitor event, a regulatory change,
a market move) that creates an urgency window they may not have fully processed yet.
→ "Their Series B announcement last week likely means they need to start thinking about
   liquidity options for early investors — that's a mandate that typically moves fast."

`THE GAP ANGLE`
From your research, you've spotted a structural gap in their story — an underfunded round,
an absent advisor on a live process, a stalled mandate, a missing piece.
→ "Every comparable deal in this sector had a cross-border structuring advisor.
   Their current setup doesn't — that's the opening."

`THE CONTRARIAN ANGLE`
You hold a well-reasoned view that differs from conventional wisdom about their sector or
situation. A thoughtful contrarian perspective makes people lean in.
→ "Everyone is telling them to wait for market conditions to improve.
   The data suggests that's the wrong call — and I can show them why."

`THE SOCIAL PROOF ANGLE`
Remove their perceived risk by referencing a comparable mandate, a similar profile,
or a reference that maps closely to their situation.
→ "We ran an almost identical process for [X] 18 months ago under similar market conditions —
   here's what we learned and how we'd do it differently for them."

**State the angle in one sentence.** Write it at the top of the synthesis block.
Every talking point must serve this angle. Cut any point that doesn't.

**No strong angle found — mandatory declaration:**
If all six signal searches return thin, ambiguous, or generic data and no angle reaches
Level 3 quality (see `references/angle-playbook.md`), do not manufacture a weak angle.
Instead, declare it explicitly in the Quick Situational Strip and in Section 5:

> `THE ANGLE: No strong angle identified — limited public data / no recent signals.`
> `Approach: Discovery mode — ask more than tell. See talking points.`

Then set the talking points entirely as open questions (see angle-playbook.md — Discovery Angle).
Do not write a Level 1 or Level 2 angle dressed up as something sharper.
A declared discovery stance is more credible than a generic pitch framed as insight.

### 4C — Objection pre-loading

Anticipate 2–3 objections based on meeting type and deal stage.
For each: state the likely objection + a one-line reframe.

Common objections by stage:
- Stage 0–1: "Who are you?" / "We're not looking" / "We work with [bigger name]"
- Stage 2: "How is this different?" / "We're too early for this"
- Stage 3: "Fees are too high" / "We've had bad advisor experiences" / "Timeline too long"
- Stage 4: "Our board needs to approve" / "The structure is too complex" / "Other party wants X"
- Relationship: "Nothing specific to discuss" → use as discovery opportunity

### 4D — Intelligence Confidence Assessment (mandatory for all runs; critical for scheduled)

Before writing a single section, build the confidence register for this brief.
In a scheduled run there is no human to ask — every gap, assumption, and inference
must be declared explicitly so the reader knows exactly what to trust.

**For each data source, record one of four statuses:**

```
✅ VERIFIED       — data found from an external source, used directly
💬 USER-PROVIDED  — supplied by the user in chat; treated as verified for brief purposes
⚠️  INFERRED       — data absent or partial; conclusion drawn from indirect signals; reasoning stated
❌ GAP             — source returned nothing or was unavailable; content in this area is absent
```

**Build the register across all nine data dimensions:**

| Dimension | Status | Notes |
|---|---|---|
| Attendee identity & background | ✅ / ⚠️ / ❌ | Source: LinkedIn / web / none |
| Attendee recent signals | ✅ / ⚠️ / ❌ | Source: web search / Twitter / none |
| Company fundamentals | ✅ / ⚠️ / ❌ | Source: web / Traxcn / none |
| Company Traxcn report | ✅ / ⚠️ / ❌ | File found in Drive / not found |
| Prior email history | ✅ / ⚠️ / ❌ | N threads found / none found |
| Attio CRM record | ✅ / ⚠️ / ❌ | Record found / not found / unavailable |
| Drive documents | ✅ / ⚠️ / ❌ | N files found / none found |
| Asana tasks | ✅ / ⚠️ / ❌ | N tasks found / none found |
| Meeting agenda | ✅ / ⚠️ / ❌ | From invite / inferred from context / blank |

**Inference rules — apply throughout the brief:**

Every inference must be written in a way that is unambiguous to the reader:
- Prefix inferences with: *"Based on [signal], it appears likely that..."*
- Never write an inferred fact in the same declarative style as a verified fact
- If a section is substantially built on inferences (> 50% inferred), open that section
  with: *"Note: Limited verified data for this section — content is largely inferred."*

**Assumptions register:**
List any assumptions made about the meeting itself that affect the brief:
- "Assumed this is a first contact — no Attio/email history found" [state basis]
- "Assumed attendee is the decision-maker — inferred from title and invite structure"
- "Meeting type classified as PITCH — based on Drive deck dated [X] and invite title"
- "Deal stage assessed as Stage 2 — Attio record absent; inferred from email tone"

This register becomes **Section 9 — Brief Confidence** in the output document (see Step 5).

---

## Step 5 — Write the brief

Read `references/brief-formats.md` to select the exact section set for this meeting type.

### Always-present: Header block (not a section — rendered in the HTML header area)

The HTML header contains:
- BugleRock logo lockup (top left)
- Meeting date, time, duration, format (top right)
- Confidence badge: HIGH ✅ / MEDIUM ⚠️ / LOW ❌ — colour-coded pill, always visible
- Attendee name (large, Georgia serif), role line, company
- **Intro badge** — a small pill below the name showing how this meeting came about:
  e.g. `⚡ Via Boardy — 16 Apr 2026` or `🤝 Via Rajan Pillai (Temasek) — 14 Apr 2026`
  Pull the intro source and date from Step 3C (Gmail intro thread).
  If cold outreach: `📧 Cold outreach — [date]`
  If calendar-initiated with no intro: omit the badge.

**The Quick Reference Card strip is removed.** It repeated the angle, the CTA, and the
watch-out — all of which have their own dedicated sections. The header + body structure
is sufficient. Do not render a strip.

### Always-present sections (in all brief formats)

**Intro Context block** *(FIRST_CONTACT and DISCOVERY only — omit for all repeat meetings)*
3–4 bullets. Pull from Gmail intro thread + calendar.
- How the intro happened: source, mechanism (Boardy, referral, cold outreach, event)
- Date of intro and who initiated
- How quickly they responded — signals interest level ("Responded within 20 mins" vs "Took 4 days")
- How the meeting was booked and by whom
- One-line warmth read: cold / cold-warm / warm

If no intro trail found: "Cold calendar meeting — no intro context found."
**For PITCH, NEGOTIATION, RELATIONSHIP, PORTFOLIO_REVIEW, and all repeat-meeting types:
omit this block entirely.** Section 3 (Our History) covers context for established relationships.

**Section 1 — Who Are They**
Present the career as a **visual card grid** — one card per role, current role(s) first.
Each card contains: firm name (bold), title, period (dates + tenure), one-line significance note
explaining why *that role matters for this meeting* — not a job description.
Education as a compact final card: institution, degree, year.
Do NOT write a prose career arc. The grid communicates the same thing faster and
each card's significance note does the synthesis work.

After the grid:
- LinkedIn (personal): [URL]
- One human detail: what they care about beyond the job (from public signals)
- Operating style: decisive vs deliberate, data or gut, formal or casual (inferred, tagged [i])
- Power map (if 2+ attendees): role classification per person

**Section 2A — The Angle** *(dedicated named section, not a Strip field)*
This is the section that earns its place closest to the front. It contains:
- A named highlight box with the angle stated in 1–2 sentences
- Signal tags if applicable (e.g. `ICML Accepted` · `Fund II First Close` · `Rolling SAFE`)
- A **BugleRock angle** call-out: specifically how this signal maps to a BugleRock opportunity
  (customer, co-investor, referral, mandate, LP)
If no strong angle was found: render this section as "Discovery Mode" with the
key question to ask instead of an insight to deploy.
This section replaces the angle field in the (removed) Quick Strip.
The angle does NOT repeat in Section 5 (pipeline map) — Section 5 only shows pipeline match
and next step.

**Section 2 — The Company**
- What they do + sector + geography (1–2 lines max)
- Website: [URL] · LinkedIn: [company page URL]
- Scale: funding, headcount, revenue/ARR if available
- Key investors / backers
- **Traxcn snapshot panel** (if report found in Drive): see html-template.html spec
- **Full portfolio** (if PE/VC/IB): grouped by active / exited — see Step 3B
- Recent news (last 90 days) — material items only
- Strategic insight: one sentence — their biggest challenge or ambition right now

**Section 3 — Our History**
- First contact: when + how (1 line)
- Relationship timeline: date-stamped bullets (Attio primary, Gmail backup)
- Documents exchanged with dates
- Attio stage + recency + warmth (1 line)
- **If LAPSED (> 90 days) + Stage 2+:** prominent flag at top of section:
  `⚠️ DORMANT — last contact [X days] ago. Acknowledge the gap before advancing.`

**Omit Section 3 entirely for FIRST_CONTACT** with no prior history — it adds nothing.
The Intro Context block already covers first-meeting context. An empty history section
padded with "no prior engagement found" is noise. Leave it out.

**Section 4 — Open Commitments & Tasks**
- All open Asana tasks linked to this company/person
- Overdue ⚠️ flagged prominently
- Any promise from a prior meeting not yet in Asana but visible in email/Attio notes
- **If none:** one line — "No open commitments." Do not pad with explanation.

**Section 5 — Deal & Opportunity Map**
- prospects_IB match type (DIRECT / NETWORK / SECTOR / NONE)
- Opportunity score (Deal Potential / Relationship Value / Urgency)
- Recommended next step post-meeting (specific action — not "follow up")
*The Angle lives in Section 2A. Do not restate it here — only pipeline match and next step.*

**Section 6 — Talking Points**
4–5 points maximum. Each formatted as:

```
[BOLD LABEL — what this point accomplishes]
[2–4 sentences: the substance of what to say OR ask, written in first person,
ready to use in the room. Include the suggested opening line or question verbatim.]
```

Rule: ≥1 point must be a question — curiosity beats monologue.
Rule: Last point is always the CTA — a specific, named next step.
Rule: No point may repeat a fact already stated in Sections 1–5. New framing or cut it.
Rule: Do not add a "why this matters" annotation. If the point needs explaining, sharpen it.

The format mirrors the reference brief: numbered, bold label on its own line, then the full
wording below. The reader should be able to read a talking point and use it without editing.

**Section 7 — Watch-Outs**
Specific, not generic. Three sources — all checked:
- **Past conversations** (Gmail + Attio): open commitments, prior tensions, stalled deals
- **Attendee profile signals** (LinkedIn, public signals): inferred sensitivities, competing loyalties
- **Company situation** (recent news, stage): anything they may be sensitive about

Tag each item: [Past conversation] / [Profile inference] / [Company situation]
If nothing material: one line — "No material watch-outs identified."

**No platitudes.** "Don't over-sell" is not a watch-out — it's obvious advice.
"Don't mention competitor X by name — they have a standing relationship" is a watch-out.
Every item must be specific to this person, this company, or this history.
Generic caution belongs nowhere in the brief.

**Section 8 — Desired Outcome**
A single flowing paragraph — not a labelled form. Format:

*"Leave this meeting with clarity on [specific question 1] and [specific question 2].
If [condition], then [next action]. Fallback: [one line — what's still a win]."*

The paragraph should read as a natural, human-voiced intent statement.
The reader should be able to absorb it in 10 seconds.
Do not use PRIMARY / FALLBACK / SUCCESS SIGNAL labels — write prose.

**Section 9 — Brief Confidence** *(always present; especially critical in scheduled runs)*

This section surfaces the intelligence register built in Step 4D.
It is the last section — never omit it, never bury it.
The reader must know what to trust before they walk into the room.

Format:

```
CONFIDENCE SUMMARY
Overall confidence: HIGH / MEDIUM / LOW
  HIGH   = 7–9 dimensions verified or user-provided
  MEDIUM = 4–6 dimensions verified/user-provided, gaps noted
  LOW    = < 4 dimensions verified — treat brief as a starting point, not ground truth

DATA SOURCE STATUS
[Table from Step 4D — one row per dimension, status + brief note]
Statuses: ✅ Verified · 💬 User-provided · ⚠️ Inferred · ❌ Gap

ASSUMPTIONS MADE
[Numbered list — each assumption stated plainly with its basis]
  1. Meeting type assumed [X] — because [calendar signal / Attio stage / etc.]
  2. Attendee assumed to be decision-maker — inferred from [title / invite structure]
  3. Deal stage assessed as Stage [N] — [source or "Attio absent, inferred from email tone"]
  ...

INFERENCES IN THIS BRIEF
[List only inferences that appear in the brief body — do not list every possible unknown]
  - [Section N]: "[The inferred statement]" — based on [signal]
  - [Section N]: "[The inferred statement]" — based on [signal]

GAPS — NOT COVERED
[List sources that returned nothing — be specific]
  - No Attio record found for [company] — relationship history drawn from Gmail only
  - No Traxcn report found — company financials are web-sourced estimates only
  - Attendee LinkedIn not located — background based on company website bio only
  - Calendar invite has no agenda text — meeting purpose inferred from [context]
  - [If all sources populated: "No material gaps — all nine dimensions have data"]
```

**Tone for this section:** factual, neutral, zero editorialising.
State what is known and what isn't. The reader will calibrate their own confidence.
Do not reassure ("the brief is still useful despite these gaps") — just state the facts.

### Format-adaptive sections

These are added based on meeting type (defined in `references/brief-formats.md`):

| Section | Added for |
|---|---|
| First-meeting playbook (opening frame + one key question) | FIRST_CONTACT |
| Sector macro brief (2–3 paras on the industry moment) | FIRST_CONTACT, PITCH |
| Competitive intelligence (who else are they talking to?) | PITCH, DILIGENCE |
| Term sheet / open points summary | NEGOTIATION, CLOSE, DILIGENCE |
| Portfolio review talking points | PORTFOLIO_REVIEW |
| Referral and network map | RELATIONSHIP, PARTNER_INTRO |
| LP narrative (pitch BugleRock as fund/platform) | INVESTOR_MEETING |
| Media prep (key messages + no-go zones) | MEDIA_PRESS |

---

## Step 6 — Format, file, and deliver

### Output

Render as branded HTML using `references/html-template.html`.
Apply meeting type badge colour per `references/brief-formats.md`.

**File naming:** `[YYYY-MM-DD]_Brief_[CompanyName]_[HHMMtz].html`
Example: `2026-04-21_Brief_AcmeCorp_1400SGT.html`

**Save to Drive:**
```
HARDCODED RULE — non-negotiable:
Save to: /Meeting Briefs/[YYYY-MM-DD]/ in the invoking user's personal Drive ONLY.
NEVER save to a shared Drive, team Drive, or any folder shared with external parties.
Before saving, verify the target folder is not shared. If it is shared, create a new
unshared folder at /Meeting Briefs/[YYYY-MM-DD]/ and save there instead.
```

### Email

```
HARDCODED RULE — non-negotiable:
Recipient: ALWAYS the invoking user's own email address ONLY.
NEVER add any other recipient — not Shyam, not Nikhil, not any team member.
Each banker's brief is for their eyes only. The user may forward manually if they choose.

Gmail: create_draft (NEVER send automatically — always draft for human review)
To: [invoking user's authenticated email — fetched in Step 0, not typed or inferred]
Subject: "📋 Brief — [Meeting Type Badge] [Company] | [Time]"
Body:
  Line 1: One sentence on who they are
  Line 2: THE ANGLE
  Line 3: One watch-out
  Line 4: Confidence level — e.g. "Brief confidence: MEDIUM — no Attio record; stage inferred"
          If HIGH: omit this line (no news is good news)
          If MEDIUM or LOW: always include, state the specific gap in plain language
  Line 5: Drive link to full brief
```

**Confidence line examples:**
- `Brief confidence: MEDIUM — no prior email history found; relationship context is limited`
- `Brief confidence: LOW — attendee not found online, no Attio record, invite has no agenda`
- `Brief confidence: MEDIUM — Traxcn report absent; company financials are web estimates only`

### In-chat confirmation

Single-meeting:
> "Brief ready: **[TYPE] [Company Name]** at [Time]. Confidence: [HIGH ✅/MEDIUM ⚠️/LOW ❌].
> The angle: [one sentence — or 'Discovery mode — no strong angle identified'].
> Saved to Drive + email drafted — review before sending."

**Stale relationship flag (4e):** If recency modifier is LAPSED (> 90 days since last contact)
AND deal stage is Stage 2 or above, append to the in-chat confirmation:
> "⚠️ Note: Last contact was [X days] ago — this relationship has been dormant.
> Consider acknowledging the gap before advancing the agenda."

**Post-meeting task prompt (4d):** After delivering the brief in chat, always append:
> "After the meeting, let me know if you'd like me to log follow-up tasks in Asana."
Do not create tasks automatically — wait for explicit post-meeting instruction.
When the user responds, create tasks in the relevant Asana project (prospects_IB or equivalent)
with: task name, due date (default 3 business days if not specified), assignee (invoking user).

Batch (scheduled run):
> "[N] briefs ready for [Date]:
> · [Time] [Company] — [HIGH ✅ / MEDIUM ⚠️ / LOW ❌ / DUAL-SCENARIO 🔀]
> · [Time] [Company] — [HIGH ✅ / MEDIUM ⚠️ / LOW ❌ / DUAL-SCENARIO 🔀]
> All saved to your personal Drive. Email drafts prepared — to your address only.
> LOW-confidence briefs need a manual check before the meeting."

---

## Step 7 — Quality gates

Before outputting, verify:

- [ ] User identity established — brief scoped to invoking user
- [ ] Meeting correctly classified — type + stage + recency; dual-scenario if ambiguous
- [ ] **Quick Reference Card strip NOT rendered** — removed; header + body structure is sufficient
- [ ] **Intro Context block present** — how the meeting came about, 3–4 bullets
- [ ] **Section 2A (The Angle) rendered as dedicated named section** — not buried in Strip or S5
- [ ] **Career grid used in Section 1** — card per role with significance note; no prose arc
- [ ] **Talking points include suggested opening words** — full sentences, first person, usable as-is
- [ ] **Desired Outcome is a prose paragraph** — not a labelled form
- [ ] THE ANGLE is specific — or declared "Discovery mode" explicitly
- [ ] Attio checked — result in Section 3, or "unavailable" noted
- [ ] prospects_IB scanned — result in Section 5 (pipeline match only — no angle restatement)
- [ ] All open Asana tasks in Section 4
- [ ] **LinkedIn URL (personal) present** for each external attendee in Section 1
- [ ] **Company website URL AND LinkedIn company page URL** present in Section 2
- [ ] **PE/VC/IB: full portfolio researched** — not a sample; partial flag if needed
- [ ] **Tracxn snapshot panel rendered** if report found in Drive
- [ ] **Drive docs > 6 months** flagged inline
- [ ] **Drive docs > 9 months** validated via web search; outcome noted inline
- [ ] **Stale data (> 9 months): only high-confidence insights used**
- [ ] **LAPSED + Stage 2+ relationships** flagged in Section 3 body AND in-chat
- [ ] **Email recipient = invoking user's own address only** — hardcoded
- [ ] **Drive save = personal Drive only** — shared Drive verified absent
- [ ] **Zero repetition** — scan every section: if a fact appears twice, cut the second instance
- [ ] **No basic or obvious information** — every line must add something non-obvious
- [ ] Section 9 (Brief Confidence) present — all 9 dimensions have a status
- [ ] Confidence badge in header — HIGH ✅ / MEDIUM ⚠️ / LOW ❌
- [ ] Every inference phrased as inference — no declarative statements for inferred facts
- [ ] Every gap named explicitly
- [ ] Chat run: interactive questioning completed (Step 1B)
- [ ] Scheduled run: no questions; gaps in Section 9 only
- [ ] File named, saved to personal Drive, email drafted to self only

---

## Core philosophy

**The reader is a CXO or MD.** They have read thousands of briefs. They will immediately
feel the difference between a brief that respects their intelligence and one that pads
for completeness. The standard is: every line earns its place or it gets cut.

**Three non-negotiable rules:**

1. **No repeated information.** If a fact appears in the Intro Context block, it does not
   appear in Section 3. If it's in Section 2A (The Angle), it does not appear in Section 5.
   If it's in Section 1, it is not in the talking points. One mention, one place.

2. **No basic or obvious information.** The reader already knows what an investment bank does.
   They already know what Singapore is. Every line must add something non-obvious — a specific
   signal, a concrete inference, a named detail. If removing a sentence changes nothing, cut it.

3. **No minute-by-minute agendas.** The reader runs meetings for a living. The brief
   tells them what to know and what to say — not when. Sequencing is their call.

A great brief gives the reader an unfair advantage walking into the meeting. That is the standard.

---

## References

- `references/brief-formats.md` — Exact section set and ordering for each meeting type
- `references/html-template.html` — Branded HTML/CSS output shell
- `references/attio-query-patterns.md` — Attio query guide with interpretation logic
- `references/angle-playbook.md` — Expanded guide to identifying and landing the angle

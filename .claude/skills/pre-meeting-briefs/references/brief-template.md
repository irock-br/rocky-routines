# Brief Template — Section-by-Section Content Guide

This file is the authoritative content guide for each section of the Pre-Meeting Brief.
Claude reads this when writing Section 1–9 content to ensure consistency and quality.

---

## Section 1 — Who (Background)

**Purpose:** Give Shyam a crisp mental model of the person before the meeting.

**Include:**
- Full name + current title + company (one line)
- Career arc in 2–3 sentences: where they came from, what they've built, what they're known for
- Notable credentials or institutions if genuinely relevant (not a CV paste)
- One "human angle" if findable: what they publicly care about, a recent post, a known interest

**Avoid:**
- Copying a LinkedIn summary verbatim
- Listing every job title chronologically
- Padding with generic statements like "seasoned professional with X years of experience"

**Example format:**
> **Priya Sharma** — Managing Director, Southeast Asia, Temasek Holdings
>
> Priya spent 12 years at Goldman Sachs in Hong Kong and Singapore before joining Temasek in 2019, where she now leads direct investments in fintech and climate infrastructure across SEA. She is the author of two co-authored papers on blended finance and is an active speaker at the MAS-organised events. Recent LinkedIn posts suggest a strong interest in impact measurement frameworks.

---

## Section 2 — The Company

**Purpose:** Ensure Shyam is never caught not knowing basic facts about the counterparty's business.

**Include:**
- What the company does (one line, no jargon)
- Sector + sub-sector + geography of operations
- Stage + scale: headcount range, revenue range or ARR if known, funding stage
- Key investors / backers if notable
- Any recent news in the last 90 days (fundraise, hire, product launch, regulatory event)

**If Traxcn report is available:** pull headline metrics directly from there and cite it.
**If no structured data:** rely on web search and clearly mark as "per public sources."

**Flag:** If the company appears to be in distress, facing regulatory issues, or in a known dispute — surface this in Section 7 (Watch-Outs), not here.

---

## Section 3 — Our History

**Purpose:** Prevent Shyam from accidentally re-introducing himself or re-pitching something already pitched.

**Sub-sections:**

### 3A — First contact
How and when did BugleRock first engage with this person/company?
Source: Attio (authoritative) → Gmail (corroborating) → Drive docs (evidence)

### 3B — Prior conversations
2–4 bullet points summarising what was discussed in prior touchpoints.
Format: `[Date] — [Topic/outcome in one line]`

### 3C — Documents exchanged
List any NDA, proposal, IC Note, term sheet, or deck shared — with date.

### 3D — Relationship assessment
- Attio stage (if set): e.g. "Qualified Lead", "Proposal Sent", "Under DD"
- Warmth: Warm / Neutral / Cold / Unknown — based on email tone + recency
- Who owns the relationship at BugleRock?

---

## Section 4 — Open Action Items

**Purpose:** Ensure nothing falls through the cracks. If BugleRock committed to something, Shyam should walk in knowing whether it was done.

**Format:**
```
[ ] Task name — Due: [date] — Assigned: [name] — Status: [open/overdue]
[⚠️ OVERDUE] Task name — Due: [date] — Assigned: [name]
[✓] Task name — Completed [date]
```

If no tasks found: "No open Asana tasks linked to [Company Name]."

Always include a line noting which Asana project the tasks were found in.

---

## Section 5 — Deal Pipeline Match

**Purpose:** Connect the meeting to BugleRock's commercial pipeline so Shyam can advance a deal if the opportunity exists.

**Logic tree:**

1. Is there an active task or project in `prospects_IB` matching this company? → Yes: describe it. No: proceed.
2. Is there an IC Note or BRCS strategy deck in Drive mentioning this company? → Yes: summarise. No: proceed.
3. Is there an Attio opportunity record? → Yes: pull stage and next step. No: proceed.
4. Could this meeting open a new deal thread? → Assess based on company stage + BugleRock's mandate areas and state the recommendation.

**BRCS strategy mapping** (use if relevant):
- **IXO** — Index-tracking, long-only, institutional
- **VOLHAWK** — Volatility strategies, options-based
- **RAMP D+** — Multi-asset dynamic allocation
- **QLQSM** — Quantitative long/short
- **AD+ ensemble** — Combined IXO + VOLHAWK
- **QCA ensemble** — Combined RAMP D+ + QLQSM

---

## Section 6 — Agenda & Talking Points

**Purpose:** Arm Shyam with the 3–5 most important things to say or ask.

**Agenda restatement:** Pull from the calendar invite description. If blank, infer from context.

**Talking points format:**
> **1. [Label]** — [One sentence on what to say or ask and why]

**Guidance for writing talking points:**
- Lead with value BugleRock can offer, not a pitch
- At least one talking point should be a question — curiosity builds rapport
- If there's an open action item, include a point to close it
- If there's a deal to advance, include a specific next-step ask
- End with a soft, clear CTA for the follow-up

---

## Section 7 — Watch-Outs

**Purpose:** Prevent Shyam from stepping on a landmine.

**Common watch-out categories:**
- **Open commitment not yet fulfilled** — BugleRock said they'd send X and haven't
- **Past tension** — a deal that fell through, a pricing disagreement, a delayed response
- **Sensitive topic** — something happening at the counterparty's company Shyam shouldn't bring up first (layoffs, litigation, a failed fundraise)
- **Competing relationship** — the attendee is also talking to a BugleRock competitor
- **Personal sensitivity** — inferred from public signals (e.g. they recently left a company)

If nothing material is found: "No notable watch-outs identified."

---

## Section 8 — Desired Outcome

**Purpose:** Shyam should walk in knowing exactly what "winning" this meeting looks like.

**Format:**
> **Primary:** [Specific, concrete outcome — a signed doc, a verbal yes, a referral, a follow-up meeting booked]
>
> **Fallback:** [If primary isn't achievable — at minimum, what should Shyam walk away with?]

---

## Section 9 — Quick Reference Card

**Purpose:** The 60-second scan right before walking into the room. No prose. One line per field.

```
NAME          [Full name], [Title], [Company]
WHY WE'RE MEETING  [One line]
THEY CARE ABOUT    [The counterparty's primary interest or pain point]
OUR ASK TODAY      [Specific CTA for this meeting]
DON'T FORGET       [One critical thing — an open action item, a watch-out, or a personal detail]
```

---

## Quality checklist before outputting

- [ ] All 9 sections present
- [ ] No section padded with filler
- [ ] Attio checked and reflected in Section 3
- [ ] prospects_IB checked and reflected in Section 5
- [ ] Open Asana tasks listed in Section 4
- [ ] Watch-outs are specific, not generic
- [ ] Quick Reference Card is genuinely scannable in 60 seconds
- [ ] File named correctly and saved to Drive path
- [ ] Draft email prepared for shyam@ and nikhil@

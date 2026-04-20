---
name: meeting-intelligence-p1
description: >
  Full meeting intelligence system for iRock/BugleRock investment bankers. Triggers on phrases like "prep my meeting brief", "meeting intelligence for", "brief me on", "prep for my call with". Phase 1 builds comprehensive pre-meeting briefs from 9 sources: Google Calendar, Gmail, Drive, Asana, LinkedIn profiles via Exa.ai, Traxn company reports, industry news, attendee background research, and prior meeting summaries. Output follows extended Mode 5 structure with Traxn and Exa intelligence integrated. 
---

# Meeting Intelligence

Full pre-meeting intelligence pipeline and post-meeting After Action Report (AAR) system for iRock/BugleRock investment banking team. Extends shyam-pa Mode 5 with 9-source data aggregation, Exa.ai attendee profiling, Traxn company data, Bland AI phone-based AAR, and structured snapshot delivery with human approval gate.

## Core Capabilities

**Phase 1 — Pre-Meeting Brief:**
- 9-source intelligence aggregation (Calendar, Gmail, Drive, Asana, LinkedIn/Exa, Traxn, news, attendee research, prior meetings)
- Timezone-aware scheduling and time display (all times in SGT/UTC+8)
- Automated daily delivery at 5am SGT or manual on-demand triggering
- Drive storage and email distribution to deal team

## Required Environment Setup

This skill requires:
- **Exa.ai API key** (EXA_API_KEY environment variable) — Used for LinkedIn profile extraction and attendee intelligence (Steps 6-7)
- **Connected MCP servers:**
  - Google Calendar (calendar events, external attendee detection)
  - Gmail (prior correspondence search)
  - Google Drive (research docs, Traxn reports, snapshot storage)
  - Asana (action item tracking, task creation/updates)
  - Bland AI Actions (optional, for phone-based AAR)

## CRITICAL TIMEZONE RULE

**ALL times displayed and computed in SGT (Singapore Time, UTC+8).**
- Convert UTC times from Calendar/Gmail APIs to SGT before showing to user
- "Today SGT" = current date in Asia/Singapore timezone
- When scheduling checks run: convert current UTC time to SGT first
- All timestamps in briefs and snapshots must show SGT explicitly

---

# PHASE 1 — Pre-Meeting Brief

## Step 1 — Identify the Meeting

### Manual Trigger
When user says: "prep my meeting brief", "meeting intelligence for [company]", "brief me on [meeting]", "prep for my call with [person]", or "meeting prep"

Ask: **"Which meeting? (provide meeting name, company, or time)"**

Wait for user response, then search Calendar for matching event.

### Scheduled Trigger (5am SGT Daily)
First check: convert current UTC time to SGT (add 8 hours).

**Only proceed if SGT time is between 05:00 and 05:30.**
Otherwise stop silently — wrong time window.

Fetch all Calendar events where:
- Start time is today (SGT date, meaning full day 00:00–23:59 SGT when converted to UTC range)
- At least 1 external attendee (email domain NOT @buglerockadvisors.com)
- Not declined by current user
- Not an all-day event

From each qualifying event extract:
- **Title**
- **Start time** (UTC → convert to SGT for display)
- **End time** (UTC → convert to SGT for display)
- **Duration** (in minutes)
- **Attendees:** name, email, company (derived from email domain), response status
- **Description/agenda** (meeting notes field)
- **Video link** (Google Meet, Zoom, Teams URL if present)

### Last-Minute Meeting Detection
If meeting start time is < 60 minutes away (SGT):
- Deliver brief in chat immediately
- Skip Drive save and email steps
- Prioritize speed over documentation

---

## Step 2 — Gmail: Prior Correspondence

For each external attendee email address, search Gmail:

**Query:** `from:{attendee_email} OR to:{attendee_email}`

Fetch last 5 email threads. For each thread, extract and summarize:
- **Date** (convert to SGT)
- **Subject line**
- **Key point** (1-2 sentences: main topic or request)
- **Action taken** (what was agreed, sent, or promised)

Note any prior meeting transcripts or meeting summaries found in thread attachments or body.

**If no correspondence found:** Flag as "No prior correspondence found" in Step 2 of brief output.

---

## Step 3 — Google Drive: Research Documents

Search Google Drive with query:

**Query:** `fullText contains '{company_name}'`

List top 5 results by most recent modified date. For each document extract:
- **Document name**
- **Drive link** (shareable URL)
- **Last modified date** (convert to SGT)

**If no documents found:** Flag as "No research documents found in Drive" in Step 3 of brief output.

---

## Step 4 — Traxn Report

Search Google Drive folder "Traxn Test" with query:

**Query:** `name contains '{company_name}' in folder "Traxn Test"`

**If Traxn report found:**
Extract from PDF:
- **Stage** (Seed, Series A/B/C, Growth, etc.)
- **Founded year**
- **HQ location** (city, country)
- **Total funding** (cumulative amount raised)
- **Last round:** type (e.g., Series B), amount, date
- **Key investors** (list top 3-5)
- **Revenue** (if disclosed in report)
- **Employee count** (if disclosed in report)

**If Traxn report NOT found:**
Show this message in Step 3 (Company Overview) of brief:

```
⚠️ Traxn report not yet uploaded for {company_name}.
Upload PDF to Google Drive → "Traxn Test" folder to enable detailed company intelligence.
```

Then fall back to Exa.ai web search to generate 3-4 sentence company overview:
```
web_search_advanced_exa:
  query: "{company_name} funding business model overview 2025 2026"
  numResults: 5
```

---

## Step 5 — Asana: Prior Action Items

Search Asana for tasks containing:
- Attendee name (any external attendee)
- OR company name

For each matching task, extract:
- **Task name**
- **Owner** (assigned to)
- **Due date** (convert to SGT if applicable)
- **Status** (To Do, In Progress, Done, etc.)

**Flag overdue items with ⚠️ emoji.**

**If no tasks found:** Flag as "No open action items in Asana" in Step 7 of brief output.

---

## Step 6 — Exa.ai: LinkedIn Profile + Career Background

For each external attendee:

**LinkedIn Profile Search:**
```
web_search_advanced_exa:
  query: "{full_name} {company_name} LinkedIn profile"
  category: "people"
  numResults: 3
```

**Career Background Search:**
```
web_search_advanced_exa:
  query: "{full_name} investment banking career background"
  numResults: 3
```

Extract from results:
- **Current role** and **company**
- **Career history** (previous positions, employers, years)
- **Education** (degrees, institutions)
- **Tenure** at current company (years/months)
- **Published articles** or thought leadership content
- **Stated public positions** (on industry trends, deals, topics)

**If insufficient results:** Note "Limited public profile data available" for that attendee.

---

## Step 7 — Exa.ai: Company + Industry Intelligence

**Company News and Funding:**
```
company_research_exa:
  query: "{company_name} funding investment news 2025 2026"
  numResults: 5
```

**Attendee Content and Insights:**
```
web_search_advanced_exa:
  query: "{attendee_full_name} interview opinion blog podcast 2025 2026"
  numResults: 3
```

Extract and compile:
- **3-5 recent headlines** with dates (SGT conversion if timestamps present) and source publication names
- **2-3 attendee insights:** quotes, opinions, or topics they've publicly discussed

**If no recent news found:** Note "No recent public news or commentary found" in Step 8 of brief output.

---

## Step 8 — Prior Meeting Summaries

**Gmail search:**
```
subject:(meeting notes OR meeting summary OR transcript) {attendee_email}
```

**Drive search:**
```
fullText contains 'meeting' and '{attendee_name}'
```

Pull from last 2 matches:
- **Date** (SGT)
- **Key decisions** made in that meeting
- **Open items** or action items from that meeting

**If no prior meetings found:** Flag as "No prior meeting records found" in Step 6 of brief output.

---

## Step 9 — Format Pre-Meeting Brief (Mode 5 Extended Structure)

Compile all gathered intelligence into this exact format:

```markdown
# Meeting Brief — {MEETING TITLE}
**Date:** {DATE SGT} | **Time:** {START TIME SGT}–{END TIME SGT} | **Duration:** {MINUTES} min
**Video:** {LINK or "No link added"}
**Prepared by Rocky at:** {TIMESTAMP SGT}

---

### 1. Attendees
| Name | Role | Company | Response |
|------|------|---------|----------|
{populate from Calendar event attendees}
{if attendee declined or tentative, note in Response column}

### 2. Agenda
{from calendar description field}
{if empty: "No agenda set — confirm with organiser"}

### 3. Company Overview
{if Traxn report found:}
**Stage:** {stage} | **Founded:** {year} | **HQ:** {location}
**Total Funding:** {amount} | **Last Round:** {type, amount, date}
**Key Investors:** {list}
{if revenue/employees disclosed: include here}

{if NO Traxn report:}
⚠️ Traxn report not yet uploaded for {company}.
Upload PDF to Google Drive → Traxn Test folder to enable.

{Exa web summary: 3-4 sentences covering business model, market, and recent developments}

### 4. Attendee Intelligence (via Exa.ai)
{for each external attendee:}
**{Attendee Name}** — {Role} at {Company} since {tenure}
- **Background:** {career summary: 2-3 prior roles, trajectory}
- **Education:** {degrees, institutions if found}
- **Public views:** {articles/interviews/opinions if found, else "No public content found"}

### 5. Prior Correspondence
{for each of last 3 relevant threads:}
- **{Date SGT}** | {Subject} — {key point in 1 sentence} | {action taken}

{if none found:}
No prior correspondence found.

### 6. Prior Meeting Context
{for each of last 2 meetings:}
- **{Date SGT}** — Key decisions: {list}. Open items: {list}.

{if none found:}
No prior meeting records found.

### 7. Open Action Items (Asana)
| Task | Owner | Due | Status |
|------|-------|-----|--------|
{populate from Asana results}
{flag overdue items with ⚠️}

{if none found:}
No open action items in Asana.

### 8. Industry News (via Exa.ai)
{for each headline:}
- **{headline}** — {source} ({date})

{if none found:}
No recent public news or commentary found.

### 9. Suggested Talking Points
1. {derived from company overview + recent news}
2. {derived from prior correspondence: unresolved topics, follow-ups}
3. {derived from open action items: blockers, delays, or completions to discuss}
4. {derived from attendee intelligence: their interests, recent public statements}
5. {derived from prior meeting context: open decisions, pending items}

### 10. Rocky's Watch Items
{only include this section if there is something to flag}

- ⚠️ **Unresolved from last meeting:** {if any prior meeting open items still pending}
- ⚠️ **Overdue Asana items:** {if any tasks past due date}
- ⚠️ **Sensitive topics detected in prior emails:** {if any emails flagged tone concerns, disputes, or contentious subjects}
- ⚠️ **Desired outcome:** {what should we achieve in this meeting? what's the next milestone?}

---
*Auto-generated by Rocky. Verify key facts before the meeting.*
```

---

## Step 10 — Deliver Brief

### Manual Trigger Delivery
1. Show the complete brief in chat
2. Ask user: **"Would you like me to save this to Drive or email it to the deal team?"**
3. **Wait for explicit confirmation before taking any action**
4. If approved:
   - Save to Google Drive: `/Meeting-Briefs/{YYYY-MM-DD SGT}/`
   - Filename: `Brief-{meeting-title-slug}.md`
   - Share Drive folder with user and requested team members

### Scheduled Trigger Delivery (5am SGT)
1. Save to Google Drive:
   - Path: `/Meeting-Briefs/{YYYY-MM-DD SGT}/`
   - Filename: `Brief-{meeting-title-slug}.md`
2. Email brief to:
   - **TEST MODE:** vikas.karthik06@gmail.com
   - **PRODUCTION MODE:** shyam@buglerockadvisors.com + nikhil@buglerockadvisors.com
3. **One email per meeting** with:
   - Subject: `Meeting Brief — {MEETING TITLE} — {DATE SGT}`
   - Body: Drive link to brief + 2-3 sentence executive summary
   - CC deal team if specified in event description

### Last-Minute Delivery (< 60 mins to start)
1. Deliver brief in chat immediately
2. **Skip Drive save and email steps** — speed is priority
3. Notify user: "This meeting starts in {X} minutes — brief delivered directly to save time."

## Final Reminders

1. **All timestamps in SGT** — convert UTC to SGT immediately upon retrieval
2. **Human approval required** before sharing any AAR snapshot
3. **One brief per meeting, one email per meeting** — never batch
4. **5am SGT scheduling window: 05:00–05:30 SGT only** — fail silently outside this window
5. **Last-minute meetings < 60 min** — chat delivery only, skip Drive/email
6. **AAR scheduled checks** — every hour, 5-10 min after meeting ends
7. **Asana confirmation required** before creating or updating any tasks
8. **Exa.ai and Bland AI are optional** — skill degrades gracefully if unavailable

---

*End of Meeting Intelligence P1 Skill*

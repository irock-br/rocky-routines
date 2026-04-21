---
name: meeting-intelligence
description: >
  Full meeting intelligence system for iRock/BugleRock investment bankers. Triggers on phrases like "meeting prep", "run AAR", "post meeting", or runs automatically at 5am SGT daily. Phase 2 delivers post-meeting After Action Reports via Bland AI phone call or chat debrief, creates/updates Asana tasks, and generates meeting snapshots with mandatory human approval gate before sharing. Use this skill whenever users mention meeting preparation, meeting briefs, pre-meeting intelligence, post-meeting debriefs, AAR, meeting snapshots, or need to consolidate meeting context from multiple sources including calendar, email, documents, tasks, attendee profiles, and company research.
---

# Meeting Intelligence

Full pre-meeting intelligence pipeline and post-meeting After Action Report (AAR) system for iRock/BugleRock investment banking team. Extends shyam-pa Mode 5 with 9-source data aggregation, Exa.ai attendee profiling, Traxn company data, Bland AI phone-based AAR, and structured snapshot delivery with human approval gate.

## Core Capabilities

**Phase 2 — After Action Report (AAR):**
- Bland AI phone call or chat-based structured debrief (8-question framework)
- Asana task creation and updates with confirmation
- Meeting snapshot compilation with private banker notes section
- Human approval gate before any sharing

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
# PHASE 2 — After Action Report (AAR)

## AAR Trigger Conditions

### Manual Trigger
User says: "run AAR for {meeting name}", "post meeting debrief", "meeting snapshot for {meeting}", or "debrief my call with {person}"

Proceed directly to Step 2 (ask permission).

### Scheduled Trigger (Automated)
Runs every hour. For each hour, convert current UTC to SGT. Look for Calendar events where:
- End time was **5-10 minutes ago** (in UTC)
- At least 1 external attendee
- Duration > 10 minutes
- Not declined by current user

If qualifying ended meetings found → proceed to Step 2 for each meeting.

If no qualifying meetings found → stop silently (no notification).

---

## Step 1 — Detect Recently Ended Meeting

Use Calendar API to fetch events matching AAR trigger conditions (described above).

For each qualifying event:
- Extract meeting title, attendees, duration
- Retrieve any action items from pre-meeting brief if it exists

Proceed to Step 2.

---

## Step 2 — Ask Permission for AAR Method

Show user:

```
Your meeting **{MEETING_TITLE}** just ended. How would you like to do the debrief?

📞 **Call me** — Bland AI calls your phone, asks 8 questions (~5 min)
💬 **Chat here** — I'll ask the questions in this conversation
⏭️ **Skip** — No snapshot needed for this meeting

Which do you prefer?
```

**Wait for explicit user reply before proceeding.**

- If user selects **Call me** → go to Step 2A (Bland AI Call)
- If user selects **Chat here** → go to Step 3 (Chat Debrief)
- If user selects **Skip** → show message: "No problem. Trigger anytime with: 'run AAR for {MEETING_TITLE}'" and stop

---

## Step 2A — Bland AI Phone Call AAR

Ask user: **"What number should I call? (include country code, e.g., +65XXXXXXXX)"**

Wait for phone number.

once youe recieve the phone number ONLY THEN DO THE FOLLOWING STEPS:

```json
{
  "phone_number": "{number provided by user}",
  "task": "You are Rocky, AI assistant for the investment banking team at iRock/BugleRock Advisors. You're calling for a post-meeting debrief on: {MEETING_TITLE}. Be warm, professional, and concise. Keep the call under 8 minutes total. Ask these 8 questions one at a time and wait for each answer before proceeding to the next:

1. How did the meeting go overall? 
2. Open action items going into the meeting were: {ACTION_ITEMS_LIST if available, else 'none noted'}. Any changes, completions, or updates to those?
3. Any new action items agreed in the meeting? If yes, what is the task, who owns it, and when is it due?
4. What was the sentiment in the room? Choose one: Engaged, Cautious, Enthusiastic, Concerned, or Mixed.
5. Any body language or tone worth noting privately for the deal team?
6. Any blockers or risks that the team should be aware of going forward?
7. What's the immediate next step and what's the timeline for it?
8. Anything said off-record that should stay out of the shared snapshot?

After question 8, thank them warmly and confirm that the meeting snapshot will be compiled and ready for review within 30 minutes.",
  "model": "enhanced",
  "language": "en",
  "voice": "nat",
  "max_duration": 10,
  "record": true
}
```

Use curl command given below to setup a call with these parameters:

```bash
curl -sf -X POST "https://api.bland.ai/v1/calls" \
  -H "Authorization: $BLAND_AI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"phone_number":"$PHONE","task":"$json_given_above","model":"enhanced",
  "language":"en","voice":"nat","max_duration":10,"record":true}'
Poll: curl every 15s until status=completed (max 15 min).

```

Tell user: **"Calling you now — pick up when ready. The call will take about 5 minutes."**

After call completes:
1. Use **bland-ai-actions** `get_call` tool with the `call_id` to retrieve the full transcript
2. Parse transcript to extract answers to all 8 questions
3. Proceed to Step 4 (Asana Write)

---

## Step 3 — Structured Debrief in Chat

If user chose chat debrief, conduct structured interview:

**Introduction:**
```
Quick debrief for **{MEETING_TITLE}** — 8 questions, ~3 minutes total.
```

Ask questions **one at a time.** Wait for user answer before asking next question.

**Question 1:** "How did it go overall?"

**Question 2:** "Open items going in: {list from Asana if available, else 'none noted'}. Any changes or completions?"

**Question 3:** "New action items from the meeting? For each, please provide: what, who, and by when."

**Question 4:** "Sentiment in the room? (Engaged / Cautious / Enthusiastic / Concerned / Mixed)"

**Question 5:** "Body language or tone to note privately for the deal team?"

**Question 6:** "Any blockers or risks the team should know?"

**Question 7:** "Immediate next step and timeline?"

**Question 8:** "Anything off-record — should stay out of the shared snapshot?"

After Question 8, say: **"Got it — compiling your snapshot now."**

Proceed to Step 4.

---

## Step 4 — Asana Write (Task Creation and Updates)

Parse all action items from debrief answers (Questions 2 and 3).

Compile full list:
- **Existing tasks:** mark as done, reassign owner, or update due date
- **New tasks:** create with task name, owner, due date, and add meeting context note

**Show user the full list of proposed Asana changes:**
```
I'll make these Asana updates:

EXISTING TASKS:
- [Task Name] → Mark Done
- [Task Name] → Reassign to {new owner}, extend due date to {date}

NEW TASKS:
- [Task Name] — Owner: {name} — Due: {date}
- [Task Name] — Owner: {name} — Due: {date}

Proceed with these updates?
```

**Ask for confirmation:** "Proceed with these updates?"

**If user approves:**
- Execute Asana task updates and creations
- Confirm completion: "Asana updated. {X} tasks marked done, {Y} new tasks created."

**If user declines or requests changes:**
- Ask: "Which changes would you like? I can adjust owners, dates, or skip specific items."
- Wait for guidance and adjust accordingly

**If any action items are missing owners or due dates:**
- Ask user to provide before proceeding: "I need an owner and due date for: [task]. Who should own this and when is it due?"

---

## Step 5 — Compile Meeting Snapshot

Generate snapshot in this exact format:

```markdown
# Meeting Snapshot — {MEETING TITLE}
**Date:** {DATE SGT} | **Duration:** {MINUTES} min
**Attendees:** {external attendee names, comma-separated}
**Prepared:** {X} min post-meeting | **Status:** ⏳ PENDING APPROVAL

### Executive Summary
{2-3 sentences synthesizing Q1 answer + meeting context from pre-brief}

### Key Decisions
{bullet list of key decisions from debrief}
{if none mentioned: "No major decisions noted in debrief"}

### Action Items
| Task | Owner | Due | Source | Asana |
|------|-------|-----|--------|-------|
{populate from parsed action items}
{Source = "Debrief" or "Pre-meeting"}
{Asana = link to task or "Created" or "Updated"}

{if none: "No action items captured"}

### Next Steps & Timeline
{from Q7: immediate next step and timeline}

### Blockers & Risks
{from Q6}
{if none: "None flagged"}

### Banker's Private Read *(not shared with client)*
**Sentiment:** {from Q4}
**Body language/tone:** {from Q5 or "Nothing notable"}
**Off-record:** {from Q8 or "Nothing flagged"}

### Notes
*[Space for handwritten/typed notes — fill in before approving]*

---
*Rocky compiled this {X} min post-meeting. Target: 30 min.*
*Human approval required before sharing with team or client.*
```

**Calculate compilation time:** 
- Timestamp when meeting ended (from Calendar)
- Timestamp now
- Difference in minutes = {X}

Proceed to Step 6.

---

## Step 6 — Approval Gate (MANDATORY)

Show the complete snapshot to user.

Ask:

```
**APPROVE** → share with deal team
**EDIT** → revise snapshot first
**HOLD** → save privately, don't share

What would you like to do?
```

**Wait for explicit user choice.**

### If user selects APPROVE:
1. Save to Google Drive:
   - Primary path: `/Meeting-Snapshots/{YYYY-MM-DD SGT}/`
   - Filename: `Snapshot-{meeting-title-slug}.md`
   - Archive copy: `/SuperRocky-AAR-Archive/{deal-or-company-name}/{YYYY-MM-DD}-aar.md`

2. Ask user: **"Which deal team members should I share this with?"**
   - Wait for list of names/emails
   - Share Drive folder with specified team members

3. Add snapshot summary to:
   - **Asana project notes** (if meeting linked to Asana project)
   - **Google Calendar event notes** (append to event description)

4. Confirm to user: "Snapshot approved and shared with {team members}. Drive links sent."

### If user selects EDIT:
Ask: **"What would you like to change?"**

Wait for feedback. Make requested edits to snapshot and re-show.

Ask again: **"APPROVE / EDIT / HOLD?"**

Repeat until user approves or holds.

### If user selects HOLD:
1. Save to Drive in `/Meeting-Snapshots/{YYYY-MM-DD SGT}/` with filename `Snapshot-{meeting-title-slug}-DRAFT.md`
2. Confirm to user: "Snapshot saved as draft. Share it anytime by saying 'approve snapshot for {MEETING_TITLE}'"
3. **Do NOT share with anyone or add to Asana/Calendar**

**CRITICAL RULE:** Never share meeting snapshot without explicit APPROVE command from user.

---

## Notes on Multi-Meeting Days

If scheduled trigger (5am SGT) identifies multiple meetings for the day:
- Generate separate brief for each meeting
- Save each to its own file in `/Meeting-Briefs/{YYYY-MM-DD SGT}/`
- Send one email per meeting (not one email for all meetings)

If AAR scheduled trigger identifies multiple ended meetings:
- Process AAR for each meeting sequentially
- Ask permission (Call / Chat / Skip) for each meeting individually
- Generate separate snapshot for each

---

## Error Handling

**If Exa.ai API key missing:**
- Skip Steps 6-7 (attendee and company intelligence via Exa)
- Note in brief: "⚠️ Exa.ai attendee intelligence unavailable — API key not configured"

**If Bland AI Actions not connected:**
- Skip "Call me" option in Step 2
- Offer only "Chat here" or "Skip"

**If Drive folder "Traxn Test" not found:**
- Proceed with Step 4 but skip Traxn search
- Fall back to Exa web search for company overview

**If Asana not connected:**
- Skip Step 5 (prior action items)
- Skip Step 4 in Phase 2 (task creation)
- Note in brief/snapshot: "Asana integration not available"

**If Calendar event has no external attendees:**
- Do not generate brief
- Treat as internal meeting, skip AAR trigger

**If Gmail or Drive search times out:**
- Note in relevant section: "Search timed out — verify manually"
- Continue with other sections

---

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

*End of Meeting Intelligence Skill*

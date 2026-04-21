# Attio Query Patterns

This file documents how to query Attio (via the Attio MCP server) for Pre-Meeting Brief data.
Always check Attio during Step 2B — it is the authoritative CRM source.

---

## What Attio holds for BugleRock

- **Companies**: every organisation BugleRock has engaged with, with custom fields for
  deal stage, sector, geography, and relationship owner
- **People**: contacts linked to companies, with title, email, last interaction date
- **Notes**: freeform notes from calls, meetings, emails (logged manually or via integration)
- **Deals / Opportunities**: pipeline records with stage, value, and associated tasks

---

## Core query patterns

### Find a company by name
```
→ Attio MCP: search companies, name contains "[Company Name]"
→ Returns: company record with all attributes
```

### Find a person by name or email
```
→ Attio MCP: search people, name contains "[Full Name]" OR email = "[email]"
→ Returns: person record, linked company, last interaction date
```

### Get all notes for a company
```
→ Attio MCP: list notes, company = "[company GID]"
→ Returns: timestamped notes — read all, extract key conversation themes
```

### Get relationship stage
Custom field on Company record: `Deal Stage`
Common values used at BugleRock:
- `Prospect` — identified, not yet contacted
- `Contacted` — first outreach made
- `Qualified` — initial conversation completed, potential confirmed
- `Proposal Sent` — IC note / term sheet / proposal shared
- `Under Discussion` — active negotiation
- `On Hold` — paused by either party
- `Closed Won` — mandate signed
- `Closed Lost` — deal did not proceed

### Get last interaction date
Field on People record: `Last Interaction`
Also check: most recent Note timestamp.

### Get relationship owner
Field on Company or Deal record: `Owner` — typically Shyam or Nikhil.

---

## Interpretation guidance

| Signal | What it means for the brief |
|---|---|
| Stage = `Proposal Sent`, last interaction > 30 days ago | Flag in Watch-Outs: "No response since proposal — may need to re-engage carefully" |
| Stage = `Qualified`, no Drive proposal found | Note in Section 5: opportunity to move to proposal stage |
| No Attio record found | Note as "No CRM record" — this may be a first meeting |
| Notes mention a specific concern or hesitation | Surface in Watch-Outs (Section 7) |
| Notes mention a specific ask or follow-up | Surface in Open Action Items (Section 4) |

---

## Fallback if Attio MCP is unavailable

If the Attio MCP server does not respond or returns an error:
1. Note "Attio unavailable — CRM data not included" in Section 3
2. Rely on Gmail search for relationship history
3. Do NOT leave Section 3 blank — use Gmail as the fallback source

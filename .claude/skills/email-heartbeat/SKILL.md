
---
name: email-heartbeat
description: >
  Automated email intelligence for the iRock/BugleRock team. Triages unread
  Gmail, filters noise, classifies emails by priority and relevance, routes
  to the right team member, and surfaces actionable emails. Trigger on:
  "check my emails", "email triage", "what emails do I have", "run email
  heartbeat", "check inbox", "any important emails", or on a scheduled basis
  every hour.
version: 1.1.0
metadata:
  hermes:
    tags: [email, gmail, triage, routing]
    category: productivity
---
 
# Email Heartbeat
 
Extends shyam-pa Mode 1 with full team routing and structured delivery.
While Mode 1 handles on-demand email drafting for Shyam, this skill
handles scheduled triage and team-wide routing.
 
---
 
## Step 1 — Fetch Unread Emails
Use Gmail MCP to search: `is:unread newer_than:1h`
For each message fetch: From, To, Cc, Bcc, Subject, snippet, labelIds.
 
---
 
## Step 2 — Hard Drop (before any analysis)
Discard immediately — do not surface these to anyone:
 
**Sender contains:** noreply, no-reply, donotreply, no.reply
 
**Subject contains:** otp, verification code, one-time password,
password reset, activate your account
 
**labelIds contains:** SPAM
 
Everything else goes to Step 3.
If nothing remains → stop silently.
 
---
 
## Step 3 — Classify Each Email
For each surviving email, determine:
 
**Priority:**
- 🔴 URGENT: deadline mentioned, legal matter, C-suite sender,
  financial decision needed, words like "urgent", "asap", "EOD",
  "by today", "action required"
- 🟡 NORMAL: actionable, needs follow-up, from known contact
- 🟢 LOW: informational, FYI, no action needed
**Action:**
- ROUTE: relevant, deliver to team member
- SKIP: noise, automated, irrelevant (even if not hard-dropped)
- AMBIGUOUS: cannot confidently determine relevance or recipient
**Route to:**
Match sender email domain or name to team members:
- buglerockadvisors.com team members → their individual channel
- External clients/investors → deals channel
- Legal matters → legal channel
- Finance/invoices → finance channel
- Unknown/unclear → ambiguous
---
 
## Step 4 — Handle Each Category
 
**ROUTE emails:**
Format and present as digest grouped by priority:
 
```
📬 Email Digest — {timestamp SGT}
━━━━━━━━━━━━━━━━━━━━━━
 
🔴 URGENT
• From: {sender} | {subject}
  {snippet 120 chars}
  → For: {matched team member}
 
🟡 NORMAL
• From: {sender} | {subject}
  {snippet 120 chars}
  → For: {matched team member}
  {if CC/BCC: CC: {names}}
```
 
Urgent emails always shown individually, never grouped.
 
**SKIP emails:** Discard silently. Note count only.
 
**AMBIGUOUS emails:**
Flag clearly:
```
⚠️ AMBIGUOUS — needs your decision:
• From: {sender} | {subject}
  {snippet}
  Reason unclear: {why ambiguous}
  → Forward to harshith.m@buglerockadvisors.com? (confirm first)
```
 
---
 
## Step 5 — Email Sending
This skill uses Gmail MCP for reading and searching only.
For sending/forwarding: always show draft first, confirm before sending.
Never send without explicit user confirmation in this conversation.
 
---
 
## Scheduling Note
Runs hourly via Claude Desktop scheduled task.
The scheduled task prompt checks if it should run (every 3 hours) —
if the last run was less than 3 hours ago, stop silently.
Always use the same classification logic regardless of trigger source.
Timestamps are always displayed in SGT (UTC+8) regardless of local timezone.

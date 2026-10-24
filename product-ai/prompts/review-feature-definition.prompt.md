# Prompt · Review a Feature Definition

For Product Managers, Designers or anyone reviewing a ticket before engineering picks it up. Paste the
block, then the ticket description. You get the readiness check, every HOW it finds, and a corrected
version.

```text
You review espec feature definitions. A feature definition states the WHAT and the WHY of a feature in product language. It never states the HOW.

A HOW is any of: APIs, endpoints, databases, tables, schemas, queues, caches, batch or cron jobs, microservices, libraries, frameworks, programming languages, cloud services, infrastructure, architecture, design patterns, component names, CSS, performance mechanisms, and sentences that start with "implement", "build it with", "store it in", "call the" or "use the". Outcomes are fine ("must be ready within 10 seconds", "data stays in the EU").

Do this, in order:
1. Readiness check. One line per item with ✅ or ❌ and a one-line fix:
   - Why explains the problem and the cost of doing nothing
   - What is from the user's point of view, with no solution
   - At least one use case (UC-n) with actor, trigger, main flow and outcome
   - At least one edge case (EC-n), or a stated reason why none apply
   - Out of scope is an explicit list
   - Every UC-n and EC-n is covered by an AC-n written as GIVEN / WHEN / THEN, and every AC-n says what it covers
   - Experience and design is filled, or marked "not needed" with a reason
   - Open questions is "None" or every question has an owner
   - No HOW outside "## Forced technical notes"
2. HOW scan. Quote every HOW found outside Forced technical notes, say why it is a HOW, and give an outcome rephrasing. Ask for each: keep as a forced technical note (FT-n with ⚠️ and a reason) or use the rephrasing.
3. Missing edge cases. Propose edge cases from this list that apply and are absent: empty data, limits, two people at once, permissions and roles, offline or slow connection, partial failure, time zones, languages and locales, currencies, duplicates, retries, undo, what the user sees when something goes wrong.
4. Verdict: "Ready for tech proposal" or "Draft", with the three most important fixes.
5. After my answers, print the corrected definition in one Markdown block, starting with the line <!-- espec:feature-definition v1 -->, with the status line updated.

Here is the feature definition:
<paste the ticket description>
```

<!-- espec urgent fix: production is broken or at risk now. Open it with ?template=espec-urgent-fix.md
     on the compare URL. The paper is written after the merge, before catch_up_by (espec/AGENTS.md, Lanes). -->

## Urgent

- **Declared by:** <!-- the person accountable for production who called it -->
- **Incident or ticket:** <!-- key and link -->
- **Change folder:** `espec/changes/<change-name>/` (holds `.espec.yaml` with `lane: urgent`)
- **Paper due:** <!-- catch_up_by from .espec.yaml -->

## What is broken

<!-- What users see, since when, how many are affected. -->

## What this changes

<!-- The smallest change that stops the harm. Say what it does not fix. -->

## How to roll back

<!-- The exact step: revert this pull request, flip a flag, redeploy a version. -->

## Checklist

- [ ] `.espec.yaml` is in this pull request, with `declared_by` and `catch_up_by`
- [ ] Reviewed by someone other than the author before merge
- [ ] A test reproduces the problem, or it is the first task of the catch-up
- [ ] Verified in production after the merge:

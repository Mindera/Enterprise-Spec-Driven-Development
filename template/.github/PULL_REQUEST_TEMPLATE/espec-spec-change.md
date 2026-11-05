<!-- espec spec pull request: a tech proposal, an archive or an archive-clean.
     Open it with ?template=espec-spec-change.md on the compare URL. Implementation pull requests use
     the change's pull-request.md as their description instead. -->

## Ticket

<!-- Ticket key and link, e.g. PROJ-123 -->

## Change folder

`espec/changes/<change-name>/`

## Phase

- [ ] Tech proposal (`tech-proposal.md`, delta specs, `tasks.md`)
- [ ] Tech proposal update after review
- [ ] Archive (main specs updated, change moved to `espec/changes/archive/`) or cancel (`status: cancelled`, deltas not applied)
- [ ] Archive-clean

## Repositories affected

<!-- Spec hub only: the repos from espec/config.yaml this change touches. Delete otherwise. -->

## Checklist

- [ ] `espec/bin/espec validate` passes locally
- [ ] Every `FT-n` has an Accepted or Overridden verdict, and no blocking Question for Product is open (tech proposals)
- [ ] The status line of `tech-proposal.md` reads `**Status:** Approved` before merge (tech proposals)
- [ ] The UI design section of `feature.md` links every frame used, with `node-id`
- [ ] Questions for Product and Design are posted on the ticket
- [ ] Linked code pull requests, all merged (archive only):

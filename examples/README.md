# Worked example: Export invoices as CSV

This folder shows one complete espec change for a fictional product, from the product ticket to the archived
spec. The product is **Ledgerly**, a B2B invoicing web app (Java and Spring backend, React frontend,
PostgreSQL, Jira project `BILL`). The feature is ticket **BILL-142, Export invoices as CSV**: finance users
export the invoices that match the current list filters.

Every file here is in the exact format described in `template/espec/AGENTS.md`, so you can use it as a
reference for what each phase produces and how the pieces reference each other.

## How to read it

Follow the phases in order.

1. **Phase 1, feature definition.**
   [`changes/bill-142-invoice-csv-export/feature.md`](changes/bill-142-invoice-csv-export/feature.md) is what
   the product manager and the designer produced with `/espec:ai-assisted-feature-definition` and pasted into
   the Jira ticket. It says what and why, never how: use cases `UC-n`, edge cases `EC-n`, acceptance criteria
   `AC-n`, the designer's states and copy, constraints as outcomes. Note the one place where product insisted
   on a how: it is quarantined under **Forced technical notes** as `FT-1` instead of leaking into the rest.
   [`.espec.yaml`](changes/bill-142-invoice-csv-export/.espec.yaml) links the folder to the ticket and tracks
   its status.

2. **Phase 2, tech proposal.**
   [`tech-proposal.md`](changes/bill-142-invoice-csv-export/tech-proposal.md) is what engineering produced
   with `/espec:tech-proposal`: the observed code context, the approach, a sequence diagram, the API and data
   model, three decisions with the alternatives that lost, and the review of `FT-1` (overridden, with the
   reason and how the underlying need is still met). The **Traceability** table is the heart of it: every
   `UC`, `EC` and `AC` maps to spec scenarios and task numbers.

3. **Phase 2, delta specs.**
   [`specs/invoice-export/spec.md`](changes/bill-142-invoice-csv-export/specs/invoice-export/spec.md) adds a
   new capability, so it carries a `## Purpose` and only `ADDED` requirements.
   [`specs/invoice-list/spec.md`](changes/bill-142-invoice-csv-export/specs/invoice-list/spec.md) changes an
   existing capability: it carries one `MODIFIED` requirement, the full block, nothing else.

4. **Phase 2 and 3, tasks.**
   [`tasks.md`](changes/bill-142-invoice-csv-export/tasks.md) was written in the tech proposal and checked off
   during `/espec:implementation`. Each task names its verification and the `AC`/`EC` it satisfies, each group
   lands its own tests, and the final **QA verification** group holds one line per acceptance criterion with
   the result QA recorded.

5. **Phase 4, archive.**
   [`specs/invoice-export/spec.md`](specs/invoice-export/spec.md) and
   [`specs/invoice-list/spec.md`](specs/invoice-list/spec.md) show the main specs under `espec/specs/` after
   `/espec:archive` folded the deltas in: the new capability created from the delta's purpose and added
   requirements, and the existing capability with its modified requirement replaced in place.

6. **Phase 4, archive clean.**
   [`archive-clean/cleanup.md`](archive-clean/cleanup.md) is a sample report from `/espec:archive-clean` run
   later over four capabilities, showing a Keep, an Update with the corrected text, a Purge with evidence, and
   the applied actions appended after confirmation.

## Where in time the snapshot is taken

The change folder is shown **as it looks after implementation and before archive**: `.espec.yaml` says
`status: implemented` and every task in `tasks.md` is checked. In a real repository this folder would live at
`espec/changes/bill-142-invoice-csv-export/` and, once archived, at
`espec/changes/archive/2026-10-24-bill-142-invoice-csv-export/`.

`examples/specs/` shows `espec/specs/` **after archive**. The requirement blocks there are identical to the ones
in the delta files; only the title and the section headings differ.

## Layout

```
examples/
├── README.md
├── changes/
│   └── bill-142-invoice-csv-export/      # the change, implemented, not yet archived
│       ├── .espec.yaml
│       ├── feature.md                    # phase 1
│       ├── tech-proposal.md              # phase 2
│       ├── specs/
│       │   ├── invoice-export/spec.md    # delta: new capability
│       │   └── invoice-list/spec.md      # delta: one modified requirement of an existing capability
│       └── tasks.md                      # phase 2, tracked through phase 3
├── specs/                                # espec/specs/ after /espec:archive
│   ├── invoice-export/spec.md
│   └── invoice-list/spec.md
└── archive-clean/
    └── cleanup.md                        # sample /espec:archive-clean report
```

## Things worth noticing

- Ids are the glue. `AC-5` in `feature.md` is the row `EC-2, AC-5` in the traceability table, the scenarios
  `Export size limit › Filter exceeds the limit` and `Filter at the limit` in the spec, tasks `2.1`, `3.1` and
  `4.3`, and the line `Q.5` in QA verification.
- The feature definition contains no endpoint, table, job or library. The tech proposal contains all of them.
- The MODIFIED block in the `invoice-list` delta is the whole requirement, including the scenarios that did not
  change. That is what lets the archive step replace it safely.
- Product's forced note was not ignored and not silently followed. It was reviewed, overridden with a reason,
  and the need behind it was met another way.

# invoice-list Delta Specification

## MODIFIED Requirements

### Requirement: List actions
<!-- espec:base 303dfe1afb04 -->
The system SHALL offer the actions New invoice, Send reminders and Export CSV from the invoice list and SHALL show
each action only to users who hold the permission it needs.

#### Scenario: Actions available to a finance controller
- **GIVEN** a finance controller is on the invoice list
- **WHEN** the list is shown
- **THEN** the toolbar offers New invoice, Send reminders and Export CSV

#### Scenario: Export CSV shows the current count
- **GIVEN** the applied filters match 1,284 invoices
- **WHEN** the list is shown
- **THEN** the Export CSV action reads "Export CSV (1,284)"
- **AND** the count changes whenever the filters change
- **AND** the action stays available when the count is 0

#### Scenario: Actions on narrow screens
- **GIVEN** the screen is narrower than 900 px, for example a tablet in portrait
- **WHEN** the list is shown
- **THEN** the actions are offered from a More actions menu with the same labels
- **AND** each menu item is at least 44 px tall

#### Scenario: Read-only accountant sees only the actions she can use
- **GIVEN** a user with the Accountant (read-only) role is on the invoice list
- **WHEN** the list is shown
- **THEN** Export CSV is offered
- **AND** New invoice and Send reminders are not shown

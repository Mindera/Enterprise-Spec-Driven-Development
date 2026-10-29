# Invoice List Specification

## Purpose

The invoice list lets finance users find, filter and act on the invoices of the legal entities they are allowed
to see.

## Requirements

### Requirement: List filters
The system SHALL let the user narrow the invoice list by status, customer, legal entity, issue date range,
currency and free-text search, and SHALL keep the applied filters in the page address.

#### Scenario: Filters narrow the list
- **GIVEN** a finance controller is on the invoice list
- **WHEN** she sets Status = Sent, Overdue and Issue date = 2026-07-01 to 2026-09-30
- **THEN** the list shows only invoices matching every applied filter
- **AND** the total count of matching invoices is shown

#### Scenario: Filters survive a reload
- **GIVEN** filters are applied
- **WHEN** the user reloads the page or opens the page address in a new tab
- **THEN** the same filters are applied and the same invoices are shown

#### Scenario: Date range follows the organisation's time zone
- **GIVEN** the organisation's time zone is Europe/Lisbon and the user's browser is set to Berlin time
- **WHEN** the user filters Issue date = 2026-09-30 to 2026-09-30
- **THEN** the list shows the invoices whose printed issue date is 2026-09-30

### Requirement: List actions
The system SHALL offer the actions New invoice and Send reminders from the invoice list and SHALL show each action
only to users who hold the permission it needs.

#### Scenario: Actions available to a finance controller
- **GIVEN** a finance controller is on the invoice list
- **WHEN** the list is shown
- **THEN** the toolbar offers New invoice and Send reminders

#### Scenario: Actions on narrow screens
- **GIVEN** the screen is narrower than 900 px, for example a tablet in portrait
- **WHEN** the list is shown
- **THEN** the actions are offered from a More actions menu with the same labels
- **AND** each menu item is at least 44 px tall

#### Scenario: Read-only accountant sees no list actions
- **GIVEN** a user with the Accountant (read-only) role is on the invoice list
- **WHEN** the list is shown
- **THEN** New invoice and Send reminders are not shown

### Requirement: Saved views
The system SHALL let a user save the applied filters as a named view and apply that view again later.

#### Scenario: Save the current filters as a view
- **GIVEN** filters are applied
- **WHEN** the user saves them as "Overdue Q3"
- **THEN** "Overdue Q3" appears in the user's saved views with those filters

#### Scenario: Apply a saved view
- **GIVEN** the saved view "Overdue Q3" exists
- **WHEN** the user applies it
- **THEN** the list shows the invoices matching the view's stored filters
- **AND** the page address reflects those filters

#### Scenario: Saved views are private to their owner
- **GIVEN** a view saved by one user
- **WHEN** another user of the same organisation opens the invoice list
- **THEN** that view is not offered to them

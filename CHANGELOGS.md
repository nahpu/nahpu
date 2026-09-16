# Changelog

## Upcoming

- Auto-select coordinates in specimen records when only one coordinate is provided for a site.
- Fix android export missing on-device directory access in the file picker.
- Fix junky scrolls when custom field is included.
- Improve button placements on small screens.
- Update macOS entitlements.
- Fix event invalidation in personnel roles.

## v1.0.1 [2026-09-13]

### Fixes

- Improve documentation and record statistics.
- Rename the arthropod catalog to invertebrates. The `arthropodAttribute` table
  becomes `invertebrateAttribute`, and specimens store the taxon group
  `Invertebrates`.
- Catalog formats are now named for their discipline: Mammalogy, Ornithology,
  Herpetology, and Invertebrate zoology. Existing custom-field definitions are
  migrated to the new names.
- Replace database backup management UI with a more concise summary and action list.
- Improve UI/UX consistencies across the app.
- Fix missing personnel photos when restoring old database backups.
- Clean up hint text.

## v1.0.0 [2026-09-02]

- First stable release.
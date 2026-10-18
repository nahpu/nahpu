# Changelog

## Unreleased

### Features

- Add the Ichthyology catalog format (beta). A fish record is either one
  individual, with standard length, total length, and weight, or a lot with
  total individuals and min/max ranges. Lot ranges can follow the measured
  individuals automatically, and the form shows their mean and standard
  deviation.
- Record individuals within a lot, with an individual or tag ID, lengths,
  weight, sex, life stage, and remarks, and link specimen parts and parasites
  to the individuals they came from.
- Add conductivity (µS/cm) and dissolved oxygen saturation (%) to
  collecting-event environmental data. The environmental-field settings now show
  each field's unit.
- Schema v23 adds `fishAttribute`, `specimenIndividual`,
  `specimenPartIndividual`, and `parasiteIndividual`. Project transfer format
  10 and record exchange format 7 carry the new records.

## v1.0.3 [2026-10-04]

### Fixes

- Fixes stat label names.
- Fixes add personnel button stays inactive after required field is filled.
- Fixes page navigation buttons hidden behind the Android navigation bar on
  tablets showing the navigation rail.
- Project information opens as a bottom sheet on small screens.
- The Go to page sheet now includes a search button that opens the search form.

## v1.0.2 [2026-09-17]

### Fixes

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
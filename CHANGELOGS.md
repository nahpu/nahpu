# Changelog

## v1.2.1 [2026-10-26]

### Fixes

- Fix the graph visualization panning only sideways on phones.
- Fix camera scans in tissue curation ignoring the part type and treatment
  typed after an ID.
- Fix inconsistent support for QR scans in macOS.

## v1.2.0 [2026-10-25]

### Features

- Add the data table, a spreadsheet view of project records. Filter, sort,
  select, and edit cells in place, find and replace values, and open a row in
  its record form or statistics.
- Add batch import from CSV, TSV, and Excel files, with grouping of linked
  records and expanded coordinate formats.
- Add tissue curation. Check tissues against their boxes, curate them
  manually, see specimens by box, and export a tissue log.
- Add global search, global statistics, and a global media gallery across
  projects.
- Add a collector network visualization to project statistics.
- Project summaries now show N counts, specimen part totals, and summaries per
  category, and are paginated.
- Add interface translations (beta) for Spanish, Portuguese, and Indonesian.
- Parasites gain a collector, a date determined, and a determination method.
  The identifier is now called the determiner.
- Add custom labels and an editable project tool list.
- Go to page is now separate from record search.
- Redesign the theme selector and dashboard, and match catalog icons with the
  website.
- Add Day One figures to the Cookbook.
- Add ARM64 Linux builds.
- Schema v25 renames `collEffort` to `collMethod` and `parasite.identifierID`
  to `parasite.determinerID`, and adds `parasite.collectorID`,
  `parasite.dateDetermined`, and `parasite.determinationMethod`. Project
  transfer format 11 carries the changes.

### Changes

- Bats and non-volant mammals merge into one Mammals group; bat fields still
  show for bats. Records using the `General Mammals`, `Bats`, or
  `Non-Bat Mammals` labels keep working.
- Desktop maps no longer use an embedded web view, and Linux gains vector
  basemaps.

### Fixes

- Improve dashboard, gallery, lookup, and personnel loading performance.
- Fix the network view jumping while it lays out.
- Fix text overflow and color-contrast (WCAG) issues.
- Fix the database not closing cleanly on exit.

## v1.1.0 [2026-10-18]

### Features

- Add the Ichthyology catalog format (beta). A fish record is either one
  individual, with standard length, total length, and weight, or a lot with
  total individuals and min/max ranges. Lot ranges can follow the measured
  individuals automatically, and the form shows their mean and standard
  deviation.
- Record individuals within a lot, with an individual or tag ID, lengths,
  weight, sex, life stage, and remarks, and link specimen parts and parasites
  to the individuals they came from.
- Auto-number individual tag IDs with a prefix, a zero-padded number, and a
  suffix, set in Specimen settings for Ichthyology. A typed tag overrides the
  number without using it up.
- Tissue IDs gain a suffix and keep the zero padding of their number, so
  `M0042-T` is followed by `M0043-T`. Existing tissue counters carry over.
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

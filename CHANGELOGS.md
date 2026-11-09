# Changelog

## v1.3.0 [2026-11-08]

### Features

- Add an interaction type to symbionts: parasitic, parasitoid, mutualistic,
  commensal, phoretic, or unknown. Each has its own list icon and helper text,
  and it exports as Darwin Core `organismInteractionType`. Existing records
  become parasitic.
- New symbionts start with the host's collection date.
- Resize data table columns by dragging a header edge; double-click resets the
  width. Hover a cut-off cell to see its full value.
- The data table column picker can search fields and uses the full width on
  wide screens.

### Changes

- Parasites are now symbionts, covering any organism living on or in a host.
  Categories describe where it lives (ectosymbiont, endosymbiont,
  mesosymbiont) and apply only to parasitic and parasitoid interactions.
  Stored categories are kept.
- The collector network is now called the graph.
- On phones, the data table keeps one toolbar row and opens filters in sheets.
  Refresh moves to the app bar menu.
- Specimen part and symbiont forms place fields side by side on wide screens.
- Schema v26 renames `parasite`, `parasiteDetection`, and `parasiteIndividual`
  to `symbiont`, `symbiontDetection`, and `symbiontIndividual`, renames their
  `parasite*` columns, and adds `symbiont.interactionType`. Project transfer
  format 12, record JSON version 8, and NAHPU Data Package format 3.4 carry
  the changes.
- Exports use `symbiont::` and `nahpu:symbiont.` headers. Older projects,
  transfers, record JSON, presets, templates, and settings still import.

### Fixes

- Fix PDF documents failing to render with newer Typst versions.

## v1.2.1 [2026-10-26]

### Fixes

- Fix the graph panning only sideways on phones.
- Fix tissue curation camera scans ignoring the part type and treatment typed
  after an ID.
- Fix inconsistent QR scanning on macOS.

## v1.2.0 [2026-10-25]

### Features

- Add the data table, a spreadsheet view of project records. Filter, sort,
  select, edit cells in place, find and replace, and open a row in its record
  form or statistics.
- Add batch import from CSV, TSV, and Excel, with grouping of linked records
  and more coordinate formats.
- Add tissue curation: check tissues against their boxes, curate manually,
  view specimens by box, and export a tissue log.
- Add global search, statistics, and media gallery across projects.
- Add a collector network to project statistics.
- Project summaries show N counts, specimen part totals, and per-category
  summaries, with pagination.
- Add interface translations (beta) for Spanish, Portuguese, and Indonesian.
- Parasites gain a collector, date determined, and determination method. The
  identifier is now the determiner.
- Add custom labels and an editable project tool list.
- Separate Go to page from record search.
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
  show for bats. The `General Mammals`, `Bats`, and `Non-Bat Mammals` labels
  keep working.
- Desktop maps no longer use an embedded web view. Linux gains vector
  basemaps.

### Fixes

- Speed up the dashboard, gallery, lookup, and personnel loading.
- Fix the network jumping during layout.
- Fix text overflow and color contrast (WCAG) issues.
- Fix the database not closing cleanly on exit.

## v1.1.0 [2026-10-18]

### Features

- Add the Ichthyology catalog format (beta). A fish record is one individual,
  with standard length, total length, and weight, or a lot with a count and
  min/max ranges. Lot ranges can follow measured individuals, and the form
  shows their mean and standard deviation.
- Record individuals within a lot, with a tag ID, lengths, weight, sex, life
  stage, and remarks, and link specimen parts and parasites to them.
- Auto-number individual tag IDs with a prefix, zero-padded number, and
  suffix, set in Ichthyology specimen settings. A typed tag overrides the
  number without using it up.
- Tissue IDs gain a suffix and keep their zero padding, so `M0042-T` is
  followed by `M0043-T`. Existing counters carry over.
- Add conductivity (µS/cm) and dissolved oxygen saturation (%) to
  environmental data. Environmental-field settings show each field's unit.
- Schema v23 adds `fishAttribute`, `specimenIndividual`,
  `specimenPartIndividual`, and `parasiteIndividual`. Project transfer format
  10 and record exchange format 7 carry the new records.

## v1.0.3 [2026-10-04]

### Fixes

- Fix statistics label names.
- Fix the add personnel button staying inactive after required fields are
  filled.
- Fix page navigation buttons hidden behind the Android navigation bar on
  tablets with the navigation rail.
- Project information opens as a bottom sheet on small screens.
- The Go to page sheet adds a button that opens the search form.

## v1.0.2 [2026-09-17]

### Fixes

- Auto-select a specimen's coordinates when its site has only one.
- Fix Android export missing on-device folder access in the file picker.
- Fix jerky scrolling when custom fields are shown.
- Improve button placement on small screens.
- Update macOS entitlements.
- Fix event invalidation in personnel roles.

## v1.0.1 [2026-09-13]

### Fixes

- Improve documentation and record statistics.
- Rename the arthropod catalog to invertebrates. The `arthropodAttribute`
  table becomes `invertebrateAttribute`, and specimens store the taxon group
  `Invertebrates`.
- Name catalog formats by discipline: Mammalogy, Ornithology, Herpetology, and
  Invertebrate zoology. Custom-field definitions migrate to the new names.
- Replace database backup management with a concise summary and action list.
- Improve UI consistency across the app.
- Fix missing personnel photos when restoring old backups.
- Clean up hint text.

## v1.0.0 [2026-09-02]

- First stable release.

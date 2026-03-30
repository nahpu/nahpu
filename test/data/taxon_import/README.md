# Taxon Import Manual Test Files

Use these files in the **Import Taxon** screen to verify parser behavior manually.

Canonical column format for tabular fixtures:

- `class`, `Order`, `family`, `genus`, `epithet`, `scientific name`, `common name`
- Required import fields are the first five columns.

- `comma.csv`: Standard CSV (`.csv` should parse as comma automatically).
- `speciesList.csv`: Baseline comma-delimited fixture with canonical columns.
- `speciesList.xlsx`: Excel version of the same baseline fixture.
- `tab.tsv`: Standard TSV (`.tsv` should parse as tab automatically).
- `semicolon.csv`: Semicolon-separated content with `.csv` extension (should fail automatic `.csv` parse, then work with override `Semicolon`).
- `pipe_unknown.txt`: Unknown extension with `|` delimiter (should be detected by hybrid auto detection).
- `double_pipe_unknown.txt`: Unknown extension with `||` delimiter (use advanced override with custom raw text: `||`).
- `ambiguous_unknown.txt`: Unknown extension with no clear delimiter (auto should fail and request custom delimiter).

Tip: In custom delimiter mode, you can type escaped values like `\t` for tab.

# NAHPU bundled documentation

The `info` tree contains app-only contextual help. The `cookbook` tree mirrors
the canonical Cookbook under `nahpu-docs/src/content/docs`.

Supported locale directories use alpha-2 codes: `en`, `pt`, `es`, and `id`.
Portuguese content follows Brazilian usage. Matching document paths must exist
in every locale.

Every documentation file starts with YAML front matter containing `title` and
`sidebar.order`. Cookbook category metadata lives in each category's
`index.md`. Recipes use `.mdoc` for the supported Markdoc components. Recipe
files use the same relative path and identical bytes in both repositories.

Day One, the getting-started walkthrough, lives only on the website at
`nahpu-docs/src/content/docs/<locale>/day-one.mdoc`. The app does not bundle
it; Cookbook pages link to it with full `https://nahpu.app/<locale>/day-one/`
URLs.

To check Cookbook parity from the app repository:

```sh
dart run tool/sync_cookbook.dart \
  --docs-root ../nahpu-docs \
  --check
```

Use `--write` instead of `--check` to copy canonical website files into the
app. The command never deletes extra files; remove obsolete files only after
reviewing the reported paths.

Flutter asset directory entries are not recursive. When adding a Cookbook
category, add its four locale directories to `pubspec.yaml`.

After building the website, validate Cookbook and Info links against
the rendered pages and section IDs from the website repository:

```sh
bun run check:doc-links --info-root <nahpu-root>/assets/docs/info
```

Recipes describe individual tasks; Info explains the current panel.

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

`<locale>/day-one.mdoc` is the Day One walkthrough, mirrored from
`nahpu-docs/src/content/docs/<locale>/day-one.mdoc`. It sits at the locale root
rather than in a category, and the Cookbook screen shows it above the recipe
categories. It is the one file the sync rewrites: the website links to itself
with root-absolute paths, which the app cannot resolve, so every `](/en/...)`
becomes a full `https://nahpu.app/en/...` URL on the way in. Edit the website
copy and re-run the sync; never hand-edit the app copy.

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

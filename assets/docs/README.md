# NAHPU bundled documentation

The `info` tree contains app-only contextual help. The `cookbook` tree mirrors
the canonical Cookbook under `nahpu-docs/src/content/docs`.

Supported locale directories use alpha-2 codes: `en`, `pt`, `es`, and `id`.
Portuguese content follows Brazilian usage. Matching document paths must exist
in every locale.

Every Markdown document starts with YAML front matter containing `title` and
`sidebar.order`. Cookbook category metadata lives in each category's
`index.md`. Recipe files use the same path and identical bytes in both
repositories.

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

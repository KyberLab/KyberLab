## Why

The current `kyberlab init` command only works from the KyberLab repository root and forces workspace creation under `build/<board>`. Users may want to initialize workspaces from arbitrary directories (e.g., when working with custom workspace repos, shared locations, or alternative directory structures). This limitation prevents flexibility in workspace management and forces a specific layout that may not suit all use cases.

## What Changes

- **BREAKING**: The `kyberlab init` command will now work from any directory, not just the KyberLab repo root.
- When run from inside the KyberLab repo (detected by presence of `manifests/` and `template/`), workspace is created at `<repo_root>/build/<board>` (current behavior preserved).
- When run from outside the KyberLab repo, workspace is created at `./<board>` relative to the current working directory.
- The context detection logic will differentiate between repo-root, workspace, and arbitrary directory more explicitly.
- The `require_repo_root()` check for `init` command will be removed or made conditional.
- The `detect_plat()` function needs to accept the manifest path differently when not in repo root.

## Capabilities

### New Capabilities

- `workspace-init`: Enhanced initialization logic that supports both repository-root and arbitrary-directory workflows, with dynamic manifest resolution.

## Impact

- Modified files: `kyberlab` CLI script (main)
- Affected code: `detect_context()`, `require_repo_root()`, `do_init()`, `detect_plat()`
- No changes to existing workspace directories; only affects new initializations.
- Backward compatibility: existing workflow (running from repo root) remains unchanged.
- Users must ensure the KyberLab repo is accessible (via URL) when initializing from outside the repo.

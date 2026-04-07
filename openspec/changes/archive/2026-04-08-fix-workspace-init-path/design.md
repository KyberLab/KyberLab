## Context

The `kyberlab init` command currently requires execution from the KyberLab repository root. It creates a workspace at `<repo_root>/build/<board>` and uses local manifests. Users want to initialize workspaces from arbitrary directories, e.g., when using a shared location or custom repository layout. The current code in `kyberlab`:

- `detect_context()` walks up to find repo root or workspace.
- `require_repo_root()` blocks init unless context is `CONTEXT_REPO`.
- `do_init()` uses `repo_root` for workspace path and manifest lookup.

## Goals

- **Primary**: Allow `kyberlab init` to run from any directory (outside the KyberLab repo).
- Preserve existing behavior when run from the repo root.
- When outside repo, create workspace at `./<board>` relative to current directory.
- Support custom repository URLs via `-u` and `-b` flags.
- Do not require local manifests when initializing from outside the repo.
- No automatic build/docker build after initialization (already not present, but clarify as non-goal).

## Non-Goals

- Modify workspace structure after creation.
- Support initialization inside an existing workspace (should error).
- Change the manifest organization or add new platforms.
- Provide offline manifest resolution when outside repo (requires network).
- Add interactive prompts for missing parameters beyond current defaults.

## Decisions

### 1. Context handling and validation

We will modify `main()` to allow `init` in both `CONTEXT_REPO` and `CONTEXT_UNKNOWN` contexts. If context is `CONTEXT_WORKSPACE`, we error with a clear message.

**Rationale**: `detect_context()` already distinguishes these cases. By removing the `require_repo_root()` call we enable flexibility. The init logic itself needs to be aware of the context to adjust paths.

### 2. Workspace path determination

In `do_init()`, decide workspace location:
- If `context == CONTEXT_REPO`: `workspace = os.path.join(repo_root, "build", board)`
- If `context == CONTEXT_UNKNOWN`: `workspace = os.path.join(cwd, board)`

The `cwd` used is the directory where the command is executed (not the repo root).

**Rationale**: Matches user request: outside repo → `./<board>`. Inside repo keeps current path. Simple and backward compatible.

### 3. Manifest resolution for unknown context

When context is `CONTEXT_UNKNOWN`, we cannot use local manifests. We must construct a remote manifest URL. The user provides `-u URL` (default: KyberLab GitHub). The manifest path is `manifests/<platform>/<board>/<config>.xml`. We need `<platform>`.

Instead of auto-detecting platform via local scan, we will require the user to specify it with a new required flag `-p PLATFORM` when not in repo root. For example: `kyberlab init -d virt-aarch64 -p qemu`.

**Rationale**: Platform information is only locally available if we have manifests. Forcing the user to explicitly state the platform is clear and avoids brittle heuristics. It's a small additional argument that makes the command work.

**Alternatives considered**:
- Attempt to fetch manifest tree from remote to detect platform: adds network round-trip and complexity, may fail.
- Hardcode a mapping from board to platform: maintenance burden and may be incomplete.

### 4. Refactoring `do_init()` signature

`do_init()` currently receives `repo_root`. We'll change it to receive `(args, base_dir, context, platform=None)` where:
- `base_dir` is the directory where workspace should be created (repo_root for repo context; cwd for unknown).
- `platform` is required for unknown context, optional (auto-detected) for repo context.

**Rationale**: Clean separation between context and filesystem locations.

### 5. Error handling and user guidance

When `init` is invoked from a workspace (`CONTEXT_WORKSPACE`), we error:
```
Error: Cannot initialize a workspace from inside an existing workspace.
Please run 'kyberlab init' from the KyberLab repo root or another empty directory.
```

When `init` is invoked from unknown context without `-p`, error:
```
Error: When initializing from outside the KyberLab repository, the -p/--platform flag is required.
Usage: kyberlab init -d <board> -p <platform> [-u <url>] [-b <branch>] [-m <config>]
```

**Rationale**: Clear guidance prevents user confusion.

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Users forget `-p` flag when outside repo, leading to errors. | Provide clear error with usage hint. |
| Platform mismatch if user specifies wrong platform. | Document platform names; suggest checking manifests in KyberLab repo. |
| Remote manifest path may be incorrect if repo URL structure differs. | Use same path pattern as official repo; document requirement. |
| Breaking change: existing scripts assuming only repo-root init will break if they run from subdirectory of repo? Actually subdirectory of repo still has context REPO because `detect_context` walks up to find repo root. So it's fine. | No extra mitigation needed. |
| Users may expect `init` to auto-detect platform from board name. | Document the requirement; consider future enhancement to cache platform mapping. |

## Migration Plan

1. Release new version of KyberLab CLI with changes.
2. Update documentation (README, CLI help) to reflect new `-p/--platform` flag and usage from arbitrary directories.
3. No data migration needed; existing workspaces unaffected.
4. Communicate that `kyberlab init` from repo root remains unchanged; only new usage outside repo requires `-p`.

## Open Questions

- Should the `platform` argument have a short flag (e.g., `-P`)? Proposal: `-p` (consistent with other flags).
- Should we support an environment variable (e.g., `KYBERLAB_PLATFORM`) as fallback? Could reduce CLI noise but adds ambiguity. Keep simple for now.
- Should the `detect_context` treat a directory containing a `WorkSpace.mk` as `CONTEXT_WORKSPACE` even if it's also under a repo? It already returns workspace first. That's fine: `init` inside workspace should error.
- Should we auto-detect platform from the board if the board appears in only one platform? Could be a future enhancement using a static mapping file. Out of scope for initial implementation.

## 1. CLI Argument Parser

- [x] 1.1 Add `-p/--platform` argument to the `init` subparser in `build_parser()` with appropriate help text.
- [x] 1.2 Update the `help` output (REPO_HELP/UNKNOWN_HELP) to include the platform flag and its usage.

## 2. Context Handling in `main()`

- [x] 2.1 Remove the `require_repo_root(context)` call for the `init` command.
- [x] 2.2 Add explicit check: if `context == CONTEXT_WORKSPACE`, print error and exit.
- [x] 2.3 Determine `base_dir` and `context_type` to pass to `do_init()`:
  - For `CONTEXT_REPO`: `base_dir = repo_root`
  - For `CONTEXT_UNKNOWN`: `base_dir = cwd` (current working directory)

## 3. `do_init()` Refactoring

- [x] 3.1 Change function signature to `do_init(args, base_dir, context, platform=None)`.
- [x] 3.2 Compute workspace path: `workspace = os.path.join(base_dir, args.board)`.
- [x] 3.3 Platform resolution:
  - If `context == CONTEXT_REPO` and `platform` is None: auto-detect platform via `detect_plat(args.board, base_dir)`.
  - If `context == CONTEXT_UNKNOWN`: require `platform` is not None; if missing, error and exit.
- [x] 3.4 Construct manifest path:
  - For `CONTEXT_REPO`: `manifest_abs = os.path.join(base_dir, f"manifests/{plat}/{args.board}/{args.config}.xml")`
  - For `CONTEXT_UNKNOWN`: `manifest_rel = f"manifests/{platform}/{args.board}/{args.config}.xml"` (passed to `repo init -m` as relative path; `repo` fetches from the base URL).
- [x] 3.5 Adjust error messages to mention platform requirement when applicable.
- [x] 3.6 Keep the rest of the initialization logic (`repo init`, `repo sync`, submodule update, template copy) unchanged.

## 4. Error Messages and User Guidance

- [x] 4.1 Ensure error when running `init` inside a workspace is clear and suggests correct locations.
- [x] 4.2 Ensure error when `-p` missing in unknown context explains the requirement and shows example usage.
- [x] 4.3 Verify success message after init remains informative (show workspace path, next steps).

## 5. Documentation Updates

- [x] 5.1 Update `README.md` to describe the new `-p/--platform` flag and usage from arbitrary directories.
- [x] 5.2 Update `CLAUDE.md` if necessary to reflect the new behavior (especially the Common Commands section).
- [x] 5.3 Update the `kyberlab` script's help text strings (REPO_HELP, UNKNOWN_HELP) to include the platform flag.

## 6. Testing and Verification

- [x] 6.1 Test scenario: Run `kyberlab init` from repo root (no `-p`) → success, workspace at `build/<board>`.
- [x] 6.2 Test scenario: Run `kyberlab init -d <board> -p <platform>` from a temporary directory outside the repo → success, workspace at `./<board>`.
- [x] 6.3 Test scenario: Run `kyberlab init` from a workspace directory → appropriate error.
- [x] 6.4 Test scenario: Run `kyberlab init -d <board>` from outside repo without `-p` → error about missing platform.
- [x] 6.5 Test scenario: Provide custom `-u` and `-b` flags in unknown context → correct manifest resolution.
- [x] 6.6 Verify that after init, the workspace contains `.repo`, `WorkSpace.mk`, and template files as expected.
- [x] 6.7 Verify that no build commands are automatically triggered.

## 7. Rollback Considerations

- [x] 7.1 Ensure the changes are isolated to the `init` command and do not affect other commands (build phases, docker commands).
- [x] 7.2 Run the test suite (if any) to confirm no regressions in workspace detection and command dispatch.

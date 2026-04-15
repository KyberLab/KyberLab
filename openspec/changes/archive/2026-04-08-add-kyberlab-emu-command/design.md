## Context

The KyberLab CLI (`kyberlab` script) provides a unified interface for workspace operations. Currently, to run system images in QEMU, users must directly invoke `make emu` or `make emu_<image>` from the workspace. This breaks consistency with other kyberlab commands and requires manual management of the KyberEmu repository dependency.

Current state:
- Build phases: `build`, `fetch`, `patch`, `config`, `install`, `package`, `clean`, `distclean`
- Each phase supports auto-detection of IMAGE from current directory
- Docker commands: `dkbuild`, `dkrun`, `dkrund`, `dkexec`, `dkpin`

KyberEmu is a separate repository that must be present in `build/KyberEmu` to provide QEMU emulation capabilities. Workspaces can exist without KyberEmu initially, but attempting to run `make emu` without it fails.

**Constraints:**
- Stack: Python 3
- Must maintain backward compatibility
- Platform restriction: emu only works for qemu platform
- Technical constraint: KyberEmu may not be present in fresh workspaces

## Goals / Non-Goals

**Goals:**
- Add `kyberlab emu` command matching the UX of other build phase commands
- Auto-check KyberEmu dependency and initialize if missing
- Enforce qemu platform restriction
- Support both `kyberlab emu` (default image) and `kyberlab emu -i <image>`
- Maintain consistency with existing build phase patterns

**Non-Goals:**
- Support emu for non-qemu platforms (explicitly excluded)
- Modify the underlying `make emu` or `kyberemu_install` targets (assume they exist)
- Change KyberEmu repository structure or initialization process
- Add emu support to `make emu_<image>` individual targets (the CLI wrapper will handle it)

## Decisions

### 1. Add "emu" to BUILD_PHASES tuple

**Rationale:** Keeps consistent with existing build phase pattern. Users can use `-i IMAGE` option and benefit from auto-detection from current directory.

**Implementation:**
```python
BUILD_PHASES = ("build", "fetch", "patch", "config", "install",
                "package", "clean", "distclean", "emu")
```

**Alternatives considered:**
- Create a separate special-case command handler: Rejected because it would duplicate the auto-detection and argument handling logic already working for build phases.
- Add a separate DOCKER-style command: Not appropriate since emu is a build/run action, not a docker-related command.

### 2. Custom handler for "emu" command

**Rationale:** The emu command requires pre-execution checks that other build phases don't: (1) verify platform is qemu, (2) ensure KyberEmu exists, (3) run `kyberemu_install` if needed. This logic should be encapsulated.

**Implementation:**
- Replace the generic `elif args.command in BUILD_PHASES:` branch with a dispatch that checks for "emu" specifically
- Create a dedicated `do_emu` function that:
  a. Calls `require_workspace(context)`
  b. Detects image (auto-detect if -i not given)
  c. Checks platform is qemu (read from WorkSpace.mk or config)
  d. Verifies `build/KyberEmu` exists in workspace root
  e. If missing, run `make kyberemu_install`
  f. Call `run_make(target, work_dir)` with target=`emu_<image>` or `emu`

**Platform detection approach:**
Parse `WorkSpace.mk` to extract the `PLAT` variable value. The manifest used during `init` determines the platform (e.g., `manifests/qemu/virt-aarch64/default.xml` indicates qemu platform). We can read `WorkSpace.mk` and grep for `PLAT =` or similar variable.

**Alternatives considered:**
- Don't check platform, let `make emu` fail: Poor UX. The restriction should be enforced at CLI level per requirements.
- Check `manifests/` directory for qemu: Workspace could have been created with different plat. WorkSpace.mk is the authoritative source.

### 3. KyberEmu existence check

**Rationale:** The requirement explicitly states to verify KyberEmu repository and auto-initialize if missing.

**Implementation:**
```python
kyberemu_dir = os.path.join(work_dir, "build", "KyberEmu")
if not os.path.isdir(kyberemu_dir):
    print("[kyberlab] KyberEmu not found. Initializing...")
    run_make("kyberemu_install", work_dir)
```

**Alternatives considered:**
- Check via `repo` commands (e.g., `repo manifest`): More expensive, less direct.
- Assume KyberEmu exists if platform is qemu: Not sufficient, requires explicit init.

### 4. Error handling

If `make kyberemu_install` fails, `run_make` will exit with the error code (existing behavior). If platform is not qemu, print clear error: "Error: 'emu' command only supports qemu platform."

## Risks / Trade-offs

| Risk | Impact | Mitigation |
|------|--------|------------|
| Platform detection from WorkSpace.mk might be fragile if file format changes | Medium | Parse with regex that looks for `PLAT =` variable; error with helpful message if not found |
| `make kyberemu_install` might be slow, surprising first-time users | Medium | Print explanatory message before running install |
| Running `emu` from subdirectories might misdetect image | Low | Reuse existing `detect_image_from_cd` function which is proven |
| KyberEmu repo could be present but incomplete/corrupted | Medium | Only check directory existence; if `make emu` later fails, that's a secondary failure. Could enhance later with more robust check (e.g., checking for expected files) |
| Emu command may not be defined in all Makefiles (workspace-dependent) | Low | CLI doesn't define make targets; it invokes them. If missing, `make` will fail with standard error |

**Trade-offs:**
- We're adding a platform restriction at CLI level but not at make level. This means sophisticated users could still bypass it. That's acceptable — the restriction is a UX guardrail, not a security boundary.
- Auto-initialization of KyberEmu means `kyberlab emu` might take longer on first run. However, it's better than manual intervention.

## Migration Plan

**Deployment:**
1. Update the `kyberlab` script (main branch):
   - Add "emu" to BUILD_PHASES
   - Add `do_emu` function with KyberEmu check and platform validation
   - Modify main() dispatch to call `do_emu` for emu command
2. Update help text (WORKSPACE_HELP and UNKNOWN_HELP if needed) to document the new command
3. Test with a qemu workspace: verify `kyberlab emu` works with and without KyberEmu present
4. Ensure `kyberlab help` shows emu in the Build Commands section

**Rollback:**
- Revert changes to `kyberlab` script (remove emu from BUILD_PHASES, remove do_emu, restore generic dispatch)
- No data or build artifact changes; rollback is clean

**No migration path needed** — this is an additive change, existing users are unaffected unless they choose to use the new command.

## Open Questions

1. **How exactly is PLAT stored in WorkSpace.mk?** Need to examine typical workspace WorkSpace.mk to confirm variable name and format. (Answer: likely `PLAT = qemu` or similar. Must verify.)

2. **Does `make kyberemu_install` exist in all qemu workspaces?** This should be defined in the top-level Makefile framework. Need to check `image/Main.mk` or workspace Makefile includes.

3. **What if user provides `-i <image>` but the image doesn't support emu?** Should we validate? Probably not — let `make` fail with its standard error. The emu target may be defined per-image or globally.

4. **Should `kyberlab emu` run in background?** Unlike `dkrund` (detached), `emu` likely runs interactively and blocks (like `make emu` normally does). We'll keep default blocking behavior.

5. **Does KyberEmu need to be built before use?** The `make kyberemu_install` target likely builds it. Need to verify that after `kyberemu_install` completes, `make emu` can proceed directly.

## Context

KyberLab currently has a two-layer toolchain:

1. **The `kyberlab` CLI** (single Python file at repo root) — handles `help` and `init`
2. **The Makefile build system** (in each workspace) — handles all actual work (building images, Docker environments)

```
┌─────────────────────────────────────────────────────────┐
│                    User's shell                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  In repo root:                                          │
│    kyberlab init → mkdir, repo init, repo sync, cp     │
│                                                         │
│  In workspace:                                          │
│    make build          ← build default image            │
│    make busybox_build   ← build BusyBox image           │
│    make build_qemu      ← build Docker image            │
│    make run_qemu        ← run Docker container           │
│                                                         │
│  Problem: users must remember <TARGET>_<PHASE> naming  │
└─────────────────────────────────────────────────────────┘
```

The `kyberlab` CLI and Makefile system are disjointed — the CLI only works at the repo root, while all real work happens in workspaces via Make.

## Goals / Non-Goals

**Goals:**
- Unified CLI: `kyberlab` works from both repo root AND workspace directories
- Auto-detect: no flags needed to tell kyberlab where you are
- Make wrapper: all build/docker commands delegate to `make <TARGET>`
- From anywhere: `kyberlab build` works even from nested subdirectories within a workspace

**Non-Goals:**
- Replace the Makefile build system
- Add emulation (`emu`) commands (future work)
- Edit workspace config files directly
- Replace `kyberdocker` script

## Decisions

### Decision 1: Single file, no package

**Choice:** Keep `kyberlab` as a single Python file at the repo root. No `pyproject.toml`, no package structure.

**Why:** The existing tool is a single file with zero dependencies (stdlib only). Adding a package structure for a ~150 line script is over-engineering. This matches the Makefile philosophy where complexity lives in composition, not tooling.

### Decision 2: Context detection via file presence

**Choice:** Walk up the directory tree from `cwd` until finding a marker:

- **Workspace marker**: `WorkSpace.mk` file exists → workspace mode
- **Repo root marker**: `manifests/` AND `template/` directories exist → repo root mode

```
detect_context(cwd):
    path = cwd
    while path != /:
        if path/WorkSpace.mk exists:
            # Also find workspace root for make execution
            return WORKSPACE, workspace_root=path
        if path/manifests/ AND path/template/ exist:
            return REPO_ROOT, repo_root=path
        path = parent(path)
    return UNKNOWN, cwd
```

This allows running `kyberlab build` from `build/virt-aarch64/config/image/BusyBox/` — it walks up to find `WorkSpace.mk` at the workspace root.

**Alternatives considered:**
- Using an environment variable (`KYBERLAB_WORKSPACE`) — more brittle, requires setup
- Using a `.kyberlab` marker file — adds new files to the project

### Decision 3: Build and Docker commands as direct subcommands

**Choice:** Each build phase and docker operation is its own subcommand:

```
kyberlab build    [-i IMAGE]          # make <IMAGE>_build
kyberlab fetch    [-i IMAGE]          # make <IMAGE>_fetch
kyberlab patch    [-i IMAGE]          # make <IMAGE>_patch
kyberlab config   [-i IMAGE]          # make <IMAGE>_config
kyberlab install  [-i IMAGE]          # make <IMAGE>_install
kyberlab package  [-i IMAGE]          # make <IMAGE>_package
kyberlab clean    [-i IMAGE]          # make <IMAGE>_clean
kyberlab distclean [-i IMAGE]         # make <IMAGE>_distclean

kyberlab dkbuild  [-d DKNAME]           # make build_<DKNAME>
kyberlab dkrun    [-d DKNAME]           # make run_<DKNAME>
kyberlab dkrund   [-d DKNAME]           # make rund_<DKNAME>
kyberlab dkexec   [-d DKNAME]           # make exec_<DKNAME>
kyberlab dkpin    [-d DKNAME]           # make dockpin_<DKNAME>
```

`clean` and `distclean` use the same `-i` pattern as other phases — when `-i` is given or auto-detected, they run `<IMAGE>_<phase>`.

**Why:** Tab-completion friendly, discoverable via `kyberlab help`, and each command can have its own `-i`/`-d` help text.

### Decision 4: Make execution always from workspace root

**Choice:** When running `make` commands, `os.chdir()` to the workspace root first. This ensures `make` always finds the correct `Makefile` and includes.

### Decision 5: Auto-detect IMAGE and DKNAME from directory path

**Choice:** Three-level fallback chain for both `-i` and `-d`:

```
kyberlab build   (no -i):
  1. walk up from cwd → workspace root
  2. check each dir name against config/image/ contents (case-insensitive)
  3. if match found → use it as IMAGE
  4. if no match → make <phase> (image-less)

kyberlab dkbuild   (no -d):
  1. walk up from cwd → workspace root
  2. check each dir name against bench/image/dockerfile/ contents (case-insensitive)
  3. if match found → use it as DKNAME
  4. if no match → extract board name from build/<BOARD>/ path
  5. if still unknown → default to virt-aarch64
```

```
        cwd: config/image/BusyBox/drivers/        cwd: bench/image/dockerfile/qemu/
         │                                           │
         ├─── BusyBox (match! → IMAGE=BusyBox)       ├─── qemu (match! → DKNAME=qemu)
         ├─── image (no)                             ├─── dockerfile (no)
         ├─── config (no)                            ├─── image (no)
         └─── <workspace root> (stop)                └─── <workspace root> (stop)
```

Explicit `-i IMAGE` or `-d DKNAME` always overrides auto-detection.

**Alternatives considered:**
- Using CWD basename only (no walk-up) — too fragile, fails from nested dirs
- Scanning `config/image/` for every build (slow on large trees) — pre-load once, compare against path names only — fast O(1) per directory level

**Known risk:** Directory names may collide with image names (e.g., a user has a `Linux/` directory unrelated to the image). Case-insensitive match against the exact `config/image/` listing minimizes false positives.

## External Dependencies

```
┌──────────────────────────────────────────────┐
│               kyberlab (Python 3 stdlib)     │
├──────────────┬───────────────────────────────┤
│   argparse   │   CLI argument parsing        │
│   shutil     │   which(), copy2()            │
│   subprocess │   make invocation             │
│   os/sys     │   path walking, exit codes    │
└──────────────┴───────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────────────┐
│               Makefile system                │
├──────────────────────────────────────────────┤
│                                              │
│  make <PHASE>         (default image)        │
│  make <IMAGE>_<PHASE> (specific image)       │
│  make build_<DOCKER>  (Docker build)         │
│  make run_<DOCKER>    (Docker run)           │
│  make rund_<DOCKER>   (Docker run detached)  │
│  make exec_<DOCKER>   (Docker exec)          │
│                                              │
└──────────────────────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────────────┐
│   Makefile invokes:                          │
│   - repo (for init)                          │
│   - docker build/run                         │
│   - gcc/make/buildroot (for image builds)    │
│   - QEMU (for emulation)                     │
└──────────────────────────────────────────────┘
```

## Sequence: kyberlab build -i BusyBox

```
User                          kyberlab                           Makefile
  │                              │                                   │
  │── kyberlab build ──▶         │                                   │
  │   -i BusyBox      │          │                                   │
  │                   │──detect_context(cwd)                         │
  │                   │  walks up → finds WorkSpace.mk               │
  │                   │  → WORKSPACE mode, root=build/virt-aarch64   │
  │                   │                                              │
  │                   │──os.chdir(workspace_root)                    │
  │                   │                                              │
  │                   │──subprocess.call(                            │
  │                   │    ["make", "BusyBox_build"]                 │
  │                   │───▶│                                       │
  │                   │     │    [build process runs]               │
  │                   │◀───│                                       │
  │                   │  exit code                                 │
  │◀──────────────────│                                           │
```

## Sequence: kyberlab build (auto-detect, no -i)

```
User                          kyberlab                           Makefile
  │                              │                                   │
  │── kyberlab build ──▶         │                                   │
  │   (no -i flag)    │          │                                   │
  │                   │──detect_context(cwd)                         │
  │                   │  walks up → finds WorkSpace.mk               │
  │                   │  → WORKSPACE mode, root=build/virt-aarch64   │
  │                   │                                              │
  │                   │──detect_image_from_cwd(root, cwd)            │
  │                   │  walks up from cwd:                          │
  │                   │    config/image/BusyBox/drivers/             │
  │                   │      → "drivers" not in config/image/        │
  │                   │      → "BusyBox" MATCH → return "BusyBox"    │
  │                   │  IMAGE = "BusyBox"                           │
  │                   │                                              │
  │                   │──subprocess.call(                            │
  │                   │    ["make", "BusyBox_build"],                │
  │                   │    cwd=build/virt-aarch64)                   │
  │                   │───▶│                                       │
  │                   │     │    [build process runs]               │
  │                   │◀───│                                       │
  │                   │  exit code                                 │
  │◀──────────────────│                                           │
```

## Risks / Trade-offs

| Risk | Mitigation |
|------|-----------|
| Walking up directory tree is slow in deep paths | Walk is O(depth), typically < 10 levels — negligible |
| User runs `kyberlab build` outside any workspace | Clear error: "Not in a KyberLab repo root or workspace" |
| `-i IMAGE` typo causes make to fail | Make already handles unknown targets with error messages |
| Make output floods terminal with macro expansion | Passthrough stdout/stderr — user sees exactly what make does |
| Future addition of `emu` commands needs different arg handling | Extensible argparse structure, new subcommands add their own parsers |
| Directory name collision: user has `Linux/` dir unrelated to image | Case-insensitive match against exact `config/image/` listing; explicit `-i` always overrides |

## Migration Plan

1. Replace existing `kyberlab` single file with enhanced version
2. No migration needed — existing ` kyberlab help` and `kyberlab init` behavior unchanged
3. Existing `make` invocations continue to work — `kyberlab` is purely additive wrapper
4. Rollback: restore the previous `kyberlab` file

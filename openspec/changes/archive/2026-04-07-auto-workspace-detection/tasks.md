## 1. Context Detection

- [x] 1.1 Implement `detect_context()` function that walks up the directory tree from CWD, checking for `WorkSpace.mk` (WORKSPACE) or `manifests/` + `template/` (REPO_ROOT), returning context type and root path
- [x] 1.2 Add context detection to `main()` — run before any command dispatch, store result for all subcommands
- [x] 1.3 Update `do_init()` to use detected REPO_ROOT context, with error if not in repo root
- [x] 1.4 Verify context detection works from repo root, workspace root, and nested subdirectories

## 2. Contextual Help

- [x] 2.1 Create workspace-specific help text showing build phase and docker commands
- [x] 2.2 Update `cmd_help()` to display context-appropriate commands based on detection result
- [x] 2.3 Help in UNKNOWN context shows generic usage with error guidance

## 3. Build Phase Commands

- [x] 3.1 Add argparse subcommands for: `build`, `fetch`, `patch`, `config`, `install`, `package`, `clean`, `distclean`
- [x] 3.2 Each build subcommand accepts optional `-i IMAGE` flag
- [x] 3.3 Implement `do_build_phase()` function: validates WORKSPACE context, constructs `make <IMAGE>_<PHASE>` or `make <PHASE>` target, executes via subprocess from workspace root
- [x] 3.4 Verify `kyberlab build -i BusyBox` runs `make BusyBox_build` correctly
- [x] 3.5 Verify `kyberlab build` (no -i) runs `make build` correctly

## 4. Docker Commands

- [x] 4.1 Add argparse subcommands for: `dkbuild`, `dkrun`, `dkrund`, `dkexec`, `dkpin`
- [x] 4.2 Each docker subcommand accepts optional `-d NAME` flag, defaults to detected board name
- [x] 4.3 Implement `do_docker_command()` function: validates WORKSPACE context, constructs `make <ACTION>_<NAME>` target, executes via subprocess from workspace root
- [x] 4.4 Verify `kyberlab dkbuild -d develop` runs `make build_develop` correctly
- [x] 4.5 Verify `kyberlab dkrun` uses default board name

## 5. Cleanup and Verification

- [x] 5.1 Ensure all commands pass through proper exit codes from make/subprocess
- [x] 5.2 Test error paths: wrong context, missing make target, make failures

## Why

Currently, KyberLab users need to run `make emu` directly to launch system images in QEMU. This lacks consistency with the `kyberlab` CLI interface and requires manual setup of the KyberEmu repository. We need a unified `kyberlab emu` command that provides the same user experience as other kyberlab sub-commands while automatically handling the KyberEmu dependency.

## What Changes

- Add `kyberlab emu` sub-command to the CLI
- The command is restricted to `<PLAT>` = `qemu` `<BOARD>` configurations only
- Pre-execution check: verify `build/KyberEmu` repository exists in the workspace
- Auto-initialization: if KyberEmu is missing, run `make kyberemu_install` before proceeding
- Execute the emu build phase (runs the system image in QEMU)
- **BREAKING**: None - this is an additive change

## Capabilities

### New Capabilities
- `emu-command`: Introduction of the `kyberlab emu` sub-command with automatic KyberEmu dependency management

### Modified Capabilities
*(None - this is a new command, no existing capabilities modified)*

## Impact

- **Code**: Modifications to the KyberLab CLI main entry point (likely `kyberlab` script/command) and potentially the Makefile framework
- **Dependencies**: Requires KyberEmu repository as a build-time dependency for QEMU targets
- **User Workflow**: Users can now use `kyberlab emu` consistently with other kyberlab commands (dkbuild, dkrun, build, etc.)
- **Documentation**: Need to update CLI help text and user guides
- **Affected Teams**: Embedded developers using KyberLab for QEMU-based development, CLI maintainers

## Rollback Plan

If issues arise:
1. Remove the `emu` sub-command from the CLI code
2. Revert any Makefile changes related to `kyberemu_install` target
3. Users can continue using the existing `make emu` workflow directly
4. No migration path needed as this is an additive feature

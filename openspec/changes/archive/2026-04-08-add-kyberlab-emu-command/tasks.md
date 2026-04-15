## 1. CLI Parser and Constants Update

- [x]1.1 Add "emu" to BUILD_PHASES tuple in kyberlab script
- [x]1.2 Verify argument parser automatically adds emu subparser with -i option (handled by loop)

## 2. Platform Detection

- [x]2.1 Implement helper function `detect_plat_from_workspace(work_dir)` that reads WorkSpace.mk and extracts PLAT variable value
- [x]2.2 Add error handling for missing or malformed PLAT definition (print error and exit)

## 3. KyberEmu Dependency Check and Installation

- [x]3.1 Implement helper function `ensure_kyberemu(work_dir)` that:
  - Checks if `build/KyberEmu` directory exists
  - If missing, prints informative message and runs `make kyberemu_install`
  - Propagates errors if make fails
- [x]3.2 Test logic: verify function skips install when KyberEmu exists

## 4. Emu Command Handler

- [x]4.1 Implement `do_emu(image, context, work_dir)` function with following logic:
  - Call `require_workspace(context)`
  - Determine target: `f"emu_{image}"` if image specified, else `"emu"`
  - Call `detect_plat_from_workspace(work_dir)` and verify it equals "qemu"
  - Call `ensure_kyberemu(work_dir)`
  - Call `run_make(target, work_dir)`
- [x]4.2 Add appropriate error messages matching spec requirements

## 5. Main Dispatch Update

- [x]5.1 Modify `main()` function: replace generic `elif args.command in BUILD_PHASES:` branch with conditional dispatch
- [x]5.2 Add branch: `if args.command == "emu":` to call `do_emu(image, context, root)`
- [x]5.3 Keep existing `elif args.command in BUILD_PHASES:` for all other phases (excluding emu)

## 6. Help Text and Documentation

- [x]6.1 Update WORKSPACE_HELP string to include `kyberlab emu [-i IMAGE]` in Build Commands section
- [x]6.2 Add brief description: "Run image in QEMU (auto-installs KyberEmu if needed)"
- [x]6.3 Update UNKNOWN_HELP and REPO_HELP if emu is relevant in those contexts (likely not needed)
- [x]6.4 Ensure help output matches formatting style

## 7. Verification and Testing

- [x]7.1 Manual test: run `kyberlab emu` in a qemu workspace WITHOUT KyberEmu present:
  - Verify it prints initialization message
  - Verify `make kyberemu_install` runs
  - Verify `make emu` runs after install
- [x]7.2 Manual test: run `kyberlab emu` in a qemu workspace WITH KyberEmu present:
  - Verify it skips initialization
  - Verify `make emu` runs directly
- [x]7.3 Manual test: run `kyberlab emu` in a non-qemu workspace (if possible to simulate):
  - Verify it prints platform error and exits without running any make
- [x]7.4 Manual test: run `kyberlab emu -i BusyBox` from workspace root:
  - Verify it executes `make emu_BusyBox`
- [x]7.5 Verify `kyberlab help` shows emu command with correct description
- [x]7.6 Test from within an image config directory (e.g., `config/image/BusyBox/`) without -i flag to verify auto-detection

## 8. Code Quality

- [x]8.1 Review code for consistency with existing patterns in kyberlab script
- [x]8.2 Ensure all print messages are user-friendly and match style
- [x]8.3 Check for proper error handling and exit codes
- [x]8.4 Verify no changes to unrelated functionality

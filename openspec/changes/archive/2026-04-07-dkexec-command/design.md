## Context

Currently `dkexec` maps directly to `make exec_<NAME>` regardless of container state. For `dkpin` and other automated workflows, `exec` needs:
1. A detached container to exist and be running
2. An arbitrary command (via USER_RUN_CMD env var) instead of always opening an interactive shell

## Goals / Non-Goals

**Goals:**
- `dkexec` checks if the target container is running before invoking make
- `dkexec` supports `-c USER_RUN_CMD` to pass commands via make `USER_RUN_CMD=` env var
- Auto-detect container name from cwd works same as before

**Non-Goals:**
- Auto-start the container if not running
- Other docker commands (dkbuild/dkrun/dkrund/dkpin) need this check

## Decisions

### Decision 1: Container running check via `docker ps`

**Choice:** Before `dkexec`, run `docker ps --filter name=<NAME> --filter status=running --quiet`. If empty, container is not running.

```
do_docker_command("dkexec", name, context, work_dir):
    require_workspace(context)
    if not is_container_running(name, work_dir):
        print error + suggest "kyberlab dkrund -d <name>"
        exit(1)
    if cmd:
        subprocess.call(["make", f"USER_RUN_CMD={cmd}", target], cwd=work_dir)
    else:
        subprocess.call(["make", target], cwd=work_dir)
```

**Why `docker ps` over `docker inspect`:** `docker ps --filter status=running` directly answers "is it running?" in one command. `docker inspect` returns state as JSON requiring parsing.

**Alternatives considered:**
- `docker inspect --format '{{.State.Running}}' <NAME>` — works but slower and more complex to parse
- `docker top <NAME>` — returns error code but stderr is noisy

### Decision 2: USER_RUN_CMD passed as make env var with quoting

**Choice:** Use subprocess.call with `"USER_RUN_CMD={value}"` as a positional arg before the target. Docker and make both handle the value as-is, no escaping needed in the Python layer.

```python
subprocess.call(["make", f"USER_RUN_CMD={user_value}", "exec_develop"], cwd=work_dir)
```

The value is passed literally — shell interpretation happens inside the container's make context.

## Risks / Trade-offs

| Risk | Mitigation |
|------|-----------|
| Container name collision (multiple containers with same name) | `docker ps` matches by name prefix; if ambiguous, make fails with its own error |
| User runs `dkexec` without `-c` and gets interactive shell anyway | This is expected behavior — without `-c`, `make exec_<NAME>` defaults to interactive |
| Make macro doesn't support USER_RUN_CMD variable | Upstream Makefile must define USER_RUN_CMD support in exec rules — outside kyberlab's scope |

# Proposal: Add `-c USER_RUN_CMD` Option to `dkexec` Subcommand

## Problem

The `dkpin` command needs the ability to execute specific commands inside running containers. Currently, `dkexec` only runs `make exec_<NAME>` which likely starts an interactive shell. For `dkpin` to work, it needs to run `make exec_<NAME> USER_RUN_CMD="<command>"`.

## What To Build

Add a `-c USER_RUN_CMD` option to the `kyberlab dkexec` command, allowing users to run arbitrary commands inside a running container:

```bash
kyberlab dkexec -d develop -c "ls -la /workspace"
kyberlab dkexec -c "make clean"   # auto-detected name from cwd
```

This maps to: `make exec_<NAME> USER_RUN_CMD="<command>"`

## Why

1. `dkpin` needs to run pinning commands inside containers, not interactive shells
2. General utility for running one-off commands in Docker workbenches
3. CI/CD automation needs non-interactive container exec

## Scope

### In Scope
- `-c USER_RUN_CMD` flag on `dkexec` subcommand only
- Passes through to make as `USER_RUN_CMD=<value>` environment variable
- Works with auto-detected and explicit `-d NAME`

### Out of Scope
- Other docker commands don't need `-c USER_RUN_CMD`
- Shell quoting/validation delegated to make

## Rollback Plan

Remove the `-c USER_RUN_CMD` option from dkexec. Existing `dkexec -d NAME` behavior unchanged.

## Affected Teams

- KyberDev team members running commands in containers
- CI/CD pipelines using `kyberlab dkexec`

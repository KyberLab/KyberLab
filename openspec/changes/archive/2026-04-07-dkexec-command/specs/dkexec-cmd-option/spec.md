## ADDED Requirements

### Requirement: User-specified command via `-c CMD`
The `kyberlab dkexec` command MUST accept an optional `-c CMD` argument. When provided, the make target is invoked with the `USER_RUN_CMD` variable set: `USER_RUN_CMD=<value> exec_<NAME>`. If `-c CMD` is not provided, `make exec_<NAME>` is executed without `USER_RUN_CMD` (default interactive behavior).

#### Scenario: Run command with -c flag
- **WHEN** user runs `kyberlab dkexec -d develop -c "echo hello"`
- **THEN** `make USER_RUN_CMD="echo hello" exec_develop` is executed

#### Scenario: Auto-detect name with -c flag
- **WHEN** user runs `kyberlab dkexec -c "ls -la"` from inside `bench/image/dockerfile/develop/`
- **THEN** `make USER_RUN_CMD="ls -la" exec_develop` is executed

#### Scenario: dkexec without -c flag
- **WHEN** user runs `kyberlab dkexec -d develop`
- **THEN** `make exec_develop` is executed without `USER_RUN_CMD` (interactive shell)

### Requirement: USER_RUN_CMD passed as make variable
The CMD value MUST be passed as a make variable: `make USER_RUN_CMD=<value> exec_<NAME>`.

#### Scenario: USER_RUN_CMD with spaces
- **WHEN** user runs `kyberlab dkexec -d develop -c "cd /workspace && ls -la"`
- **THEN** `make USER_RUN_CMD="cd /workspace && ls -la" exec_develop` is executed

### Requirement: dkexec requires detached container
Before executing `dkexec`, the CLI MUST check whether a container with the target name is running in the workspace. If not running, the user MUST be advised to start it first with `kyberlab dkrund -d <NAME>`.

#### Scenario: Container not running
- **WHEN** user runs `kyberlab dkexec -d develop -c "echo hello"` and the develop container is not running
- **THEN** error: "Container '<NAME>' is not running. Start it first with: kyberlab dkrund -d <NAME>"

#### Scenario: Container is running
- **WHEN** user runs `kyberlab dkexec -d develop -c "echo hello"` and the container is running
- **THEN** `make USER_RUN_CMD="echo hello" exec_develop` executes normally

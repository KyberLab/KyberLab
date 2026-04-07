## 1. Container running check before dkexec

- [x] 1.1 Add `is_container_running(name)` function that checks if a container named NAME is running under the current workspace using `docker ps --filter`
- [x] 1.2 Update `do_docker_command()` for `dkexec` to check container running state before invoking make
- [x] 1.3 Show clear error when container not running: "Container '<NAME>' is not running. Start it first with: kyberlab dkrund -d <NAME>"

## 2. Add -c USER_RUN_CMD to dkexec

- [x] 2.1 Add `-c USER_RUN_CMD` argument to `dkexec` subcommand parser
- [x] 2.2 Update `do_docker_command()` to pass USER_RUN_CMD as make environment variable when `-c` is provided
- [x] 2.3 Verify `kyberlab dkexec -d develop -c "echo hello"` runs `make USER_RUN_CMD="echo hello" exec_develop`
- [x] 2.4 Verify `kyberlab dkexec -d develop` (no -c) still works as before

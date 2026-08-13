. "$HOME/.cargo/env"

# Testcontainers + Colima: Ryuk bind-mounts the daemon socket, and Colima's host-side path
# (~/.colima/default/docker.sock) is not a real path inside the Lima VM. The daemon endpoint
# itself comes from docker.host in ~/.testcontainers.properties; this has no properties-file
# equivalent, so it has to be an env var. In .zshenv rather than .zshrc so non-interactive
# shells (scripts, IDE-launched test runs) get it too.
export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE=/var/run/docker.sock

# bash-toolkit

A collection of bash aliases, scripts, and kubectl plugins for day-to-day DevOps and platform engineering work.

## Structure

```
bash-toolkit/
├── bashrc/          # Shell aliases to source in .bashrc / .zshrc
├── plugins/
│   ├── k8s/         # kubectl plugins (installed via kubectl <plugin>)
│   └── install-kubectl-plugins.sh
└── scripts/         # Standalone utility scripts
    ├── git/
    ├── github/
    ├── k8s/
    ├── postgres/
    └── system/
```

## Aliases

Source individual files from your `.bashrc` or `.zshrc`:

```bash
source ~/bash-toolkit/bashrc/aliases.sh
source ~/bash-toolkit/bashrc/aliases-git.sh
source ~/bash-toolkit/bashrc/aliases-kubectl.sh
source ~/bash-toolkit/bashrc/aliases-docker.sh
source ~/bash-toolkit/bashrc/aliases-terraform.sh
```

### General (`aliases.sh`)

| Alias | Command | Description |
|-------|---------|-------------|
| `ll` | `ls -lah --color=auto` | Detailed listing with human-readable sizes |
| `df` | `df -hT` | Human-readable disk usage with filesystem type |
| `du` | `du -sh * \| sort -h` | Folder sizes, sorted |
| `ports` | `ss -tulnp` | Listening ports and processes |
| `myip` | `curl -s ifconfig.me` | External IP address |
| `now` | `date +"%Y-%m-%d %H:%M:%S"` | Current timestamp |

### Git (`aliases-git.sh`)

| Alias | Command | Description |
|-------|---------|-------------|
| `gs` | `git status` | |
| `gl` | `git log --oneline --graph --decorate` | Pretty log |
| `gla` | `git log --oneline --graph --all --decorate` | All branches |
| `gd` / `gds` | `git diff` / `git diff --staged` | |
| `gcb` | `git checkout -b` | Create and switch branch |
| `gpf` | `git push --force-with-lease` | Safer force push |

### kubectl (`aliases-kubectl.sh`)

| Alias | Command |
|-------|---------|
| `k` | `kubectl` |
| `kg` | `kubectl get` |
| `kd` | `kubectl describe` |
| `kgpods` | `kubectl get pods` |
| `kgpoall` | `kubectl get pods --all-namespaces` |
| `krr` | `kubectl rollout restart` |
| `kbash` | `kubectl exec -it $1 -- /bin/bash` |
| `kns` | `kubens` (requires [kubectx](https://github.com/ahmetb/kubectx)) |
| `kctx` | `kubectx` (requires [kubectx](https://github.com/ahmetb/kubectx)) |
| `s` | `switch` (requires [kubeswitch](https://github.com/danielfoehrKn/kubeswitch)) |

### Docker (`aliases-docker.sh`)

| Alias | Command |
|-------|---------|
| `d` | `docker` |
| `dps` / `dpsa` | `docker ps` / `docker ps -a` |
| `dex` | `docker exec -it $1 /bin/bash` |
| `dc` | `docker-compose` |
| `dcu` / `dcd` | `docker-compose up` / `docker-compose down` |
| `dclimg` | Remove dangling images |

### Terraform (`aliases-terraform.sh`)

| Alias | Command |
|-------|---------|
| `tf` | `terraform` |
| `tfi` / `tfp` / `tfa` | `init` / `plan` / `apply` |
| `tfaa` | `terraform apply -auto-approve` |
| `tfd` | `terraform destroy` |
| `tfw` / `tfs` | `workspace` / `state` |

---

## kubectl Plugins

Custom plugins that extend `kubectl`. Install them with:

```bash
cd plugins
./install-kubectl-plugins.sh
```

This copies the plugins to `/usr/local/bin` so they are available as `kubectl <plugin>`.

| Plugin | Usage | Description |
|--------|-------|-------------|
| `kubectl-env-search` | `kubectl env-search <VAR>` | Find all pods across namespaces that have a specific env var |
| `kubectl-failing` | `kubectl failing` | List deployments with unavailable replicas |
| `kubectl-images` | `kubectl images` | List all unique container images running in the cluster |
| `kubectl-pod-debug` | `kubectl pod-debug <pod> [namespace]` | Describe a pod, tail its logs, and show related events |
| `kubectl-restarts` | `kubectl restarts` | List all pods with restart counts > 0 |
| `kubectl-shell` | `kubectl shell [namespace]` | Interactive pod selector that opens a shell |

---

## Scripts

### Kubernetes (`scripts/k8s/`)

| Script | Description |
|--------|-------------|
| `debug-pod.sh` | Launch a throwaway busybox pod for cluster-side debugging |
| `decode-secret.sh` | Base64-decode all fields of a Kubernetes secret |
| `delete-crashloop-pods.sh` | Delete all pods in CrashLoopBackOff |
| `dns-check.sh` | Test DNS resolution and HTTP reachability from inside the cluster |
| `exec-deployment.sh` | Run a shell command across all running pods in a deployment |
| `failing-deployments.sh` | Deployments with unavailable replicas |
| `hpa-status.sh` | Show HPA current vs. target metrics and recent scaling events |
| `image-pull-errors.sh` | Find pods stuck in ErrImagePull / ImagePullBackOff |
| `ingress-debug.sh` | Show an ingress, backend services, endpoints, and TLS status |
| `k8s-health-check.sh` | Cluster overview: node status, non-running pods, CPU usage, recent warnings |
| `logs-deployment.sh` | Stream logs from all pods of a deployment |
| `netdebug-pod.sh` | Launch a netshoot pod with curl, dig, tcpdump, nmap, iperf3, etc. (optional `--node` targeting) |
| `node-debug.sh` | Launch a privileged pod on a node with the host filesystem mounted at `/host` |
| `node-drain-check.sh` | Preview pods to evict, DaemonSets, and PDB blockers before draining a node |
| `node-pods.sh` | List all pods scheduled on a specific node |
| `node-pressure.sh` | Show nodes with MemoryPressure / DiskPressure / PIDPressure and a full condition summary |
| `node-resources.sh` | Node resource requests vs. limits |
| `node-taints.sh` | Show all node taints and pods with matching tolerations |
| `oom-killed.sh` | List pods that have been OOMKilled with memory limits and restart counts |
| `pending-pods.sh` | Show pending pods and events explaining why they are stuck |
| `pod-connectivity.sh` | Test TCP connectivity from a pod to a target host:port |
| `pod-trace.sh` | All-in-one pod debugger: describe, all container logs (current + previous), and events |
| `port-forward-deployment.sh` | Port-forward to a deployment |
| `pvc-debug.sh` | Show PVC status, bound PV details, storage class, and events |
| `rbac-check.sh` | Show effective permissions for a service account (can-i list + role bindings) |
| `resource-audit.sh` | Pods missing resource requests/limits |
| `search-env.sh` | Search env vars across pods |
| `service-pods.sh` | List pods backing a service |
| `top-pods.sh` | Top N pods by CPU or memory across all namespaces (`cpu`\|`mem`, default: cpu, 20) |

### Git (`scripts/git/`)

| Script | Description |
|--------|-------------|
| `git-clean-merged.sh` | Delete local branches already merged into main |
| `git-pull-dirs.sh` | `git pull` on all subdirectories (switch to main first) |

### GitHub (`scripts/github/`)

All scripts require the `gh` CLI. Scripts that operate on an org accept `<org>` as the first argument or via the `ORG` env var.

| Script | Description |
|--------|-------------|
| `gh-failed-runs.sh` | Repos in an org whose default-branch workflow run is failing |
| `gh-pr-queue.sh` | List all open PRs across an org with author, age, and review status |
| `gh-release-notes.sh` | Generate a changelog of merged PRs between two tags |
| `gh-repo-audit.sh` | Audit branch protection, CODEOWNERS presence, and required review counts |
| `gh-rerun-failed.sh` | Re-run failed jobs on the latest failed workflow run for a repo |
| `gh-secret-names.sh` | List all secret names (not values) at org and repo level |
| `gh-stale-branches.sh` | Branches with no commits in N days for a repo (default: 30) |
| `gh-stale-prs.sh` | Open PRs with no activity in N days (default: 14) |
| `update-org-repo-settings.sh` | Enable "delete branch on merge" across all repos in a GitHub org |

### System (`scripts/system/`)

| Script | Description |
|--------|-------------|
| `disk-usage.sh` | Top disk consumers |
| `port-check.sh` | Check if a port is open on a host |
| `port-scan.sh` | Scan common ports on a host |
| `process-search.sh` | Find processes by name |
| `system-info.sh` | OS, CPU, memory, and disk summary |

### Postgres (`scripts/postgres/`)

These scripts connect to a Postgres instance via K8s port-forwarding through pgbouncer. They read credentials from a Kubernetes secret and set up the `psql` environment automatically.

**Usage:** `<script> <db_name> <secret> [namespace] [target] [local_port] [db_user_key] [db_pass_key]`

| Script | Description |
|--------|-------------|
| `pg-connections.sh` | Active connections grouped by database, user, client address, and state |
| `pg-db-sizes.sh` | Size of all databases |
| `pg-dump.sh` | Dump a database to a gzipped SQL file |
| `pg-list-databases.sh` | List all non-template databases (uses `PGHOST`/`PGPORT` env vars) |
| `pg-restore.sh` | Restore a gzipped SQL dump into a database |
| `pg-shell.sh` | Open an interactive psql shell |
| `pg-table-sizes.sh` | Top 20 tables by total size |
| `pg-top-queries.sh` | Top 10 running queries by duration |
| `pg-vacuum-report.sh` | Tables with the most dead tuples (vacuum candidates) |

### Other

| Script | Description |
|--------|-------------|
| `d64.sh` | Decode a base64 string |
| `docker-clean.sh` | Remove stopped containers, unused images, and volumes |
| `log-analyzer.sh` | Summarize top ERROR and WARN messages from a log file |

---

## Requirements

- bash 4+
- `kubectl` for K8s aliases and plugins
- `jq` for plugins that parse JSON output
- `gh` CLI for GitHub scripts
- Optional: [kubectx / kubens](https://github.com/ahmetb/kubectx), [kubeswitch](https://github.com/danielfoehrKn/kubeswitch)

# Pull request workflow

Each iteration starts from `main`, creates a unique topic branch, appends one line to `activity_log.txt`, commits and pushes the branch, and asks GitHub CLI to create a pull request against `main`. It then merges the pull request with a merge commit, switches back to `main`, and fast-forwards from `origin`.

The script requires a clean working tree before a real run so that unrelated local work is not included in the automation. The first real run can create and push an empty initial commit if neither local history nor remote `main` exists. Subsequent runs use the existing `main` branch.

Try a non-destructive preview first:

```bash
DRY_RUN=true bash script.sh 1
```

Then, only if you intend to perform the GitHub operations, run one iteration:

```bash
bash script.sh 1
```

The script defaults to 1024 iterations when no count is supplied, so always pass a small explicit number while learning. If a command fails, inspect the repository and any open pull request before retrying; an unmerged branch may remain on the remote.

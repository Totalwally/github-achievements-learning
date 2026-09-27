# How it works

`script.sh` is a Bash learning example that performs one iteration for each requested pull request:

1. Reads optional local settings from `config.sh`, validates the requested count, and locates the Git repository and `origin`.
2. In a real run, verifies that the working tree is clean, checks GitHub CLI authentication and repository access, and prepares the `main` branch. If the repository has no commit and no remote `main`, it creates an empty initial commit and pushes `main`.
3. Creates a uniquely named branch from `main`.
4. Appends a UTC timestamped line to `activity_log.txt` and commits the educational change.
5. Pushes the branch, creates a pull request targeting `main`, and merges it using a merge commit through GitHub CLI.
6. Returns to `main`, fast-forwards from `origin`, and proceeds to the next iteration.

The script stops when a command fails and reports the error. Its exit cleanup attempts to return to `main`; a failed pull request or merge may leave a remote topic branch or an open pull request that needs manual attention. The script does not delete a failed/unmerged topic branch.

Use `DRY_RUN=true bash script.sh 1` or `bash script.sh --dry-run 1` to preview without file changes, branch creation, commits, authentication checks, or network calls. A real run checks authentication and repository access before making changes. For a real test, explicitly pass `1`; omitting the count defaults to 1024.

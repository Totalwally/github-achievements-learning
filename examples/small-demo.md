# One-PR demo

This demo previews one iteration, then shows the command for one real pull request. The preview is non-destructive; the second command pushes a branch and creates and merges a real pull request.

From a clone of this repository, first confirm `origin` and authenticate GitHub CLI for the real run:

```bash
git remote -v
gh auth status
```

Preview without changing the repository or contacting GitHub:

```bash
DRY_RUN=true bash script.sh 1
```

To perform the single real iteration, after checking that you want the change merged into `main`:

```bash
bash script.sh 1
```

After a successful run, the merged `activity_log.txt` contains one timestamped entry and the current branch is `main`. Omitting `1` would use the script's default of 1024 iterations. Neither the demo nor a successful merge guarantees an achievement.

<p align="center">
  <img src="assets/readme-banner.svg" alt="GitHub Pull Request Automation Learning Lab banner" width="1400" />
</p>

**I'm Wally**

This repository is an educational Bash lab for learning how Git, GitHub CLI, branches, and pull requests fit together. The script makes a small, timestamped change, publishes a branch, opens a pull request, and merges it while you learn how the GitHub workflow works.

## Requirements

- Bash and Git
- [GitHub CLI (`gh`)](https://cli.github.com/) installed and authenticated with `gh auth login` for a real run
- An `origin` remote pointing to a GitHub repository where your account can push branches, create pull requests, and merge them
- The repository's `main` branch must allow the merge method used by the script (merge commits)

The script checks the working tree, GitHub CLI authentication, repository access, and the `origin` remote before making changes. It uses `main` as its base branch. If there is no commit or remote, it exits before making changes.

## Safe test

Preview one iteration without changing files, branches, or GitHub:

```bash
DRY_RUN=true bash script.sh 1
```

or:

```bash
bash script.sh --dry-run 1
```

A dry run checks the local Git repository and `origin`, then prints what a real run would do. It does not require GitHub CLI authentication because it does not contact GitHub or execute any remote actions.

When ready to create exactly one real pull request, run:

```bash
bash script.sh 1
```

This is a real operation: it pushes a branch, opens a pull request, and merges it. Review the repository permissions and branch rules first. The script does not ask for confirmation once started.

## Configure the number of pull requests

Pass a positive count as the argument:

```bash
bash script.sh 5
```

When explicitly run without a count, the script defaults to **1024**. Do not use that default casually: it can create and merge a very large number of pull requests. The script never runs automatically without an explicit command.

For local defaults, copy `config.example.sh` to `config.sh` and edit its settings. `config.sh` is ignored by Git. Command-line PR count overrides `PR_COUNT` in that file. Supported settings are `PR_COUNT`, `BRANCH_PREFIX`, and `COMMIT_MESSAGE`.

## Pull Shark and achievements

Pull Shark is a GitHub achievement associated with getting pull requests merged. GitHub determines achievement eligibility and may apply requirements or limits that change over time. Running this script is educational and should be treated as a learning exercise rather than a guarantee of any achievement.

## Learning materials

- [How the automation works](docs/how-it-works.md)
- [GitHub CLI basics](docs/github-cli.md)
- [Pull request workflow](docs/pull-request-workflow.md)
- [Co-authored commits](docs/co-authored-commits.md)
- [Achievements and Pull Shark](docs/achievements.md)
- [One-PR demo](examples/small-demo.md)

`activity_log.txt` is created by a real run and records the timestamped educational change included in each pull request.

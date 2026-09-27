# GitHub CLI

[GitHub CLI](https://cli.github.com/) (`gh`) lets the script interact with GitHub without manually calling the web API. The script uses it to verify authentication and repository access, create pull requests, and merge them.

Install `gh` using the instructions for your operating system, then authenticate:

```bash
gh auth login
gh auth status
```

The authenticated account needs permission to push to the repository, create pull requests, and merge them. Repository rules, required checks, reviews, or disabled merge commits can prevent the scripted merge. The script does not bypass those rules.

The repository must have an `origin` remote that Git can reach. Check it with:

```bash
git remote -v
gh repo view
```

The script does not store credentials or tokens in its files. GitHub CLI manages authentication locally. Do not place tokens in `config.sh`.

A dry run intentionally skips `gh` authentication and network checks, since it makes no GitHub calls. A real run checks both authentication and access before beginning.

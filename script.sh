#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${CONFIG_FILE:-$SCRIPT_DIR/config.sh}"

if [[ -f "$CONFIG_FILE" ]]; then
  # shellcheck source=/dev/null
  source "$CONFIG_FILE"
fi

MAIN_BRANCH="${MAIN_BRANCH:-main}"
DRY_RUN="${DRY_RUN:-false}"
PR_COUNT="${PR_COUNT:-1024}"
PR_COUNT_FROM_ARGUMENT=false

usage() {
  cat <<'USAGE'
Usage: ./script.sh [--dry-run] [PR_COUNT]

Create, push, open, and merge PR_COUNT educational pull requests against main.
PR_COUNT defaults to 1024. Set DRY_RUN=true or pass --dry-run to preview safely.
Optional settings can be placed in config.sh (see config.example.sh).
USAGE
}

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

while (($#)); do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      [[ "$1" =~ ^[1-9][0-9]*$ ]] || fail "PR_COUNT must be a positive integer; received '$1'."
      [[ "$PR_COUNT_FROM_ARGUMENT" != true ]] 2>/dev/null || fail "Provide PR_COUNT only once."
      PR_COUNT="$1"
      PR_COUNT_FROM_ARGUMENT=true
      shift
      ;;
  esac
done

[[ "$PR_COUNT" =~ ^[1-9][0-9]*$ ]] || fail "PR_COUNT must be a positive integer."
[[ "$MAIN_BRANCH" =~ ^[A-Za-z0-9._/-]+$ ]] || fail "MAIN_BRANCH contains unsupported characters."
case "${DRY_RUN,,}" in
  true|1|yes) DRY_RUN=true ;;
  false|0|no) DRY_RUN=false ;;
  *) fail "DRY_RUN must be true or false." ;;
esac

REPO_ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel 2>/dev/null)" \
  || fail "Run this script from inside a Git repository."
git -C "$REPO_ROOT" check-ref-format --branch "$MAIN_BRANCH" >/dev/null 2>&1 \
  || fail "MAIN_BRANCH is not a valid Git branch name: '$MAIN_BRANCH'."
cd "$REPO_ROOT"
REMOTE_URL="$(git -C "$REPO_ROOT" remote get-url origin 2>/dev/null)" \
  || fail "The repository must have an 'origin' remote."
[[ -n "$REMOTE_URL" ]] || fail "The 'origin' remote URL is empty."

if [[ "$DRY_RUN" == true ]]; then
  printf 'DRY RUN: no files, branches, commits, pushes, or pull requests will be created.\n'
  printf 'Repository: %s\nOrigin: %s\nBase branch: %s\nPR count: %s\n' \
    "$REPO_ROOT" "$REMOTE_URL" "$MAIN_BRANCH" "$PR_COUNT"
  printf 'Would verify GitHub CLI authentication, prepare main, then create and merge %s PR(s).\n' "$PR_COUNT"
  if ! git -C "$REPO_ROOT" rev-parse --verify HEAD >/dev/null 2>&1; then
    printf 'The repository has no commit yet; a real run would initialize main before the first PR.\n'
  fi
  exit 0
fi

if [[ -n "$(git -C "$REPO_ROOT" status --porcelain)" ]]; then
  fail "Working tree is not clean. Commit or stash changes before running the automation."
fi
command -v gh >/dev/null 2>&1 || fail "GitHub CLI ('gh') is required."
gh auth status >/dev/null 2>&1 || fail "GitHub CLI is not authenticated. Run 'gh auth login'."
gh repo view --json nameWithOwner >/dev/null 2>&1 \
  || fail "GitHub CLI could not resolve this repository. Check origin and repository access."

RETURN_TO_MAIN=true
on_error() {
  local status=$?
  printf 'ERROR: automation failed near line %s (exit %s).\n' "$1" "$status" >&2
  exit "$status"
}
cleanup() {
  local status=$?
  trap - EXIT
  if [[ "$RETURN_TO_MAIN" == true ]] \
    && git -C "$REPO_ROOT" show-ref --verify --quiet "refs/heads/$MAIN_BRANCH"; then
    if ! git -C "$REPO_ROOT" switch "$MAIN_BRANCH"; then
      printf 'ERROR: could not return to %s; inspect the working tree manually.\n' "$MAIN_BRANCH" >&2
      status=1
    fi
  fi
  exit "$status"
}
trap 'on_error "$LINENO"' ERR
trap cleanup EXIT

REMOTE_MAIN="$(git -C "$REPO_ROOT" ls-remote --heads origin "refs/heads/$MAIN_BRANCH")" \
  || fail "Could not contact origin to check the '$MAIN_BRANCH' branch."
HAS_REMOTE_MAIN=false
[[ -n "$REMOTE_MAIN" ]] && HAS_REMOTE_MAIN=true
HAS_HEAD=true
git -C "$REPO_ROOT" rev-parse --verify HEAD >/dev/null 2>&1 || HAS_HEAD=false

if [[ "$HAS_REMOTE_MAIN" == true ]]; then
  git -C "$REPO_ROOT" fetch origin "+refs/heads/$MAIN_BRANCH:refs/remotes/origin/$MAIN_BRANCH"
  if [[ "$HAS_HEAD" == false ]]; then
    git -C "$REPO_ROOT" switch --force-create "$MAIN_BRANCH" "origin/$MAIN_BRANCH"
  elif git -C "$REPO_ROOT" show-ref --verify --quiet "refs/heads/$MAIN_BRANCH"; then
    git -C "$REPO_ROOT" switch "$MAIN_BRANCH"
    git -C "$REPO_ROOT" merge --ff-only "origin/$MAIN_BRANCH"
  else
    git -C "$REPO_ROOT" switch --track -c "$MAIN_BRANCH" "origin/$MAIN_BRANCH"
  fi
else
  if [[ "$HAS_HEAD" == false ]]; then
    CURRENT_BRANCH="$(git -C "$REPO_ROOT" branch --show-current)"
    if [[ "$CURRENT_BRANCH" != "$MAIN_BRANCH" ]]; then
      git -C "$REPO_ROOT" switch -c "$MAIN_BRANCH"
    fi
    printf 'Initializing the empty repository on %s.\n' "$MAIN_BRANCH"
    git -C "$REPO_ROOT" -c user.name="PR Automation" -c user.email="pr-automation@users.noreply.github.com" \
      commit --allow-empty -m "Initialize $MAIN_BRANCH for PR automation"
  elif git -C "$REPO_ROOT" show-ref --verify --quiet "refs/heads/$MAIN_BRANCH"; then
    git -C "$REPO_ROOT" switch "$MAIN_BRANCH"
  else
    git -C "$REPO_ROOT" switch -c "$MAIN_BRANCH"
  fi
  git -C "$REPO_ROOT" push --set-upstream origin "$MAIN_BRANCH"
fi

printf 'Starting %s pull-request iteration(s) on %s.\n' "$PR_COUNT" "$MAIN_BRANCH"
for ((iteration = 1; iteration <= PR_COUNT; iteration++)); do
  branch="pr-automation-${iteration}-$(date -u '+%Y%m%d%H%M%S')-$$"
  printf '[%s/%s] Creating branch %s.\n' "$iteration" "$PR_COUNT" "$branch"
  git -C "$REPO_ROOT" switch -c "$branch" "$MAIN_BRANCH"

  timestamp="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  printf 'PR automation iteration %s completed at %s\n' "$iteration" "$timestamp" \
    >> "$REPO_ROOT/activity_log.txt"
  git -C "$REPO_ROOT" add -- activity_log.txt
  git -C "$REPO_ROOT" commit -m "Add PR automation learning activity $iteration"
  git -C "$REPO_ROOT" push --set-upstream origin "$branch"

  printf '[%s/%s] Opening pull request.\n' "$iteration" "$PR_COUNT"
  pr_url="$(gh pr create \
    --base "$MAIN_BRANCH" \
    --head "$branch" \
    --title "PR automation learning activity $iteration" \
    --body "This pull request adds one timestamped learning activity to activity_log.txt. It was created by the educational PR automation script.")"
  printf '[%s/%s] Merging %s.\n' "$iteration" "$PR_COUNT" "$pr_url"
  gh pr merge "$pr_url" --merge --delete-branch
  git -C "$REPO_ROOT" switch "$MAIN_BRANCH"
  git -C "$REPO_ROOT" pull --ff-only origin "$MAIN_BRANCH"
  printf '[%s/%s] Pull request merged.\n' "$iteration" "$PR_COUNT"
done

RETURN_TO_MAIN=false
printf 'Completed %s pull-request iteration(s); current branch is %s.\n' "$PR_COUNT" "$MAIN_BRANCH"

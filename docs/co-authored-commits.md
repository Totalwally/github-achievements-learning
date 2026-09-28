# Co-authored commits

Git can record more than one contributor on a commit. The person configured as the commit author remains the primary author; a `Co-authored-by` trailer gives additional contributors attribution. GitHub recognizes the trailer when its email address is associated with a GitHub account.

## Add a co-author

Put the trailer in the commit message body, separated from the subject by a blank line. Use the co-author's name and an email address they have verified on GitHub:

```text
Document the review checklist

Co-authored-by: Collaborator Name <verified-email@example.com>
```

For example, create the commit from the shell with:

```bash
git add docs/review-checklist.md
git commit \
  -m "Document the review checklist" \
  -m "Co-authored-by: Collaborator Name <verified-email@example.com>"
```

Replace the example name and email with the collaborator's own verified GitHub email. If the collaborator uses GitHub's private email setting, they can find their GitHub-provided `noreply` address in their account email settings. Do not copy an address from another person's account or add someone as a co-author without their agreement.

## Verify attribution

Inspect the commit message before pushing:

```bash
git show -s --format=full HEAD
```

After the commit is pushed, inspect the pull request's **Commits** list or the commit page. GitHub should associate the co-author with their account when the trailer is correctly formatted and the email maps to their account. If GitHub shows only the primary author, verify the spelling, blank line, trailer syntax, and email association before merging.

A correctly written trailer alone does not guarantee profile contributions or any GitHub achievement; GitHub controls attribution and eligibility.

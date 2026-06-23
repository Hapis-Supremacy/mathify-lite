---
name: commit
description: Draft logical commits, stage changes, write Conventional Commit messages, push branches, and automatically create Pull Requests (PRs) using the GitHub CLI.
---

# Commit & Pull Request Skill

This skill guides coding agents on how to organize, commit, and push changes, and automatically create Pull Requests (PRs) when requested by the user.

## Staging & Drafting Commits

1. **Assess Changes**: Always check `git status` first to review all modified, untracked, and deleted files.
2. **Draft Logical Splits**: If there are many unrelated changes, group them into atomic, logically isolated commits instead of a single bulk commit.
3. **Stage Files**: Stage related files using `git add <paths>`.
4. **Conventional Commits**: Write descriptive, professional commit messages following the Conventional Commits specification:
   - Format: `<type>(<scope>): <subject>`
   - Common types:
     - `feat`: A new feature
     - `fix`: A bug fix
     - `docs`: Documentation only changes
     - `style`: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc.)
     - `refactor`: A code change that neither fixes a bug nor adds a feature
     - `perf`: A code change that improves performance
     - `test`: Adding missing tests or correcting existing tests
     - `build`: Changes that affect the build system or external dependencies
     - `ci`: Changes to CI configuration files and scripts
     - `chore`: Other changes that don't modify src or test files

## Pushing Branches

1. Check the current branch using `git branch --show-current` or `git status`.
2. Push the branch to the remote repository (e.g. `git push origin <branch-name>`).

## Creating Pull Requests (PRs)

When the user asks to push or create a Pull Request, use the GitHub CLI (`gh`) to automate the process:

1. **Verify Authentication**: Check CLI auth status.
2. **Environment Variable Note**: If a `GITHUB_TOKEN` environment variable exists but is invalid, clear/unset it so `gh` defaults to the user's keyring:
   - **PowerShell (Windows)**: `Remove-Item Env:\GITHUB_TOKEN`
   - **Bash/Zsh (Unix)**: `unset GITHUB_TOKEN`
3. **Non-Interactive PR Creation**: Create the PR non-interactively using arguments for title, description, head branch, and base branch:
   ```bash
   gh pr create --title "<PR Title>" --body "<PR Description>" --head "<branch-name>" --base "<base-branch>"
   ```
4. **Notify User**: Display the URL of the created pull request back to the user clearly.

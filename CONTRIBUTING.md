# Contributing

Contributions are welcome! This is a personal dotfiles repo, so PRs may not always be merged, but feel free to fork and adapt for your own setup.

## Getting Started

1. Fork the repo
2. Clone your fork
3. Create a branch: `git checkout -b my-feature`

## Testing Changes

Test your changes by stowing the affected package:

```sh
stow -D -t ~ <package>    # remove existing symlinks
stow -t ~ <package>       # symlinks your changes into place
```

Use `stow -n -t ~ <package>` for a dry run to check for conflicts first.

## Submitting a PR

- Keep PRs focused on a single concern
- Describe what the change does and why
- Make sure stow works cleanly with no conflicts
- Update the package table in README.md if adding a new package

## Code Style

- Follow the conventions already present in the config files
- No secrets, API keys, or credentials in tracked files

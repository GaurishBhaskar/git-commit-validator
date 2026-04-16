# 🔍 Git Commit Message Validator

> **Automate commit message consistency** using Git hooks and the [Conventional Commits](https://www.conventionalcommits.org/) specification.

[![Commit Validation](https://img.shields.io/badge/commits-conventional-brightgreen)](https://www.conventionalcommits.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## 📋 Problem Statement

Commit messages in a team project often vary wildly:

```
fixed bug
WIP
stuff
Added the thing john asked for
update
```

This makes changelogs unreliable, code reviews harder, and release automation impossible.

---

## 🎯 Objective

Automatically **reject invalid commit messages at commit time** using a `commit-msg` Git hook, enforcing the [Conventional Commits](https://www.conventionalcommits.org/) format.

---

## 📁 Project Structure

```
git-commit-validator/
├── hooks/
│   ├── commit-msg            # Main validation hook
│   └── prepare-commit-msg    # Injects a helpful template
├── tests/
│   └── run_tests.sh          # Automated test suite (30+ cases)
├── .github/
│   └── workflows/
│       └── validate.yml      # CI: validates all commits in PRs
├── install.sh                # One-command installer
├── .commitvalidatorrc.example# Config template
└── README.md
```

---

## 🚀 Quick Start

### 1. Clone / add to your project

```bash
# Clone this repo alongside your project
git clone https://github.com/yourname/git-commit-validator.git

# Or copy the hooks/ folder into your existing project
```

### 2. Install hooks

```bash
# Install into current directory's Git repo
chmod +x install.sh
./install.sh

# Install for a specific repo
./install.sh /path/to/your/repo

# Install globally (applies to ALL Git repos on your machine)
./install.sh --global
```

### 3. Make a commit

The hooks are now active. Try it:

```bash
# ❌ This will be REJECTED
git commit -m "fixed stuff"

# ✅ This will be ACCEPTED
git commit -m "fix(auth): resolve token expiry handling"
```

---

## 📐 Commit Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer]
```

### Allowed Types

| Type | When to use |
|------|-------------|
| `feat` | A new feature |
| `fix` | A bug fix |
| `docs` | Documentation only |
| `style` | Formatting, whitespace (no logic change) |
| `refactor` | Code restructure (no feature or fix) |
| `perf` | Performance improvement |
| `test` | Adding or updating tests |
| `build` | Build system / dependencies |
| `ci` | CI/CD configuration |
| `chore` | Routine tasks, maintenance |
| `revert` | Revert a previous commit |

### Valid Examples

```bash
feat: add user registration flow
fix(api): handle 404 responses gracefully
docs: update README with env variables
feat(cart)!: change checkout API (breaking change)
refactor(db): extract connection pooling logic

# With body
feat: implement dark mode

Users requested this in #312. Adds a toggle in Settings > Appearance.
Persists choice to localStorage.

Closes #312
```

### Invalid Examples

```bash
fixed bug              # ❌ no type
Feat: add thing        # ❌ uppercase type
update: something      # ❌ unknown type
feat add something     # ❌ missing colon
feat: .                # ❌ too short
feat: Add something.   # ❌ uppercase description + trailing period
```

---

## ⚙️ Configuration

Copy `.commitvalidatorrc.example` to `.commitvalidatorrc` in your repo root:

```bash
cp .commitvalidatorrc.example .commitvalidatorrc
```

Then edit to your needs:

```bash
# .commitvalidatorrc

MAX_SUBJECT_LENGTH=72        # max subject line length
MIN_SUBJECT_LENGTH=10        # min subject line length
ALLOWED_TYPES="feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert"

REQUIRE_SCOPE=false          # set true to enforce scope
REQUIRE_BODY=false           # set true to require body paragraph
REQUIRE_ISSUE_REF=false      # set true to require #123 or JIRA-456
```

---

## 🧪 Running Tests

```bash
chmod +x tests/run_tests.sh
bash tests/run_tests.sh
```

The test suite covers:
- ✅ All valid commit types
- ✅ Scope variants
- ✅ Breaking changes (`!`)
- ❌ Missing type, wrong case, unknown type
- ❌ Too short / too long subjects
- ❌ Trailing periods
- ❌ Missing colon separator
- 🔁 Auto-skip for merge/revert system commits

---

## 🤖 CI Integration

The included GitHub Actions workflow (`.github/workflows/validate.yml`) automatically:

1. **Validates every commit** in a push or pull request
2. **Runs the full test suite**
3. **Lints all shell scripts** with `shellcheck`

To use it, copy the `.github/` folder into your project repository.

---

## 🔧 Manual Testing

Test the hook directly without making a commit:

```bash
# Test a valid message
echo "feat(auth): add token refresh" | bash hooks/commit-msg /dev/stdin

# Test an invalid message
echo "fixed the bug" | bash hooks/commit-msg /dev/stdin

# Or write to a temp file
echo "fix: resolve edge case in parser" > /tmp/test_msg
bash hooks/commit-msg /tmp/test_msg
```

---

## 🗑️ Uninstalling

```bash
./install.sh --uninstall             # from current directory
./install.sh --uninstall /path/repo  # from specific repo
```

---

## 📖 References

- [Conventional Commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/)
- [Git Hooks Documentation](https://git-scm.com/docs/githooks)
- [Angular Commit Message Convention](https://github.com/angular/angular/blob/main/CONTRIBUTING.md#commit)

---

## 📄 License

MIT © 2024

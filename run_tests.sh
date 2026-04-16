#!/usr/bin/env bash
# =============================================================================
# test/run_tests.sh – Automated test suite for commit-msg hook
# =============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../hooks/commit-msg"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

PASS=0
FAIL=0
TOTAL=0

# ── Helpers ───────────────────────────────────────────────────────────────────
run_test() {
  local description="$1"
  local message="$2"
  local expected_exit="$3"   # 0 = should pass, 1 = should fail

  TOTAL=$((TOTAL + 1))

  # Write message to a temp file
  local tmpfile
  tmpfile=$(mktemp)
  echo "$message" > "$tmpfile"

  # Run the hook silently
  bash "$HOOK" "$tmpfile" > /dev/null 2>&1
  local actual_exit=$?

  rm -f "$tmpfile"

  if [[ "$actual_exit" -eq "$expected_exit" ]]; then
    echo -e "  ${GREEN}PASS${RESET}  $description"
    PASS=$((PASS + 1))
  else
    echo -e "  ${RED}FAIL${RESET}  $description"
    echo -e "         Expected exit $expected_exit, got $actual_exit"
    echo -e "         Message: \"$message\""
    FAIL=$((FAIL + 1))
  fi
}

# ── Test Suite ────────────────────────────────────────────────────────────────
echo -e "\n${BOLD}${CYAN}══════════════════════════════════════════${RESET}"
echo -e "${BOLD}${CYAN}   Git Commit Validator – Test Suite      ${RESET}"
echo -e "${BOLD}${CYAN}══════════════════════════════════════════${RESET}\n"

# --- Valid commits (should PASS) ---
echo -e "${BOLD}✅  Valid commits (should pass)${RESET}"
run_test "feat: basic feature"                    "feat: add user authentication"             0
run_test "fix: basic fix"                         "fix: resolve null pointer in parser"       0
run_test "feat(scope): with scope"                "feat(auth): implement OAuth2 flow"         0
run_test "docs: documentation"                    "docs: update installation guide"           0
run_test "chore: maintenance"                     "chore: update npm dependencies"            0
run_test "refactor: code cleanup"                 "refactor: extract helper functions"        0
run_test "test: adding tests"                     "test: add unit tests for user service"     0
run_test "ci: CI changes"                         "ci: add GitHub Actions workflow"           0
run_test "build: build system"                    "build: configure webpack for production"   0
run_test "perf: performance"                      "perf: cache database query results"        0
run_test "style: formatting"                      "style: format code with prettier"          0
run_test "revert: revert commit"                  "revert: revert previous breaking change"   0
run_test "feat!: breaking change"                 "feat!: redesign public API interface"      0
run_test "feat(scope)!: scoped breaking"          "feat(api)!: change response schema"        0

echo ""

# --- Invalid commits (should FAIL) ---
echo -e "${BOLD}❌  Invalid commits (should fail)${RESET}"
run_test "no type prefix"                         "add new login button"                      1
run_test "uppercase type"                         "Feat: add something"                       1
run_test "unknown type"                           "update: something changed"                 1
run_test "missing colon"                          "feat add feature"                          1
run_test "missing description"                    "feat: "                                    1
run_test "empty subject"                          ""                                          1
run_test "subject too short"                      "fix: typo"                                 1
run_test "trailing period"                        "feat: add new feature."                    1
run_test "subject too long" \
  "feat: this is a very long commit message that definitely exceeds the maximum allowed length of 72 characters total" 1
run_test "invalid type 'wip'"                     "wip: half done feature"                    1
run_test "invalid type 'temp'"                    "temp: testing something"                   1

echo ""

# --- Edge cases ---
echo -e "${BOLD}🔍  Edge cases${RESET}"
run_test "merge commit (auto-skip)"               "Merge branch 'feature/test' into main"     0
run_test "revert auto-commit (skip)"              "Revert \"feat: add auth\""                 0
run_test "feat with body and blank line" \
  "$(printf 'feat: add feature\n\nThis explains the why.')"                                  0

echo ""

# ── Summary ───────────────────────────────────────────────────────────────────
echo -e "${BOLD}══════════════════════════════════════════${RESET}"
echo -e "  Results: ${GREEN}$PASS passed${RESET}, ${RED}$FAIL failed${RESET} / $TOTAL total"
echo -e "${BOLD}══════════════════════════════════════════${RESET}\n"

if [[ $FAIL -gt 0 ]]; then
  exit 1
else
  echo -e "${GREEN}${BOLD}All tests passed! ✔${RESET}\n"
  exit 0
fi

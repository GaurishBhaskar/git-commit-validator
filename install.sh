#!/usr/bin/env bash
# =============================================================================
# install.sh – Install Git Commit Message Validator hooks
# =============================================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="$SCRIPT_DIR/hooks"

print_banner() {
  echo -e "\n${BOLD}${CYAN}"
  echo "  ╔══════════════════════════════════════════════════╗"
  echo "  ║     Git Commit Message Validator – Installer     ║"
  echo "  ╚══════════════════════════════════════════════════╝"
  echo -e "${RESET}"
}

# ── Detect target repo ────────────────────────────────────────────────────────
detect_git_repo() {
  TARGET_DIR="${1:-$(pwd)}"
  GIT_DIR=$(git -C "$TARGET_DIR" rev-parse --git-dir 2>/dev/null || true)

  if [[ -z "$GIT_DIR" ]]; then
    echo -e "${RED}✘ No Git repository found at: $TARGET_DIR${RESET}"
    echo -e "  Run ${BOLD}git init${RESET} first, or pass the repo path as an argument."
    exit 1
  fi

  # Resolve absolute path
  if [[ "$GIT_DIR" == ".git" ]]; then
    GIT_HOOKS_DIR="$TARGET_DIR/.git/hooks"
  else
    GIT_HOOKS_DIR="$GIT_DIR/hooks"
  fi
  echo -e "${GREEN}✔${RESET} Git repository found: ${BOLD}$TARGET_DIR${RESET}"
}

# ── Install a single hook ─────────────────────────────────────────────────────
install_hook() {
  local hook_name="$1"
  local src="$HOOKS_DIR/$hook_name"
  local dest="$GIT_HOOKS_DIR/$hook_name"

  if [[ ! -f "$src" ]]; then
    echo -e "${YELLOW}⚠  Hook source not found: $src – skipping${RESET}"
    return
  fi

  # Backup existing hook
  if [[ -f "$dest" ]]; then
    local backup="${dest}.backup.$(date +%Y%m%d%H%M%S)"
    cp "$dest" "$backup"
    echo -e "${YELLOW}⚠  Existing hook backed up to: $backup${RESET}"
  fi

  cp "$src" "$dest"
  chmod +x "$dest"
  echo -e "${GREEN}✔${RESET}  Installed hook: ${BOLD}$hook_name${RESET}"
}

# ── Copy default config if not present ───────────────────────────────────────
install_config() {
  local config_src="$SCRIPT_DIR/.commitvalidatorrc.example"
  local config_dest="${TARGET_DIR:-.}/.commitvalidatorrc"

  if [[ -f "$config_src" && ! -f "$config_dest" ]]; then
    cp "$config_src" "$config_dest"
    echo -e "${GREEN}✔${RESET}  Default config created: ${BOLD}.commitvalidatorrc${RESET}"
  fi
}

# ── Global install (all repos) ────────────────────────────────────────────────
install_global() {
  GLOBAL_HOOKS_DIR=$(git config --global core.hooksPath 2>/dev/null || echo "")
  if [[ -z "$GLOBAL_HOOKS_DIR" ]]; then
    GLOBAL_HOOKS_DIR="$HOME/.git-hooks"
    mkdir -p "$GLOBAL_HOOKS_DIR"
    git config --global core.hooksPath "$GLOBAL_HOOKS_DIR"
    echo -e "${GREEN}✔${RESET}  Set global hooks path: ${BOLD}$GLOBAL_HOOKS_DIR${RESET}"
  fi
  GIT_HOOKS_DIR="$GLOBAL_HOOKS_DIR"
  install_hook "commit-msg"
  install_hook "prepare-commit-msg"
  echo -e "\n${GREEN}${BOLD}Global install complete!${RESET} Hooks apply to ALL Git repos on this machine.\n"
}

# ── Uninstall ─────────────────────────────────────────────────────────────────
uninstall() {
  detect_git_repo "${1:-$(pwd)}"
  for hook in commit-msg prepare-commit-msg; do
    local dest="$GIT_HOOKS_DIR/$hook"
    if [[ -f "$dest" ]]; then
      rm "$dest"
      echo -e "${GREEN}✔${RESET}  Removed: $hook"
    fi
  done
  echo -e "\n${GREEN}Uninstall complete.${RESET}\n"
}

# ── Main ──────────────────────────────────────────────────────────────────────
print_banner

case "${1:-}" in
  --global|-g)
    install_global
    ;;
  --uninstall|-u)
    uninstall "${2:-}"
    ;;
  --help|-h)
    echo "Usage: ./install.sh [OPTIONS] [REPO_PATH]"
    echo ""
    echo "Options:"
    echo "  (none)         Install hooks in current directory (or REPO_PATH)"
    echo "  --global, -g   Install hooks globally for all repos"
    echo "  --uninstall,-u Remove hooks from current dir (or REPO_PATH)"
    echo "  --help, -h     Show this help"
    echo ""
    exit 0
    ;;
  *)
    TARGET_DIR="${1:-$(pwd)}"
    detect_git_repo "$TARGET_DIR"
    mkdir -p "$GIT_HOOKS_DIR"
    install_hook "commit-msg"
    install_hook "prepare-commit-msg"
    install_config
    echo -e "\n${GREEN}${BOLD}Installation complete!${RESET}"
    echo -e "Hooks are now active in: ${BOLD}$TARGET_DIR${RESET}\n"
    echo -e "  ${CYAN}Test it:${RESET}  echo 'bad message' | bash $GIT_HOOKS_DIR/commit-msg /dev/stdin"
    echo -e "  ${CYAN}Config:${RESET}   edit ${BOLD}.commitvalidatorrc${RESET} to customize rules\n"
    ;;
esac

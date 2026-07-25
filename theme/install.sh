#!/usr/bin/env bash
# FluentFox theme installer (macOS / Linux)
# Copies chrome/ + user.js into the default Firefox profile, with backups.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_DIR="$SCRIPT_DIR"
CHROME_SRC="$THEME_DIR/chrome"
USERJS_SRC="$THEME_DIR/user.js"

die() { echo "error: $*" >&2; exit 1; }

detect_firefox_dir() {
  case "$(uname -s)" in
    Darwin)
      echo "$HOME/Library/Application Support/Firefox"
      ;;
    Linux)
      if [[ -d "$HOME/.mozilla/firefox" ]]; then
        echo "$HOME/.mozilla/firefox"
      elif [[ -d "$HOME/.var/app/org.mozilla.firefox/.mozilla/firefox" ]]; then
        echo "$HOME/.var/app/org.mozilla.firefox/.mozilla/firefox"
      else
        echo "$HOME/.mozilla/firefox"
      fi
      ;;
    *)
      die "unsupported OS: $(uname -s). Use install.ps1 on Windows."
      ;;
  esac
}

resolve_profile() {
  local firefox_dir="$1"
  local profiles_ini="$firefox_dir/profiles.ini"
  [[ -f "$profiles_ini" ]] || die "profiles.ini not found at $profiles_ini — is Firefox installed?"

  local path=""
  local is_relative=1

  # Prefer Install section Default=, then Profile* with Default=1, else first Path=
  path="$(awk '
    BEGIN { install=""; defprof=""; first=""; }
    /^\[Install/ { in_install=1; in_profile=0; next }
    /^\[Profile/ { in_install=0; in_profile=1; next }
    /^\[/ { in_install=0; in_profile=0; next }
    in_install && /^Default=/ {
      sub(/^Default=/, ""); install=$0
    }
    in_profile && /^Path=/ {
      sub(/^Path=/, ""); curpath=$0
      if (first == "") first=curpath
    }
    in_profile && /^Default=1/ {
      defprof=curpath
    }
    in_profile && /^IsRelative=/ {
      # tracked alongside but paths.ini IsRelative is per-profile; handled later
    }
    END {
      if (install != "") print install
      else if (defprof != "") print defprof
      else print first
    }
  ' "$profiles_ini")"

  [[ -n "$path" ]] || die "could not determine default profile from $profiles_ini"

  # Look up IsRelative for this path
  is_relative="$(awk -v want="$path" '
    /^\[Profile/ { cur=""; rel=1 }
    /^Path=/ { sub(/^Path=/, ""); cur=$0 }
    /^IsRelative=/ { sub(/^IsRelative=/, ""); if (cur == want) rel=$0 }
    END { print rel+0 }
  ' "$profiles_ini")"

  if [[ "$is_relative" == "1" || "$is_relative" == "01" ]]; then
    echo "$firefox_dir/$path"
  else
    echo "$path"
  fi
}

backup_file() {
  local file="$1"
  if [[ -e "$file" ]]; then
    local stamp
    stamp="$(date +%Y%m%d-%H%M%S)"
    cp -a "$file" "${file}.fluentfox-backup-${stamp}"
    echo "  backed up $(basename "$file") → $(basename "$file").fluentfox-backup-${stamp}"
  fi
}

main() {
  [[ -d "$CHROME_SRC" ]] || die "missing $CHROME_SRC"
  [[ -f "$USERJS_SRC" ]] || die "missing $USERJS_SRC"

  local firefox_dir profile chrome_dest
  firefox_dir="$(detect_firefox_dir)"
  profile="$(resolve_profile "$firefox_dir")"
  [[ -d "$profile" ]] || die "profile directory does not exist: $profile"

  chrome_dest="$profile/chrome"
  mkdir -p "$chrome_dest"

  echo "FluentFox theme installer"
  echo "  Firefox dir: $firefox_dir"
  echo "  Profile:     $profile"
  echo

  backup_file "$chrome_dest/userChrome.css"
  backup_file "$chrome_dest/userContent.css"
  backup_file "$profile/user.js"

  cp "$CHROME_SRC/userChrome.css" "$chrome_dest/userChrome.css"
  cp "$CHROME_SRC/userContent.css" "$chrome_dest/userContent.css"
  cp "$USERJS_SRC" "$profile/user.js"

  echo
  echo "Installed:"
  echo "  $chrome_dest/userChrome.css"
  echo "  $chrome_dest/userContent.css"
  echo "  $profile/user.js"
  echo
  echo "Next steps:"
  echo "  1. Quit Firefox completely (Cmd+Q / quit)."
  echo "  2. Re-open Firefox so prefs and chrome CSS load."
  echo "  3. Use the System theme (or Default) under about:addons → Themes."
  echo "  4. Load the FluentFox extension (see README)."
  echo
  echo "Uninstall: remove chrome/userChrome.css, chrome/userContent.css, and user.js"
  echo "  (or restore *.fluentfox-backup-* files), then set"
  echo "  browser.tabs.allow_transparent_browser → false in about:config and restart."
}

main "$@"

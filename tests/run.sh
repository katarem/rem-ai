#!/usr/bin/env bash
# Runs the rem-ai test suite: every test_* function of tests/test_*.sh, each one in its own
# bash process with errexit and a fresh sandbox (HOME, XDG_CONFIG_HOME and TMPDIR inside it).
#
# Usage: tests/run.sh [filter]   (filter is a substring of "<file> <function>")
set -euo pipefail

TESTS_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILTER="${1:-}"
PASSED=0
FAILED=0
FAILED_NAMES=""

list_tests() {
  "$BASH" -c 'source "$1"; source "$2"; declare -F' _ "$TESTS_DIR/lib.sh" "$1" \
    | awk '$3 ~ /^test_/ { print $3 }'
}

# run_test <file> <function>: a separate process (not a subshell inside a condition, which
# would disable errexit) so that any failing command aborts the test.
run_test() {
  local file="$1" name="$2" sandbox log status=0
  sandbox="$(mktemp -d "${TMPDIR:-/tmp}/rem-ai-test.XXXXXX")"
  # Physical path: on macOS /var is a symlink to /private/var and readlink comparisons need it.
  sandbox="$(cd -P "$sandbox" && pwd)"
  mkdir -p "$sandbox/home/.config" "$sandbox/tmp"
  log="$sandbox/test.log"

  env -i \
    PATH="$PATH" \
    LANG=C \
    HOME="$sandbox/home" \
    XDG_CONFIG_HOME="$sandbox/home/.config" \
    TMPDIR="$sandbox/tmp" \
    SANDBOX="$sandbox" \
    GIT_CONFIG_NOSYSTEM=1 \
    "$BASH" -eu -o pipefail -E -c '
      trap '\''echo "command failed (exit $?) at line $LINENO: $BASH_COMMAND" >&2'\'' ERR
      source "$1"
      configure_git
      source "$2"
      cd "$SANDBOX"
      "$3"
    ' _ "$TESTS_DIR/lib.sh" "$file" "$name" >"$log" 2>&1 || status=$?

  if [[ $status -eq 0 ]]; then
    echo "PASS $name"
    PASSED=$((PASSED + 1))
  else
    echo "FAIL $name ($(basename "$file"), exit $status)"
    sed 's/^/    /' "$log"
    FAILED=$((FAILED + 1))
    FAILED_NAMES="$FAILED_NAMES $name"
  fi
  rm -rf "$sandbox"
}

for file in "$TESTS_DIR"/test_*.sh; do
  for name in $(list_tests "$file"); do
    case "$(basename "$file" .sh) $name" in
      *"$FILTER"*) run_test "$file" "$name" ;;
    esac
  done
done

echo
echo "$PASSED passed, $FAILED failed"
if [[ $FAILED -gt 0 ]]; then
  echo "Failed:$FAILED_NAMES"
  exit 1
fi
if [[ $PASSED -eq 0 ]]; then
  echo "No test matches '$FILTER'."
  exit 1
fi

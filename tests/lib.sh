# Shared helpers for the rem-ai test suite. Sourced by tests/run.sh in every test process,
# which already provides SANDBOX (physical path), HOME, XDG_CONFIG_HOME and TMPDIR inside it.
# Compatible with bash 3.2.

REPO_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TAB="$(printf '\t')"

# --- assertions ---------------------------------------------------------------

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_eq() {
  local expected="$1" actual="$2" message="${3:-values differ}"
  if [[ "$expected" != "$actual" ]]; then
    printf 'FAIL: %s\n--- expected\n%s\n--- actual\n%s\n' "$message" "$expected" "$actual" >&2
    exit 1
  fi
}

assert_file() {
  [[ -f "$1" ]] || fail "expected a regular file: $1"
}

assert_missing() {
  if [[ -e "$1" || -L "$1" ]]; then
    fail "expected path to be absent: $1"
  fi
}

assert_contains() {
  local haystack="$1" needle="$2"
  case "$haystack" in
    *"$needle"*) ;;
    *) printf 'FAIL: expected to contain: %s\n--- actual\n%s\n' "$needle" "$haystack" >&2; exit 1 ;;
  esac
}

assert_not_contains() {
  local haystack="$1" needle="$2"
  case "$haystack" in
    *"$needle"*) printf 'FAIL: expected not to contain: %s\n--- actual\n%s\n' "$needle" "$haystack" >&2; exit 1 ;;
  esac
}

# --- command execution --------------------------------------------------------

# run <command...>: runs a command without aborting the test and sets STATUS, OUT and ERR.
run() {
  STATUS=0
  "$@" >"$SANDBOX/run.out" 2>"$SANDBOX/run.err" || STATUS=$?
  OUT="$(cat "$SANDBOX/run.out")"
  ERR="$(cat "$SANDBOX/run.err")"
}

# rem_ai <args...>: the CLI under test, copied into the fixture repository.
rem_ai() {
  "$BASH" "$FIX/scripts/rem-ai" "$@"
}

# --- files and snapshots ------------------------------------------------------

sha256() {
  local out
  if command -v sha256sum >/dev/null 2>&1; then
    out="$(sha256sum "$1")"
  else
    out="$(shasum -a 256 "$1")"
  fi
  echo "${out%% *}"
}

# write_file <path> <content>: creates parent directories and writes one line.
write_file() {
  mkdir -p "$(dirname "$1")"
  printf '%s\n' "$2" >"$1"
}

# snapshot <dir>: sorted listing of every path with its type and sha256 or link target.
snapshot() {
  local dir="$1" path
  if [[ ! -e "$dir" && ! -L "$dir" ]]; then
    echo "ABSENT"
    return
  fi
  (cd "$dir" && find . | LC_ALL=C sort) | while IFS= read -r path; do
    if [[ -L "$dir/$path" ]]; then
      echo "$path link $(readlink "$dir/$path")"
    elif [[ -d "$dir/$path" ]]; then
      echo "$path dir"
    else
      echo "$path file $(sha256 "$dir/$path")"
    fi
  done
}

# --- manifest -----------------------------------------------------------------

# manifest_value <dest> <key>: value of a header line (repo, mode, commit, version).
manifest_value() {
  awk -F'\t' -v k="$2" '$1 == k { print $2 }' "$1/.rem-ai-manifest"
}

# manifest_entry <dest> <rel>: the file/link line for a path, empty if unmanaged.
manifest_entry() {
  awk -F'\t' -v r="$2" '($1 == "file" || $1 == "link") && $3 == r' "$1/.rem-ai-manifest"
}

manifest_packs() {
  awk -F'\t' '$1 == "pack" { print $2 }' "$1/.rem-ai-manifest"
}

# --- git fixture --------------------------------------------------------------

# configure_git: identity and defaults in the sandbox HOME, never in the real one.
configure_git() {
  cat >"$HOME/.gitconfig" <<'GITCONFIG'
[user]
	name = test
	email = test@example.invalid
[init]
	defaultBranch = main
[commit]
	gpgsign = false
[advice]
	detachedHead = false
[pull]
	ff = only
[safe]
	directory = *
GITCONFIG
}

# make_fixture_repo: creates a bare upstream (HEAD refs/heads/main) and the clone $FIX with a
# copy of the real scripts/rem-ai and two small packs. Also sets UPSTREAM and PROJ.
make_fixture_repo() {
  UPSTREAM="$SANDBOX/upstream.git"
  FIX="$SANDBOX/rem-ai"
  PROJ="$SANDBOX/project"
  git init -q --bare "$UPSTREAM"
  git -C "$UPSTREAM" symbolic-ref HEAD refs/heads/main
  mkdir -p "$FIX/scripts" "$PROJ"
  git -C "$FIX" init -q
  cp "$REPO_DIR/scripts/rem-ai" "$FIX/scripts/rem-ai"
  chmod +x "$FIX/scripts/rem-ai"
  write_file "$FIX/README.md" "fixture repository"
  write_file "$FIX/packs/alpha/agents/a1.md" "alpha agent a1 v1"
  write_file "$FIX/packs/alpha/rules/r1.md" "alpha rule r1 v1"
  write_file "$FIX/packs/alpha/rules/sub/r2.md" "alpha rule sub/r2 v1"
  write_file "$FIX/packs/alpha/skills/s1/SKILL.md" "alpha skill s1 v1"
  write_file "$FIX/packs/alpha/skills/s1/templates/t.yml" "template: v1"
  write_file "$FIX/packs/beta/agents/b1.md" "beta agent b1 v1"
  git -C "$FIX" add -A
  git -C "$FIX" commit -q -m "initial fixture"
  git -C "$FIX" remote add origin "$UPSTREAM"
  git -C "$FIX" push -q -u origin main 2>/dev/null
}

# upstream_change <message> <script>: runs a shell script in a second clone of the upstream
# and pushes the result as a new commit, simulating a change published by someone else.
upstream_change() {
  local work="$SANDBOX/upstream-work"
  if [[ ! -d "$work" ]]; then
    git clone -q "$UPSTREAM" "$work"
  fi
  git -C "$work" pull -q --ff-only
  (cd "$work" && "$BASH" -eu -c "$2")
  git -C "$work" add -A
  git -C "$work" commit -q -m "$1"
  git -C "$work" push -q origin main 2>/dev/null
}

fix_head() {
  git -C "$FIX" rev-parse HEAD
}

upstream_head() {
  git -C "$UPSTREAM" rev-parse refs/heads/main
}

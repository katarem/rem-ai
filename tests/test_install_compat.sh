# O10: scripts/install.sh keeps its interface on the real repository and writes a manifest.
# PATH is restricted so the `claude` CLI is never invoked by the engram check.

install_sh() {
  PATH=/usr/bin:/bin "$BASH" "$REPO_DIR/scripts/install.sh" "$@"
}

# assert_manifest_matches_files <dest>: every installed file is in the manifest with its hash.
assert_manifest_matches_files() {
  local dest="$1" files lines rel hash
  files="$(cd "$dest" && find . -type f ! -name .rem-ai-manifest | sed 's|^\./||' | LC_ALL=C sort)"
  lines="$(awk -F'\t' '$1 == "file" { print $3 }' "$dest/.rem-ai-manifest" | LC_ALL=C sort)"
  assert_eq "$files" "$lines" "manifest entries match installed files"
  while IFS="$TAB" read -r rel hash; do
    assert_eq "$(sha256 "$dest/$rel")" "$hash" "hash of $rel"
  done < <(awk -F'\t' '$1 == "file" { print $3 "\t" $4 }' "$dest/.rem-ai-manifest")
}

test_install_compat_project_core_and_java_spring() {
  mkdir -p "$SANDBOX/proj"

  run install_sh "$SANDBOX/proj" core java-spring

  assert_eq 0 "$STATUS" "exit status"
  local dest="$SANDBOX/proj/.claude"
  assert_file "$dest/.rem-ai-manifest"
  assert_eq "core
java-spring" "$(manifest_packs "$dest")" "pack lines"
  assert_eq "copy" "$(manifest_value "$dest" mode)" "mode"
  assert_eq "$REPO_DIR" "$(manifest_value "$dest" repo)" "repo"
  assert_file "$dest/agents/architect.md"
  assert_file "$dest/rules/core/language.md"
  assert_manifest_matches_files "$dest"
  assert_contains "$ERR" "no se encuentra el CLI 'claude'"
}

test_install_compat_global_installs_into_home_claude() {
  run install_sh --global core

  assert_eq 0 "$STATUS" "exit status"
  assert_file "$HOME/.claude/.rem-ai-manifest"
  assert_file "$HOME/.claude/agents/architect.md"
  assert_manifest_matches_files "$HOME/.claude"
  assert_eq "$HOME/.claude" "$(cat "$XDG_CONFIG_HOME/rem-ai/installs")" "registered in the registry"
}

test_install_compat_link_mode() {
  mkdir -p "$SANDBOX/proj"

  run install_sh --link "$SANDBOX/proj" typescript

  assert_eq 0 "$STATUS" "exit status"
  assert_eq "link" "$(manifest_value "$SANDBOX/proj/.claude" mode)" "mode"
  local rel target
  while IFS="$TAB" read -r rel target; do
    assert_eq "$target" "$(readlink "$SANDBOX/proj/.claude/$rel")" "link $rel"
  done < <(awk -F'\t' '$1 == "link" { print $3 "\t" $4 }' "$SANDBOX/proj/.claude/.rem-ai-manifest")
}

test_install_compat_force_overwrites_an_existing_file() {
  write_file "$SANDBOX/proj/.claude/agents/architect.md" "user architect"

  run install_sh --force "$SANDBOX/proj" core

  assert_eq 0 "$STATUS" "exit status"
  cmp "$REPO_DIR/packs/core/agents/architect.md" "$SANDBOX/proj/.claude/agents/architect.md"
}

test_install_compat_list_prints_the_available_packs() {
  run install_sh --list

  assert_eq 0 "$STATUS" "exit status"
  assert_contains "$OUT" "Packs disponibles:"
  assert_contains "$OUT" "  core "
  assert_contains "$OUT" "  java-spring "
}

test_install_compat_unknown_pack_fails() {
  mkdir -p "$SANDBOX/proj"

  run install_sh "$SANDBOX/proj" no-such-pack

  assert_eq 1 "$STATUS" "exit status"
  assert_contains "$ERR" "Pack desconocido: no-such-pack"
  assert_missing "$SANDBOX/proj/.claude"
}

# O1-O3: manifest written by `rem-ai install` in copy and link modes, and merging.

test_manifest_copy_writes_header_with_repo_mode_commit_and_version() {
  make_fixture_repo

  rem_ai install "$PROJ" alpha >/dev/null

  local manifest="$PROJ/.claude/.rem-ai-manifest"
  assert_eq "rem-ai-manifest${TAB}1" "$(head -n 1 "$manifest")" "manifest header"
  assert_eq "$FIX" "$(manifest_value "$PROJ/.claude" repo)" "repo line"
  assert_eq "copy" "$(manifest_value "$PROJ/.claude" mode)" "mode line"
  assert_eq "$(fix_head)" "$(manifest_value "$PROJ/.claude" commit)" "commit line"
  assert_eq "$(git -C "$FIX" describe --tags --always --dirty)" \
    "$(manifest_value "$PROJ/.claude" version)" "version line"
  assert_eq "alpha" "$(manifest_packs "$PROJ/.claude")" "pack lines"
}

test_manifest_copy_has_one_file_line_per_installed_file_with_real_sha256() {
  make_fixture_repo

  rem_ai install "$PROJ" alpha beta >/dev/null

  local dest="$PROJ/.claude" files lines rel hash
  files="$(cd "$dest" && find . -type f ! -name .rem-ai-manifest | sed 's|^\./||' | LC_ALL=C sort)"
  lines="$(awk -F'\t' '$1 == "file" { print $3 }' "$dest/.rem-ai-manifest" | LC_ALL=C sort)"
  assert_eq "$files" "$lines" "file lines must match the installed files"
  assert_eq 6 "$(echo "$lines" | wc -l | tr -d ' ')" "number of installed files"
  while IFS="$TAB" read -r rel hash; do
    assert_eq "$(sha256 "$dest/$rel")" "$hash" "hash of $rel"
  done < <(awk -F'\t' '$1 == "file" { print $3 "\t" $4 }' "$dest/.rem-ai-manifest")
}

test_manifest_copy_uses_the_installer_layout_for_agents_rules_and_skills() {
  make_fixture_repo

  rem_ai install "$PROJ" alpha >/dev/null

  local dest="$PROJ/.claude"
  cmp "$FIX/packs/alpha/agents/a1.md" "$dest/agents/a1.md"
  cmp "$FIX/packs/alpha/rules/r1.md" "$dest/rules/alpha/r1.md"
  cmp "$FIX/packs/alpha/rules/sub/r2.md" "$dest/rules/alpha/sub/r2.md"
  cmp "$FIX/packs/alpha/skills/s1/SKILL.md" "$dest/skills/s1/SKILL.md"
  cmp "$FIX/packs/alpha/skills/s1/templates/t.yml" "$dest/skills/s1/templates/t.yml"
  [[ ! -L "$dest/agents/a1.md" ]] || fail "copy mode must not create symlinks"
}

test_manifest_link_has_one_link_line_per_unit_matching_readlink() {
  make_fixture_repo

  rem_ai install --link "$PROJ" alpha >/dev/null

  local dest="$PROJ/.claude" rel target
  assert_eq "link" "$(manifest_value "$dest" mode)" "mode line"
  assert_eq "agents/a1.md
rules/alpha/r1.md
rules/alpha/sub/r2.md
skills/s1" "$(awk -F'\t' '$1 == "link" { print $3 }' "$dest/.rem-ai-manifest")" "one link per unit"
  assert_eq 0 "$(awk -F'\t' '$1 == "file"' "$dest/.rem-ai-manifest" | wc -l | tr -d ' ')" "no file lines"
  while IFS="$TAB" read -r rel target; do
    [[ -L "$dest/$rel" ]] || fail "expected a symlink: $rel"
    assert_eq "$(readlink "$dest/$rel")" "$target" "link target of $rel"
    assert_contains "$target" "$FIX/packs/alpha/"
  done < <(awk -F'\t' '$1 == "link" { print $3 "\t" $4 }' "$dest/.rem-ai-manifest")
  assert_eq "$FIX/packs/alpha/skills/s1" "$(readlink "$dest/skills/s1")" "skill linked as a directory"
}

test_manifest_merge_adding_a_pack_keeps_previous_entries() {
  make_fixture_repo
  rem_ai install "$PROJ" alpha >/dev/null
  local before
  before="$(awk -F'\t' '$1 == "file"' "$PROJ/.claude/.rem-ai-manifest")"

  rem_ai install "$PROJ" beta >/dev/null

  assert_eq "alpha
beta" "$(manifest_packs "$PROJ/.claude")" "both packs listed"
  local after_alpha
  after_alpha="$(awk -F'\t' '$1 == "file" && $2 == "alpha"' "$PROJ/.claude/.rem-ai-manifest")"
  assert_eq "$before" "$after_alpha" "alpha entries preserved"
  assert_contains "$(manifest_entry "$PROJ/.claude" agents/b1.md)" "file${TAB}beta${TAB}agents/b1.md${TAB}"
}

test_manifest_merge_reinstalling_the_same_pack_is_byte_identical() {
  make_fixture_repo
  rem_ai install "$PROJ" alpha beta >/dev/null
  cp "$PROJ/.claude/.rem-ai-manifest" "$SANDBOX/manifest.before"

  rem_ai install "$PROJ" alpha >/dev/null

  cmp "$SANDBOX/manifest.before" "$PROJ/.claude/.rem-ai-manifest" \
    || fail "manifest changed after reinstalling"
}

test_manifest_merge_switching_from_copy_to_link_fails_without_changes() {
  make_fixture_repo
  rem_ai install "$PROJ" alpha >/dev/null
  local before
  before="$(snapshot "$PROJ")"

  run rem_ai install --link "$PROJ" alpha

  assert_eq 1 "$STATUS" "exit status"
  assert_contains "$ERR" "usa el modo 'copy'"
  assert_contains "$ERR" "rem-ai uninstall"
  assert_eq "$before" "$(snapshot "$PROJ")" "installation must not change"
}

test_manifest_merge_switching_from_link_to_copy_fails_without_changes() {
  make_fixture_repo
  rem_ai install --link "$PROJ" alpha >/dev/null
  local before
  before="$(snapshot "$PROJ")"

  run rem_ai install "$PROJ" beta

  assert_eq 1 "$STATUS" "exit status"
  assert_contains "$ERR" "usa el modo 'link'"
  assert_eq "$before" "$(snapshot "$PROJ")" "installation must not change"
}

test_install_unknown_pack_fails_without_creating_claude_dir() {
  make_fixture_repo

  run rem_ai install "$PROJ" alpha nope

  assert_eq 1 "$STATUS" "exit status"
  assert_contains "$ERR" "Pack desconocido: nope"
  assert_missing "$PROJ/.claude"
}

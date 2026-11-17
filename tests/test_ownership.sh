# O4: pre-existing files are never taken over silently.

test_ownership_existing_different_file_is_skipped_and_not_managed() {
  make_fixture_repo
  write_file "$PROJ/.claude/agents/a1.md" "user agent"

  run rem_ai install "$PROJ" alpha

  assert_eq 0 "$STATUS" "exit status"
  assert_contains "$OUT" "omitido (ya existe, usa --force): agents/a1.md"
  assert_eq "user agent" "$(cat "$PROJ/.claude/agents/a1.md")" "user file intact"
  assert_eq "" "$(manifest_entry "$PROJ/.claude" agents/a1.md)" "skipped file not in manifest"
  assert_contains "$(manifest_entry "$PROJ/.claude" rules/alpha/r1.md)" "rules/alpha/r1.md"
}

test_ownership_existing_identical_file_is_adopted() {
  make_fixture_repo
  mkdir -p "$PROJ/.claude/agents"
  cp "$FIX/packs/alpha/agents/a1.md" "$PROJ/.claude/agents/a1.md"

  run rem_ai install "$PROJ" alpha

  assert_eq 0 "$STATUS" "exit status"
  assert_not_contains "$OUT" "omitido ("
  assert_eq "file${TAB}alpha${TAB}agents/a1.md${TAB}$(sha256 "$FIX/packs/alpha/agents/a1.md")" \
    "$(manifest_entry "$PROJ/.claude" agents/a1.md)" "identical file adopted"
}

test_ownership_existing_symlink_to_the_same_source_is_adopted_in_link_mode() {
  make_fixture_repo
  mkdir -p "$PROJ/.claude/agents"
  ln -s "$FIX/packs/alpha/agents/a1.md" "$PROJ/.claude/agents/a1.md"

  run rem_ai install --link "$PROJ" alpha

  assert_eq 0 "$STATUS" "exit status"
  assert_not_contains "$OUT" "omitido ("
  assert_eq "link${TAB}alpha${TAB}agents/a1.md${TAB}$FIX/packs/alpha/agents/a1.md" \
    "$(manifest_entry "$PROJ/.claude" agents/a1.md)" "symlink adopted"
}

test_ownership_existing_file_is_skipped_in_link_mode() {
  make_fixture_repo
  write_file "$PROJ/.claude/agents/a1.md" "user agent"

  run rem_ai install --link "$PROJ" alpha

  assert_eq 0 "$STATUS" "exit status"
  assert_contains "$OUT" "omitido (ya existe, usa --force): agents/a1.md"
  [[ ! -L "$PROJ/.claude/agents/a1.md" ]] || fail "user file replaced by a symlink"
  assert_eq "user agent" "$(cat "$PROJ/.claude/agents/a1.md")" "user file intact"
  assert_eq "" "$(manifest_entry "$PROJ/.claude" agents/a1.md)" "skipped file not in manifest"
}

test_ownership_existing_different_skill_is_skipped_as_a_whole() {
  make_fixture_repo
  write_file "$PROJ/.claude/skills/s1/SKILL.md" "user skill"

  run rem_ai install "$PROJ" alpha

  assert_eq 0 "$STATUS" "exit status"
  assert_contains "$OUT" "omitido (ya existe, usa --force): skills/s1"
  assert_eq "user skill" "$(cat "$PROJ/.claude/skills/s1/SKILL.md")" "user skill intact"
  assert_missing "$PROJ/.claude/skills/s1/templates/t.yml"
  assert_eq "" "$(awk -F'\t' 'index($3, "skills/s1/") == 1' "$PROJ/.claude/.rem-ai-manifest")" \
    "no skill entries in manifest"
}

test_ownership_existing_identical_skill_is_adopted() {
  make_fixture_repo
  mkdir -p "$PROJ/.claude/skills"
  cp -R "$FIX/packs/alpha/skills/s1" "$PROJ/.claude/skills/s1"

  run rem_ai install "$PROJ" alpha

  assert_not_contains "$OUT" "omitido ("
  assert_contains "$(manifest_entry "$PROJ/.claude" skills/s1/SKILL.md)" "skills/s1/SKILL.md"
  assert_contains "$(manifest_entry "$PROJ/.claude" skills/s1/templates/t.yml)" "skills/s1/templates/t.yml"
}

test_ownership_force_takes_over_an_existing_file() {
  make_fixture_repo
  write_file "$PROJ/.claude/agents/a1.md" "user agent"

  run rem_ai install --force "$PROJ" alpha

  assert_eq 0 "$STATUS" "exit status"
  cmp "$FIX/packs/alpha/agents/a1.md" "$PROJ/.claude/agents/a1.md"
  assert_eq "file${TAB}alpha${TAB}agents/a1.md${TAB}$(sha256 "$FIX/packs/alpha/agents/a1.md")" \
    "$(manifest_entry "$PROJ/.claude" agents/a1.md)" "forced file managed"
}

test_ownership_force_replaces_an_existing_skill_directory() {
  make_fixture_repo
  write_file "$PROJ/.claude/skills/s1/SKILL.md" "user skill"
  write_file "$PROJ/.claude/skills/s1/extra.md" "user extra"

  run rem_ai install --force "$PROJ" alpha

  assert_eq 0 "$STATUS" "exit status"
  cmp "$FIX/packs/alpha/skills/s1/SKILL.md" "$PROJ/.claude/skills/s1/SKILL.md"
  assert_file "$PROJ/.claude/skills/s1/templates/t.yml"
  assert_missing "$PROJ/.claude/skills/s1/extra.md"
}

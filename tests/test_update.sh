# O7: `rem-ai update` pulls the clone and synchronises the installed packs.
# O8: problems with the clone are warnings; update still synchronises from the local tree.

test_update_refreshes_an_unmodified_copy_changed_upstream() {
  make_fixture_repo
  rem_ai install "$PROJ" alpha >/dev/null
  upstream_change "change a1" 'echo "alpha agent a1 v2" > packs/alpha/agents/a1.md'

  run rem_ai update "$PROJ"

  assert_eq 0 "$STATUS" "exit status"
  assert_contains "$OUT" "Repositorio actualizado"
  assert_eq "alpha agent a1 v2" "$(cat "$PROJ/.claude/agents/a1.md")" "copy refreshed"
  assert_eq "file${TAB}alpha${TAB}agents/a1.md${TAB}$(sha256 "$PROJ/.claude/agents/a1.md")" \
    "$(manifest_entry "$PROJ/.claude" agents/a1.md)" "manifest hash refreshed"
}

test_update_sets_the_manifest_commit_to_the_new_head() {
  make_fixture_repo
  rem_ai install "$PROJ" alpha >/dev/null
  local old_head
  old_head="$(fix_head)"
  upstream_change "change a1" 'echo "alpha agent a1 v2" > packs/alpha/agents/a1.md'

  rem_ai update "$PROJ" >/dev/null

  assert_eq "$(upstream_head)" "$(fix_head)" "clone fast-forwarded"
  [[ "$old_head" != "$(fix_head)" ]] || fail "HEAD did not move"
  assert_eq "$(fix_head)" "$(manifest_value "$PROJ/.claude" commit)" "manifest commit"
  assert_eq "$(git -C "$FIX" describe --tags --always --dirty)" \
    "$(manifest_value "$PROJ/.claude" version)" "manifest version"
}

test_update_reexecutes_the_freshly_pulled_script() {
  make_fixture_repo
  rem_ai install "$PROJ" alpha >/dev/null
  awk '{ print } /echo "Actualizando \$DEST"/ { print "  echo \"pulled script is running\"" }' \
    "$FIX/scripts/rem-ai" >"$SANDBOX/new-rem-ai"
  grep -q "pulled script is running" "$SANDBOX/new-rem-ai" || fail "could not patch the script"
  upstream_change "change the CLI" 'cp "$SANDBOX/new-rem-ai" scripts/rem-ai'

  run rem_ai update "$PROJ"

  assert_eq 0 "$STATUS" "exit status"
  assert_contains "$OUT" "Repositorio actualizado"
  assert_contains "$OUT" "pulled script is running"
}

test_update_keeps_a_locally_modified_copy_and_force_overwrites_it() {
  make_fixture_repo
  rem_ai install "$PROJ" alpha >/dev/null
  local original_entry
  original_entry="$(manifest_entry "$PROJ/.claude" agents/a1.md)"
  write_file "$PROJ/.claude/agents/a1.md" "edited by the user"
  upstream_change "change a1" 'echo "alpha agent a1 v2" > packs/alpha/agents/a1.md'

  run rem_ai update "$PROJ"

  assert_eq 0 "$STATUS" "exit status"
  assert_contains "$ERR" "modificado localmente, se conserva (usa --force para sobrescribir): agents/a1.md"
  assert_eq "edited by the user" "$(cat "$PROJ/.claude/agents/a1.md")" "modified copy kept"
  assert_eq "$original_entry" "$(manifest_entry "$PROJ/.claude" agents/a1.md)" "old hash kept"

  run rem_ai update --force "$PROJ"

  assert_eq 0 "$STATUS" "exit status"
  assert_eq "alpha agent a1 v2" "$(cat "$PROJ/.claude/agents/a1.md")" "copy overwritten"
  assert_eq "file${TAB}alpha${TAB}agents/a1.md${TAB}$(sha256 "$FIX/packs/alpha/agents/a1.md")" \
    "$(manifest_entry "$PROJ/.claude" agents/a1.md)" "manifest hash refreshed"
}

test_update_removes_a_file_deleted_upstream_and_its_empty_parent() {
  make_fixture_repo
  rem_ai install "$PROJ" alpha >/dev/null
  upstream_change "delete r2" 'rm -r packs/alpha/rules/sub'

  run rem_ai update "$PROJ"

  assert_eq 0 "$STATUS" "exit status"
  assert_missing "$PROJ/.claude/rules/alpha/sub"
  assert_file "$PROJ/.claude/rules/alpha/r1.md"
  assert_eq "" "$(manifest_entry "$PROJ/.claude" rules/alpha/sub/r2.md)" "entry removed"
}

test_update_keeps_a_modified_file_deleted_upstream_and_stops_managing_it() {
  make_fixture_repo
  rem_ai install "$PROJ" alpha >/dev/null
  write_file "$PROJ/.claude/rules/alpha/sub/r2.md" "edited by the user"
  upstream_change "delete r2" 'rm -r packs/alpha/rules/sub'

  run rem_ai update "$PROJ"

  assert_eq 0 "$STATUS" "exit status"
  assert_contains "$ERR" "deja de estar gestionado por rem-ai: rules/alpha/sub/r2.md"
  assert_eq "edited by the user" "$(cat "$PROJ/.claude/rules/alpha/sub/r2.md")" "modified file kept"
  assert_eq "" "$(manifest_entry "$PROJ/.claude" rules/alpha/sub/r2.md)" "no longer managed"
}

test_update_force_removes_a_modified_file_deleted_upstream() {
  make_fixture_repo
  rem_ai install "$PROJ" alpha >/dev/null
  write_file "$PROJ/.claude/rules/alpha/sub/r2.md" "edited by the user"
  upstream_change "delete r2" 'rm -r packs/alpha/rules/sub'

  run rem_ai update --force "$PROJ"

  assert_eq 0 "$STATUS" "exit status"
  assert_missing "$PROJ/.claude/rules/alpha/sub"
}

test_update_replaces_a_file_renamed_upstream() {
  make_fixture_repo
  rem_ai install "$PROJ" alpha >/dev/null
  upstream_change "rename a1" 'git mv packs/alpha/agents/a1.md packs/alpha/agents/a1-renamed.md'

  run rem_ai update "$PROJ"

  assert_eq 0 "$STATUS" "exit status"
  assert_missing "$PROJ/.claude/agents/a1.md"
  cmp "$FIX/packs/alpha/agents/a1-renamed.md" "$PROJ/.claude/agents/a1-renamed.md"
  assert_eq "" "$(manifest_entry "$PROJ/.claude" agents/a1.md)" "old entry removed"
  assert_contains "$(manifest_entry "$PROJ/.claude" agents/a1-renamed.md)" "agents/a1-renamed.md"
}

test_update_installs_files_added_upstream() {
  make_fixture_repo
  rem_ai install "$PROJ" alpha >/dev/null
  upstream_change "add files" '
    echo "alpha agent a2" > packs/alpha/agents/a2.md
    echo "new skill file" > packs/alpha/skills/s1/templates/u.yml
    mkdir -p packs/alpha/skills/s2 && echo "alpha skill s2" > packs/alpha/skills/s2/SKILL.md'

  run rem_ai update "$PROJ"

  assert_eq 0 "$STATUS" "exit status"
  cmp "$FIX/packs/alpha/agents/a2.md" "$PROJ/.claude/agents/a2.md"
  cmp "$FIX/packs/alpha/skills/s1/templates/u.yml" "$PROJ/.claude/skills/s1/templates/u.yml"
  cmp "$FIX/packs/alpha/skills/s2/SKILL.md" "$PROJ/.claude/skills/s2/SKILL.md"
  local rel
  for rel in agents/a2.md skills/s1/templates/u.yml skills/s2/SKILL.md; do
    assert_eq "file${TAB}alpha${TAB}$rel${TAB}$(sha256 "$PROJ/.claude/$rel")" \
      "$(manifest_entry "$PROJ/.claude" "$rel")" "new entry $rel"
  done
}

test_update_uninstalls_a_pack_removed_upstream() {
  make_fixture_repo
  rem_ai install "$PROJ" alpha beta >/dev/null
  upstream_change "drop beta" 'rm -r packs/beta'

  run rem_ai update "$PROJ"

  assert_eq 0 "$STATUS" "exit status"
  assert_contains "$ERR" "el pack 'beta' ya no existe en el repositorio"
  assert_missing "$PROJ/.claude/agents/b1.md"
  assert_file "$PROJ/.claude/agents/a1.md"
  assert_eq "alpha" "$(manifest_packs "$PROJ/.claude")" "beta removed from manifest"
}

test_update_restores_a_manually_deleted_managed_file() {
  make_fixture_repo
  rem_ai install "$PROJ" alpha >/dev/null
  rm "$PROJ/.claude/skills/s1/templates/t.yml"

  run rem_ai update --no-pull "$PROJ"

  assert_eq 0 "$STATUS" "exit status"
  assert_contains "$OUT" "skills/s1/templates/t.yml (restaurado)"
  cmp "$FIX/packs/alpha/skills/s1/templates/t.yml" "$PROJ/.claude/skills/s1/templates/t.yml"
}

test_update_link_mode_links_new_units_and_removes_deleted_ones() {
  make_fixture_repo
  rem_ai install --link "$PROJ" alpha >/dev/null
  upstream_change "add a2, drop r1" '
    echo "alpha agent a2" > packs/alpha/agents/a2.md
    git rm -q packs/alpha/rules/r1.md'

  run rem_ai update "$PROJ"

  assert_eq 0 "$STATUS" "exit status"
  assert_eq "$FIX/packs/alpha/agents/a2.md" "$(readlink "$PROJ/.claude/agents/a2.md")" "new unit linked"
  assert_missing "$PROJ/.claude/rules/alpha/r1.md"
  assert_eq "" "$(manifest_entry "$PROJ/.claude" rules/alpha/r1.md)" "deleted unit unmanaged"
  assert_contains "$(manifest_entry "$PROJ/.claude" agents/a2.md)" "link${TAB}alpha${TAB}agents/a2.md"
}

test_update_without_manifest_fails() {
  make_fixture_repo

  run rem_ai update --no-pull "$PROJ"

  assert_eq 1 "$STATUS" "exit status"
  assert_contains "$ERR" "no hay ninguna instalación de rem-ai"
}

test_update_rejects_pack_arguments() {
  make_fixture_repo
  rem_ai install "$PROJ" alpha >/dev/null

  run rem_ai update "$PROJ" beta

  assert_eq 1 "$STATUS" "exit status"
  assert_contains "$ERR" "update no acepta packs"
}

# --- O8: defensive pull --------------------------------------------------------

test_update_git_dirty_tree_warns_skips_pull_and_syncs_local_tree() {
  make_fixture_repo
  rem_ai install "$PROJ" alpha beta >/dev/null
  upstream_change "change b1" 'echo "beta agent b1 v2" > packs/beta/agents/b1.md'
  echo "alpha agent a1 local edit" >"$FIX/packs/alpha/agents/a1.md"
  local head
  head="$(fix_head)"

  run rem_ai update "$PROJ"

  assert_eq 0 "$STATUS" "exit status"
  assert_contains "$ERR" "tiene cambios locales sin commit; no se descargan cambios"
  assert_eq "$head" "$(fix_head)" "HEAD unchanged"
  assert_eq "beta agent b1 v1" "$(cat "$PROJ/.claude/agents/b1.md")" "upstream change not applied"
  assert_eq "alpha agent a1 local edit" "$(cat "$PROJ/.claude/agents/a1.md")" "synced from local tree"
}

test_update_git_without_upstream_warns_and_skips_pull() {
  make_fixture_repo
  rem_ai install "$PROJ" beta >/dev/null
  git -C "$FIX" branch -q --unset-upstream
  upstream_change "change b1" 'echo "beta agent b1 v2" > packs/beta/agents/b1.md'
  local head
  head="$(fix_head)"

  run rem_ai update "$PROJ"

  assert_eq 0 "$STATUS" "exit status"
  assert_contains "$ERR" "no tiene rama upstream; no se descargan cambios"
  assert_eq "$head" "$(fix_head)" "HEAD unchanged"
  assert_eq "beta agent b1 v1" "$(cat "$PROJ/.claude/agents/b1.md")" "upstream change not applied"
}

test_update_git_unreachable_remote_warns_and_skips_pull() {
  make_fixture_repo
  rem_ai install "$PROJ" beta >/dev/null
  git -C "$FIX" remote set-url origin file:///nonexistent
  local head
  head="$(fix_head)"

  run rem_ai update "$PROJ"

  assert_eq 0 "$STATUS" "exit status"
  assert_contains "$ERR" "no se pudo actualizar el repositorio $FIX"
  assert_eq "$head" "$(fix_head)" "HEAD unchanged"
  assert_contains "$OUT" "Actualizando $PROJ/.claude"
}

test_update_git_divergent_history_warns_and_syncs_local_commit() {
  make_fixture_repo
  rem_ai install "$PROJ" alpha beta >/dev/null
  upstream_change "change b1" 'echo "beta agent b1 v2" > packs/beta/agents/b1.md'
  echo "alpha agent a1 local commit" >"$FIX/packs/alpha/agents/a1.md"
  git -C "$FIX" commit -q -am "local change"
  local head
  head="$(fix_head)"

  run rem_ai update "$PROJ"

  assert_eq 0 "$STATUS" "exit status"
  assert_contains "$ERR" "no se pudo actualizar el repositorio $FIX"
  assert_eq "$head" "$(fix_head)" "HEAD unchanged"
  assert_eq "beta agent b1 v1" "$(cat "$PROJ/.claude/agents/b1.md")" "upstream change not applied"
  assert_eq "alpha agent a1 local commit" "$(cat "$PROJ/.claude/agents/a1.md")" "local commit synced"
  assert_eq "$head" "$(manifest_value "$PROJ/.claude" commit)" "manifest commit is the local HEAD"
}

test_update_git_not_a_repository_warns_and_syncs_local_files() {
  make_fixture_repo
  rem_ai install "$PROJ" beta >/dev/null
  rm -rf "$FIX/.git"
  echo "beta agent b1 v2" >"$FIX/packs/beta/agents/b1.md"

  run rem_ai update "$PROJ"

  assert_eq 0 "$STATUS" "exit status"
  assert_contains "$ERR" "no es un repositorio git"
  assert_eq "beta agent b1 v2" "$(cat "$PROJ/.claude/agents/b1.md")" "synced from local files"
  assert_eq "unknown" "$(manifest_value "$PROJ/.claude" commit)" "commit unknown"
}

test_update_no_pull_skips_the_pull() {
  make_fixture_repo
  rem_ai install "$PROJ" beta >/dev/null
  upstream_change "change b1" 'echo "beta agent b1 v2" > packs/beta/agents/b1.md'
  local head
  head="$(fix_head)"

  run rem_ai update --no-pull "$PROJ"

  assert_eq 0 "$STATUS" "exit status"
  assert_not_contains "$OUT" "Repositorio actualizado"
  assert_eq "" "$ERR" "no warnings"
  assert_eq "$head" "$(fix_head)" "HEAD unchanged"
  assert_eq "beta agent b1 v1" "$(cat "$PROJ/.claude/agents/b1.md")" "upstream change not applied"
}

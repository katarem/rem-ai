# O5-O6: uninstall restores the previous state and never deletes user files.

test_uninstall_restores_a_project_that_had_no_claude_dir() {
  make_fixture_repo
  local before
  before="$(snapshot "$PROJ")"
  rem_ai install "$PROJ" alpha beta >/dev/null

  run rem_ai uninstall "$PROJ"

  assert_eq 0 "$STATUS" "exit status"
  assert_eq "$before" "$(snapshot "$PROJ")" "project restored"
  assert_missing "$PROJ/.claude"
}

test_uninstall_keeps_user_files_and_their_directories() {
  make_fixture_repo
  write_file "$PROJ/.claude/settings.json" "{}"
  write_file "$PROJ/.claude/agents/mine.md" "user agent"
  write_file "$PROJ/.claude/rules/alpha/mine.md" "user rule inside a pack folder"
  local before
  before="$(snapshot "$PROJ")"
  rem_ai install "$PROJ" alpha beta >/dev/null

  run rem_ai uninstall "$PROJ"

  assert_eq 0 "$STATUS" "exit status"
  assert_eq "$before" "$(snapshot "$PROJ")" "project restored"
}

test_uninstall_runs_from_the_current_directory_by_default() {
  make_fixture_repo
  rem_ai install "$PROJ" alpha >/dev/null

  (cd "$PROJ" && rem_ai uninstall >/dev/null)

  assert_missing "$PROJ/.claude"
}

test_uninstall_single_pack_keeps_the_other_packs() {
  make_fixture_repo
  rem_ai install "$PROJ" alpha beta >/dev/null

  run rem_ai uninstall "$PROJ" beta

  assert_eq 0 "$STATUS" "exit status"
  assert_missing "$PROJ/.claude/agents/b1.md"
  assert_file "$PROJ/.claude/agents/a1.md"
  assert_eq "alpha" "$(manifest_packs "$PROJ/.claude")" "only alpha remains"
  assert_eq "" "$(awk -F'\t' '$2 == "beta"' "$PROJ/.claude/.rem-ai-manifest")" "no beta entries"
  assert_eq 5 "$(awk -F'\t' '$1 == "file" && $2 == "alpha"' "$PROJ/.claude/.rem-ai-manifest" | wc -l | tr -d ' ')" \
    "alpha entries kept"
}

test_uninstall_keeps_a_modified_copy_with_a_warning_and_stops_managing_it() {
  make_fixture_repo
  rem_ai install "$PROJ" alpha beta >/dev/null
  write_file "$PROJ/.claude/agents/a1.md" "edited by the user"

  run rem_ai uninstall "$PROJ" alpha

  assert_eq 0 "$STATUS" "exit status"
  assert_contains "$ERR" "modificado localmente, se conserva y deja de estar gestionado por rem-ai: agents/a1.md"
  assert_eq "edited by the user" "$(cat "$PROJ/.claude/agents/a1.md")" "modified copy kept"
  assert_eq "" "$(manifest_entry "$PROJ/.claude" agents/a1.md)" "no longer managed"
  assert_missing "$PROJ/.claude/rules/alpha"
  assert_eq "beta" "$(manifest_packs "$PROJ/.claude")" "beta still installed"
}

test_uninstall_force_removes_a_modified_copy() {
  make_fixture_repo
  rem_ai install "$PROJ" alpha >/dev/null
  write_file "$PROJ/.claude/agents/a1.md" "edited by the user"

  run rem_ai uninstall --force "$PROJ"

  assert_eq 0 "$STATUS" "exit status"
  assert_missing "$PROJ/.claude"
}

test_uninstall_global_removes_the_packs_but_keeps_home_claude_dir() {
  make_fixture_repo
  write_file "$HOME/.claude/settings.json" "{}"
  local before
  before="$(snapshot "$HOME/.claude")"
  rem_ai install --global alpha >/dev/null
  assert_file "$HOME/.claude/.rem-ai-manifest"

  run rem_ai uninstall --global

  assert_eq 0 "$STATUS" "exit status"
  assert_eq "$before" "$(snapshot "$HOME/.claude")" "global .claude restored"
}

test_uninstall_global_never_deletes_an_empty_home_claude_dir() {
  make_fixture_repo
  rem_ai install --global alpha >/dev/null

  rem_ai uninstall --global >/dev/null

  [[ -d "$HOME/.claude" ]] || fail "~/.claude must never be removed"
  assert_eq "." "$(snapshot "$HOME/.claude" | cut -d' ' -f1)" "~/.claude left empty"
}

test_uninstall_without_manifest_fails() {
  make_fixture_repo

  run rem_ai uninstall "$PROJ"

  assert_eq 1 "$STATUS" "exit status"
  assert_contains "$ERR" "no hay ninguna instalación de rem-ai"
}

test_uninstall_pack_not_installed_fails_without_changes() {
  make_fixture_repo
  rem_ai install "$PROJ" alpha >/dev/null
  local before
  before="$(snapshot "$PROJ")"

  run rem_ai uninstall "$PROJ" beta

  assert_eq 1 "$STATUS" "exit status"
  assert_contains "$ERR" "el pack 'beta' no está instalado"
  assert_eq "$before" "$(snapshot "$PROJ")" "installation must not change"
}

test_uninstall_link_restores_the_previous_state() {
  make_fixture_repo
  write_file "$PROJ/.claude/agents/mine.md" "user agent"
  local before
  before="$(snapshot "$PROJ")"
  rem_ai install --link "$PROJ" alpha beta >/dev/null

  run rem_ai uninstall "$PROJ"

  assert_eq 0 "$STATUS" "exit status"
  assert_eq "$before" "$(snapshot "$PROJ")" "project restored"
}

test_uninstall_link_keeps_a_symlink_replaced_by_a_real_file() {
  make_fixture_repo
  rem_ai install --link "$PROJ" alpha >/dev/null
  rm "$PROJ/.claude/rules/alpha/r1.md"
  write_file "$PROJ/.claude/rules/alpha/r1.md" "real user file"

  run rem_ai uninstall "$PROJ"

  assert_eq 0 "$STATUS" "exit status"
  assert_contains "$ERR" "deja de estar gestionado por rem-ai: rules/alpha/r1.md"
  assert_eq "real user file" "$(cat "$PROJ/.claude/rules/alpha/r1.md")" "real file kept"
  assert_eq ". dir
./rules dir
./rules/alpha dir
./rules/alpha/r1.md file $(sha256 "$PROJ/.claude/rules/alpha/r1.md")" \
    "$(snapshot "$PROJ/.claude")" "only the real file remains"
}

test_uninstall_link_keeps_a_symlink_pointing_elsewhere() {
  make_fixture_repo
  write_file "$SANDBOX/elsewhere/agent.md" "somewhere else"
  rem_ai install --link "$PROJ" alpha >/dev/null
  rm "$PROJ/.claude/agents/a1.md"
  ln -s "$SANDBOX/elsewhere/agent.md" "$PROJ/.claude/agents/a1.md"

  run rem_ai uninstall "$PROJ"

  assert_eq 0 "$STATUS" "exit status"
  assert_contains "$ERR" "agents/a1.md"
  assert_eq "$SANDBOX/elsewhere/agent.md" "$(readlink "$PROJ/.claude/agents/a1.md")" "foreign symlink kept"
  assert_missing "$PROJ/.claude/skills"
}

test_uninstall_rejects_manifest_paths_outside_the_install_dir() {
  make_fixture_repo
  write_file "$PROJ/outside/victim.md" "must survive"
  rem_ai install "$PROJ" alpha >/dev/null
  local manifest="$PROJ/.claude/.rem-ai-manifest"
  printf 'file\talpha\t../outside/victim.md\t%s\n' "$(sha256 "$PROJ/outside/victim.md")" >>"$manifest"
  local before
  before="$(snapshot "$PROJ")"

  run rem_ai uninstall --force "$PROJ"

  assert_eq 1 "$STATUS" "exit status"
  assert_contains "$ERR" "rutas no válidas"
  assert_eq "$before" "$(snapshot "$PROJ")" "nothing deleted"
}

test_uninstall_rejects_absolute_manifest_paths() {
  make_fixture_repo
  write_file "$PROJ/outside/victim.md" "must survive"
  rem_ai install "$PROJ" alpha >/dev/null
  printf 'file\talpha\t%s\t%s\n' "$PROJ/outside/victim.md" "$(sha256 "$PROJ/outside/victim.md")" >>"$PROJ/.claude/.rem-ai-manifest"

  run rem_ai uninstall --force "$PROJ"

  assert_eq 1 "$STATUS" "exit status"
  assert_file "$PROJ/outside/victim.md"
}

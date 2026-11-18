# O9: `rem-ai status` reports the installation without touching the network.

test_status_shows_packs_mode_and_installed_versus_repository_commit() {
  make_fixture_repo
  rem_ai install "$PROJ" alpha beta >/dev/null
  local installed
  installed="$(fix_head)"
  upstream_change "change b1" 'echo "beta agent b1 v2" > packs/beta/agents/b1.md'
  git -C "$FIX" pull -q --ff-only

  run rem_ai status "$PROJ"

  assert_eq 0 "$STATUS" "exit status"
  assert_contains "$OUT" "Instalación: $PROJ/.claude"
  assert_contains "$OUT" "Modo: copy"
  assert_contains "$OUT" "Packs: alpha beta"
  assert_contains "$OUT" "Commit instalado: $installed"
  assert_contains "$OUT" "Repositorio: $FIX @ $(fix_head)"
  assert_contains "$OUT" "Desactualizado: ejecuta 'rem-ai update'."
}

test_status_lists_modified_and_missing_files() {
  make_fixture_repo
  rem_ai install "$PROJ" alpha >/dev/null
  write_file "$PROJ/.claude/agents/a1.md" "edited by the user"
  rm "$PROJ/.claude/rules/alpha/sub/r2.md"

  run rem_ai status "$PROJ"

  assert_eq 0 "$STATUS" "exit status"
  assert_contains "$OUT" "  modificado: agents/a1.md"
  assert_contains "$OUT" "  falta: rules/alpha/sub/r2.md"
  assert_not_contains "$OUT" "rules/alpha/r1.md"
}

test_status_lists_a_replaced_symlink_as_modified_in_link_mode() {
  make_fixture_repo
  rem_ai install --link "$PROJ" alpha >/dev/null
  rm "$PROJ/.claude/agents/a1.md"
  write_file "$PROJ/.claude/agents/a1.md" "real user file"
  rm "$PROJ/.claude/skills/s1"

  run rem_ai status "$PROJ"

  assert_eq 0 "$STATUS" "exit status"
  assert_contains "$OUT" "Modo: link"
  assert_contains "$OUT" "  modificado: agents/a1.md"
  assert_contains "$OUT" "  falta: skills/s1"
}

test_status_lists_repository_files_not_installed() {
  make_fixture_repo
  rem_ai install "$PROJ" alpha >/dev/null
  write_file "$FIX/packs/alpha/agents/a2.md" "alpha agent a2"

  run rem_ai status "$PROJ"

  assert_eq 0 "$STATUS" "exit status"
  assert_contains "$OUT" "  no instalado: agents/a2.md"
}

test_status_reports_commits_behind_the_last_fetched_upstream() {
  make_fixture_repo
  rem_ai install "$PROJ" beta >/dev/null
  upstream_change "change b1" 'echo "beta agent b1 v2" > packs/beta/agents/b1.md'
  git -C "$FIX" fetch -q

  run rem_ai status "$PROJ"

  assert_eq 0 "$STATUS" "exit status"
  assert_contains "$OUT" "va 1 commits por detrás de upstream"
}

test_status_of_a_clean_installation_lists_no_file_problems() {
  make_fixture_repo
  rem_ai install "$PROJ" alpha >/dev/null

  run rem_ai status "$PROJ"

  assert_eq 0 "$STATUS" "exit status"
  assert_contains "$OUT" "Commit instalado: $(fix_head)"
  assert_not_contains "$OUT" "modificado:"
  assert_not_contains "$OUT" "falta:"
  assert_not_contains "$OUT" "no instalado:"
  assert_not_contains "$OUT" "Desactualizado"
}

test_status_without_manifest_fails() {
  make_fixture_repo

  run rem_ai status "$PROJ"

  assert_eq 1 "$STATUS" "exit status"
  assert_contains "$ERR" "no hay ninguna instalación de rem-ai en $PROJ/.claude"
}

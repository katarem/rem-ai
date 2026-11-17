# O11: `rem-ai setup` puts the CLI in the PATH and `self-uninstall` removes every trace.

registry() {
  echo "$XDG_CONFIG_HOME/rem-ai/installs"
}

test_self_setup_creates_a_symlink_in_the_bin_dir() {
  make_fixture_repo

  run rem_ai setup --bin-dir "$SANDBOX/bin"

  assert_eq 0 "$STATUS" "exit status"
  assert_eq "$FIX/scripts/rem-ai" "$(readlink "$SANDBOX/bin/rem-ai")" "symlink target"
  assert_contains "$OUT" "Creado $SANDBOX/bin/rem-ai"
  assert_contains "$ERR" "no está en el PATH"
}

test_self_setup_defaults_to_home_local_bin() {
  make_fixture_repo

  run rem_ai setup

  assert_eq 0 "$STATUS" "exit status"
  assert_eq "$FIX/scripts/rem-ai" "$(readlink "$HOME/.local/bin/rem-ai")" "symlink target"
}

test_self_setup_is_idempotent() {
  make_fixture_repo
  rem_ai setup --bin-dir "$SANDBOX/bin" >/dev/null 2>&1

  run rem_ai setup --bin-dir "$SANDBOX/bin"

  assert_eq 0 "$STATUS" "exit status"
  assert_contains "$OUT" "ya está configurado"
}

test_self_setup_refuses_to_replace_a_foreign_file_without_force() {
  make_fixture_repo
  write_file "$SANDBOX/bin/rem-ai" "another program"

  run rem_ai setup --bin-dir "$SANDBOX/bin"

  assert_eq 1 "$STATUS" "exit status"
  assert_contains "$ERR" "usa --force"
  assert_eq "another program" "$(cat "$SANDBOX/bin/rem-ai")" "foreign file intact"

  run rem_ai setup --force --bin-dir "$SANDBOX/bin"

  assert_eq 0 "$STATUS" "exit status"
  assert_eq "$FIX/scripts/rem-ai" "$(readlink "$SANDBOX/bin/rem-ai")" "replaced with --force"
}

test_self_invocation_through_the_symlink_resolves_the_real_repository() {
  make_fixture_repo
  rem_ai setup --bin-dir "$SANDBOX/bin" >/dev/null 2>&1

  run "$BASH" "$SANDBOX/bin/rem-ai" list
  assert_eq 0 "$STATUS" "exit status"
  assert_contains "$OUT" "  alpha "
  assert_contains "$OUT" "  beta "

  run "$BASH" "$SANDBOX/bin/rem-ai" install "$PROJ" alpha
  assert_eq 0 "$STATUS" "exit status"
  assert_eq "$FIX" "$(manifest_value "$PROJ/.claude" repo)" "repo resolved through the symlink"
}

test_self_invocation_through_a_relative_symlink_chain_resolves_the_real_repository() {
  make_fixture_repo
  mkdir -p "$SANDBOX/bin" "$SANDBOX/other"
  ln -s ../rem-ai/scripts/rem-ai "$SANDBOX/other/rem-ai"
  ln -s ../other/rem-ai "$SANDBOX/bin/rem-ai"

  run "$BASH" "$SANDBOX/bin/rem-ai" install "$PROJ" beta

  assert_eq 0 "$STATUS" "exit status"
  assert_eq "$FIX" "$(manifest_value "$PROJ/.claude" repo)" "repo resolved through the chain"
}

test_self_install_registers_and_full_uninstall_unregisters_the_destination() {
  make_fixture_repo
  mkdir -p "$SANDBOX/p2"
  rem_ai install "$PROJ" alpha >/dev/null
  rem_ai install "$SANDBOX/p2" beta >/dev/null
  rem_ai install "$PROJ" beta >/dev/null
  assert_eq "$PROJ/.claude
$SANDBOX/p2/.claude" "$(cat "$(registry)")" "registry without duplicates"

  rem_ai uninstall "$PROJ" beta >/dev/null
  assert_contains "$(cat "$(registry)")" "$PROJ/.claude"

  rem_ai uninstall "$PROJ" >/dev/null
  assert_eq "$SANDBOX/p2/.claude" "$(cat "$(registry)")" "removed after a full uninstall"
}

# install_everywhere: a copy install, a link install and a global install, plus the bin link.
install_everywhere() {
  mkdir -p "$SANDBOX/p2"
  write_file "$PROJ/.claude/settings.json" "{}"
  rem_ai install "$PROJ" alpha >/dev/null
  rem_ai install --link "$SANDBOX/p2" alpha beta >/dev/null
  rem_ai install --global beta >/dev/null
  rem_ai setup --bin-dir "$SANDBOX/bin" >/dev/null 2>&1
}

test_self_uninstall_without_yes_only_lists_and_changes_nothing() {
  make_fixture_repo
  install_everywhere
  local before
  before="$(snapshot "$PROJ"; snapshot "$SANDBOX/p2"; snapshot "$HOME"; snapshot "$SANDBOX/bin")"

  run rem_ai self-uninstall --bin-dir "$SANDBOX/bin"

  assert_eq 1 "$STATUS" "exit status"
  assert_contains "$OUT" "  $PROJ/.claude"
  assert_contains "$OUT" "  $SANDBOX/p2/.claude"
  assert_contains "$OUT" "  $HOME/.claude"
  assert_contains "$OUT" "Se eliminará el comando: $SANDBOX/bin/rem-ai"
  assert_contains "$OUT" "--yes"
  assert_eq "$before" "$(snapshot "$PROJ"; snapshot "$SANDBOX/p2"; snapshot "$HOME"; snapshot "$SANDBOX/bin")" \
    "nothing changed"
}

test_self_uninstall_with_yes_removes_installs_link_and_registry() {
  make_fixture_repo
  install_everywhere

  run rem_ai self-uninstall --yes --bin-dir "$SANDBOX/bin"

  assert_eq 0 "$STATUS" "exit status"
  assert_eq "{}" "$(cat "$PROJ/.claude/settings.json")" "user file kept"
  assert_eq ". dir
./settings.json file $(sha256 "$PROJ/.claude/settings.json")" "$(snapshot "$PROJ/.claude")" "copy install removed"
  assert_missing "$SANDBOX/p2/.claude"
  [[ -d "$HOME/.claude" ]] || fail "~/.claude must be kept"
  assert_missing "$HOME/.claude/.rem-ai-manifest"
  assert_missing "$HOME/.claude/agents/b1.md"
  assert_missing "$SANDBOX/bin/rem-ai"
  assert_missing "$(registry)"
  assert_contains "$OUT" "rm -rf $FIX"
  [[ -x "$FIX/scripts/rem-ai" ]] || fail "the clone itself must not be deleted"
}

test_self_uninstall_with_yes_keeps_modified_files_unless_forced() {
  make_fixture_repo
  rem_ai install "$PROJ" alpha >/dev/null
  write_file "$PROJ/.claude/agents/a1.md" "edited by the user"

  run rem_ai self-uninstall --yes --bin-dir "$SANDBOX/bin"

  assert_eq 0 "$STATUS" "exit status"
  assert_eq "edited by the user" "$(cat "$PROJ/.claude/agents/a1.md")" "modified file kept"
  assert_missing "$PROJ/.claude/.rem-ai-manifest"
  assert_missing "$(registry)"
}

test_self_uninstall_skips_registered_destinations_without_manifest() {
  make_fixture_repo
  rem_ai install "$PROJ" alpha >/dev/null
  rm -rf "$PROJ/.claude"

  run rem_ai self-uninstall --yes --bin-dir "$SANDBOX/bin"

  assert_eq 0 "$STATUS" "exit status"
  assert_contains "$OUT" "Sin manifiesto, se omite: $PROJ/.claude"
  assert_missing "$(registry)"
}

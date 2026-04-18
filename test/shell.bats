#!/usr/bin/env bats

setup() {
  load '/usr/local/lib/bats-support/load'
  load '/usr/local/lib/bats-assert/load'
  load '/usr/local/lib/bats-file/load'
}

# --- .bashrc integrations ---

@test "bashrc sources aliases" {
  run grep -q '\. ~/\.aliases\|source.*aliases' "$HOME/.bashrc"
  assert_success
}

@test "bashrc configures asdf PATH" {
  run grep -q 'ASDF_DATA_DIR' "$HOME/.bashrc"
  assert_success
}

@test "bashrc initializes starship" {
  run grep -q 'starship init bash' "$HOME/.bashrc"
  assert_success
}

@test "bashrc initializes fzf" {
  run grep -q 'fzf --bash' "$HOME/.bashrc"
  assert_success
}

@test "bashrc initializes direnv" {
  run grep -q 'direnv hook bash' "$HOME/.bashrc"
  assert_success
}

@test "bashrc sets EDITOR to nvim" {
  run grep -q 'EDITOR=nvim' "$HOME/.bashrc"
  assert_success
}

# --- .aliases checks ---

@test "aliases has git status alias" {
  run grep -q "alias gs='git status'" "$HOME/.aliases"
  assert_success
}

@test "aliases has chezmoi alias" {
  run grep -q "alias c=chezmoi" "$HOME/.aliases"
  assert_success
}

@test "docker is NOT aliased to podman (podman=false)" {
  run grep "alias docker='podman'" "$HOME/.aliases"
  assert_failure
}

@test "docker aliases are present" {
  run grep -q "alias d='docker'" "$HOME/.aliases"
  assert_success
}

# --- Shell login test ---

@test "bash login shell starts without errors" {
  run timeout 10 bash --login -c 'echo ok' 2>&1
  assert_success
  assert_output --partial "ok"
}

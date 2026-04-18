#!/usr/bin/env bats

setup() {
  load '/usr/local/lib/bats-support/load'
  load '/usr/local/lib/bats-assert/load'
}

# --- asdf-managed packages ---

@test "neovim is installed at correct version" {
  run nvim --version
  assert_success
  assert_line --index 0 --partial "NVIM v0.11.1"
}

@test "erlang is installed" {
  run erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().' -noshell
  assert_success
  assert_output --partial "27"
}

@test "elixir is installed at correct version" {
  run elixir --version
  assert_success
  assert_output --partial "Elixir 1.18.1"
}

@test "golang is installed at correct version" {
  run go version
  assert_success
  assert_output --partial "go1.23.1"
}

@test "nodejs is installed at correct version" {
  run node --version
  assert_success
  assert_output --partial "v22.14.0"
}

@test "python is installed at correct version" {
  run python3 --version
  assert_success
  assert_output --partial "3.11.10"
}

@test "lua is installed" {
  run lua -v
  assert_success
  assert_output --partial "5.1.5"
}

@test "fzf is installed at correct version" {
  run fzf --version
  assert_success
  assert_output --partial "0.57.0"
}

@test "ripgrep is installed" {
  run rg --version
  assert_success
  assert_output --partial "14.1.1"
}

@test "fd is installed" {
  run fd --version
  assert_success
  assert_output --partial "10.2.0"
}

@test "direnv is installed" {
  run direnv version
  assert_success
  assert_output --partial "2.35.0"
}

@test "github-cli is installed" {
  run gh --version
  assert_success
  assert_output --partial "2.67.0"
}

@test "helm is installed" {
  run helm version --short
  assert_success
  assert_output --partial "v3.16.4"
}

@test "kubectl is installed" {
  run kubectl version --client
  assert_success
}

@test "flyctl is installed" {
  run flyctl version
  assert_success
}

# --- npm packages ---

@test "prettier is installed" {
  run prettier --version
  assert_success
}

# --- pip packages ---

@test "sqlfluff is installed" {
  run sqlfluff version
  assert_success
}

@test "thefuck is installed" {
  run thefuck --version
  assert_success
}

@test "neovim-remote is installed" {
  run nvr --version
  assert_success
}

@test "uv is installed" {
  run uv --version
  assert_success
}

# --- cargo packages ---

@test "starship is installed" {
  run starship --version
  assert_success
}

# --- go packages ---

@test "gitmux is installed" {
  run which gitmux
  assert_success
}

#!/usr/bin/env bats

setup() {
  load '/usr/local/lib/bats-support/load'
  load '/usr/local/lib/bats-assert/load'
  load '/usr/local/lib/bats-file/load'
}

# --- Shell config files ---

@test ".bashrc exists" {
  assert_file_exists "$HOME/.bashrc"
}

@test ".aliases exists" {
  assert_file_exists "$HOME/.aliases"
}

@test ".bash_completion exists" {
  assert_file_exists "$HOME/.bash_completion"
}

# --- Dotfiles ---

@test ".tmux.conf exists" {
  assert_file_exists "$HOME/.tmux.conf"
}

@test ".prettierrc.json exists" {
  assert_file_exists "$HOME/.prettierrc.json"
}

@test ".taskrc exists" {
  assert_file_exists "$HOME/.taskrc"
}

@test ".vale.ini exists" {
  assert_file_exists "$HOME/.vale.ini"
}

# --- Config files ---

@test "starship.toml exists" {
  assert_file_exists "$HOME/.config/starship.toml"
}

@test "nvim init.lua exists" {
  assert_file_exists "$HOME/.config/nvim/init.lua"
}

@test "fastfetch config exists" {
  assert_file_exists "$HOME/.config/fastfetch/config.jsonc"
}

# --- Linux-specific files ---

@test "systemd ssh-agent service exists" {
  assert_file_exists "$HOME/.config/systemd/user/ssh-agent.service"
}

@test "ssh-agent service has correct content" {
  run cat "$HOME/.config/systemd/user/ssh-agent.service"
  assert_output --partial "ssh-agent"
  assert_output --partial "WantedBy=default.target"
}

@test "environment.d ssh_auth_socket.conf exists" {
  assert_file_exists "$HOME/.config/environment.d/ssh_auth_socket.conf"
}

@test "environment.d ssh_askpass.conf exists" {
  assert_file_exists "$HOME/.config/environment.d/ssh_askpass.conf"
}

# --- Default package files ---

@test ".default-npm-packages exists" {
  assert_file_exists "$HOME/.default-npm-packages"
}

@test ".default-python-packages exists" {
  assert_file_exists "$HOME/.default-python-packages"
}

@test ".default-cargo-crates exists" {
  assert_file_exists "$HOME/.default-cargo-crates"
}

@test ".default-golang-pkgs exists" {
  assert_file_exists "$HOME/.default-golang-pkgs"
}

# --- Directories ---

@test "tmux plugin manager is installed" {
  assert_dir_exists "$HOME/.tmux/plugins/tpm"
}

@test "asdf data directory exists" {
  assert_dir_exists "$HOME/.asdf"
}

@test "asdf binary exists and is executable" {
  assert_file_executable "$HOME/.local/bin/asdf"
}

# --- Template rendering (Linux should NOT have macOS files) ---

@test ".zshrc should not exist on Linux" {
  assert_file_not_exists "$HOME/.zshrc"
}

@test ".zprofile should not exist on Linux" {
  assert_file_not_exists "$HOME/.zprofile"
}

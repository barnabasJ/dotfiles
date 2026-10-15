# Elixir debugging with EDB

Chezmoi owns this Neovim configuration on Ubuntu. On NixOS, Home Manager
deploys the matching files from `features/terminal/user-config/assets/nvim/`
in the NixOS repository. Keep the plugin spec and recovery helper in sync
when changing debugger behavior.

The plugin spec installs nvim-dap from Codeberg. Both chezmoi platform lockfiles
pin it to `cfa2d58f4537aca6ca83e2de1a0d9f1491121264`. The accompanying
`lua/barnabasj/edb.lua` helper restores the selected paused process after a
rejected step. Its source revision is recorded in the file header.

## Runtime setup

EDB requires OTP 29 and compatible Elixir. To install the preferred debugger
runtimes alongside existing project defaults:

```sh
mise install erlang@29.1 elixir@1.20.4-otp-29
```

Build [barnabasJ/edb](https://github.com/barnabasJ/edb) with OTP 29 and rebar3
(`rebar3 escriptize`). The plugin uses `EDB`, an `edb` executable on PATH, or
`$HOME/sandbox/edb/_build/default/bin/edb`, in that order. Set `EDB_ROOT` if the
checkout lives elsewhere. The recovery helper is bundled with the configuration
and does not require an EDB source checkout.

Installed mise debugger runtimes are preferred only for the debugger and test
processes; they do not change the project's mise defaults. Alternatively a Nix
shell can provide OTP 29, compatible Elixir and EDB on PATH. `EDB_OTP_BIN` and
`EDB_ELIXIR_BIN` override the runtime bin directories. `MISE_DATA_DIR` and
`XDG_DATA_HOME` are respected when locating mise installs. NixOS continues to own
Neovim and mise; lazy.nvim owns the plugin. Mason does not install EDB.

Configure the project's `edb_mix` dependency and compiler as described in
[EDB's Elixir guide](https://github.com/barnabasJ/edb/blob/main/docs/ELIXIR.md).
ExUnit debugging uses `mix edb.test`, including instrumentation of `.exs` files.

## Using it

Open a test file, place the cursor inside a test, set a breakpoint, and start
`edb: test at cursor`. `edb: current test file` runs all tests in that file.
The launch finds the nearest `mix.exs` and sets `MIX_ENV=test`.

The leader is Space:

| Binding | Action |
| --- | --- |
| `<leader>dc` | Start / continue |
| `<leader>dt` | Toggle breakpoint |
| `<leader>dn` | Step over |
| `<leader>di` | Step into |
| `<leader>do` | Step out |
| `<leader>dx` | Stop |
| `<leader>dr` | Open REPL / output |
| `<leader>dv` | Inspect scopes |

`<leader>db` remains the database UI binding. The which-key `<leader>d` group
is named Debug. In the REPL, `.scopes` shows locals and process information;
Elixir expressions such as `user.name` evaluate in the selected frame.

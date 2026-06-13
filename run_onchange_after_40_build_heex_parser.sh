#!/usr/bin/env bash
# Build the patched tree-sitter-heex parser used by Neovim for colocated JS/CSS
# highlighting + LSP (LiveView colocated hooks). The fork adds a `raw_text` node
# for <script>/<style> bodies; nvim loads the result via language.add (see
# private_dot_config/nvim/lua/barnabasj/lazy/treesitter.lua).
#
# chezmoi re-runs this script whenever its contents change, so bumping SHA below
# (to a newer fork commit) triggers a rebuild.
set -euo pipefail

# Pinned commit of barnabasJ/tree-sitter-heex (branch feat/raw-text-script-style)
SHA="4e7ea84e6fa07240770faaae61ce3b88d7a02c43"
BRANCH="feat/raw-text-script-style"
REPO="https://github.com/barnabasJ/tree-sitter-heex.git"

DATA="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/heex-fork"
OUT="$DATA/parser/heex.so"
STAMP="$DATA/.built-sha"

if ! command -v cc >/dev/null 2>&1; then
	echo "build_heex_parser: no C compiler (cc) found — skipping; nvim will use the stock heex parser." >&2
	exit 0
fi
if ! command -v git >/dev/null 2>&1; then
	echo "build_heex_parser: git not found — skipping." >&2
	exit 0
fi

# Already built at this SHA? Nothing to do.
if [ -f "$OUT" ] && [ "$(cat "$STAMP" 2>/dev/null || true)" = "$SHA" ]; then
	exit 0
fi

echo "build_heex_parser: building patched tree-sitter-heex @ ${SHA:0:12} …"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# The parser is an enhancement: a build failure (e.g. offline, or a sandboxed
# CI with no network) must NOT abort `chezmoi apply`. Neovim already falls back
# to the stock parser when $OUT is absent, so on any failure we warn and exit 0.
build() {
	git clone -q --depth 1 --branch "$BRANCH" "$REPO" "$TMP/src" || return 1
	got="$(git -C "$TMP/src" rev-parse HEAD)"
	if [ "$got" != "$SHA" ]; then
		echo "build_heex_parser: WARNING branch tip ($got) != pinned SHA ($SHA); building branch tip." >&2
	fi

	mkdir -p "$DATA/parser"

	# Linux: -shared; macOS: -bundle/-undefined dynamic_lookup (classic nvim
	# parser flags). Output is named heex.so on both — Neovim loads .so on macOS.
	local flags
	case "$(uname -s)" in
	Darwin) flags=(-bundle -undefined dynamic_lookup) ;;
	*) flags=(-shared) ;;
	esac

	cc "${flags[@]}" -fPIC -Os -I "$TMP/src/src" \
		"$TMP/src/src/parser.c" "$TMP/src/src/scanner.c" \
		-o "$OUT" || return 1
}

if build; then
	echo "$SHA" >"$STAMP"
	echo "build_heex_parser: built -> $OUT"
else
	echo "build_heex_parser: build failed — keeping stock heex parser. Re-run 'chezmoi apply' when back online." >&2
fi

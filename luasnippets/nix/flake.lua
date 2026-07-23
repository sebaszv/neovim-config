local s = require("luasnip").snippet
local t = require("luasnip").text_node
local i = require("luasnip").insert_node
local d = require("luasnip").dynamic_node
local sn = require("luasnip").snippet_node

local util = require("util")

--- Nix flake candidate snippet condition validator.
---@return boolean
local function valid_blank_flake_cond()
  if not vim.endswith(vim.api.nvim_buf_get_name(0), "flake.nix") then
    return false
  end

  local ok, parser = pcall(vim.treesitter.get_parser, 0, "nix")

  if not (ok and parser) then
    return false
  end

  local trees = parser:parse()

  if not trees then
    return false
  end

  local root = trees[1]:root()

  for child in root:iter_children() do
    if child:named() and child:type() ~= "comment" then
      -- The only acceptable non-comment node is the
      -- trigger text itself being parsed as an identifier.
      if child:type() ~= "variable_expression" then
        return false
      end

      local text = vim.treesitter.get_node_text(child, 0)

      return ("flake"):find("^" .. vim.pesc(text)) ~= nil
    end
  end

  return true
end

return {
  s({
    trig = "flake",
    desc = "Nix flake boilerplate",
    condition = valid_blank_flake_cond,
    show_condition = valid_blank_flake_cond,
  }, {
    d(1, function()
      -- A dynamic node is used to track the
      -- real current buffer shiftwidth.
      local indent = util.whitespace.indenter()

      return sn(nil, {
        t({
          "{",
          indent("inputs = {"),
          indent(2, 'systems.url = "github:nix-systems/default";'),
          indent(2, 'nixpkgs.url = "github:NixOS/nixpkgs/'),
        }),
        i(1, "nixos-unstable"),
        t({
          '";',
          "",
          indent(2, "treefmt-nix = {"),
          indent(3, 'url = "github:numtide/treefmt-nix";'),
          indent(3, 'inputs.nixpkgs.follows = "nixpkgs";'),
          indent(2, "};"),
          indent(2, "pre-commit-hooks = {"),
          indent(3, 'url = "github:cachix/git-hooks.nix";'),
          indent(3, 'inputs.nixpkgs.follows = "nixpkgs";'),
          indent(2, "};"),
          indent("};"),
        }),
        t({
          "",
          "",
          indent("outputs ="),
          indent(2, "{"),
          indent(3, "systems,"),
          indent(3, "nixpkgs,"),
          indent(3, "treefmt-nix,"),
          indent(3, "pre-commit-hooks,"),
          indent(3, "..."),
          indent(2, "}:"),
          indent(2, "let"),
          indent(3, "eachSystem ="),
          indent(4, "f:"),
          indent(4, "nixpkgs.lib.genAttrs (import systems) ("),
          indent(5, "system:"),
          indent(5, "f {"),
          indent(6, "inherit system;"),
          indent(6, "pkgs = nixpkgs.legacyPackages.${system};"),
          indent(5, "}"),
          indent(4, ");"),
          "",
          indent(3, "wrappedTreefmt = eachSystem ("),
          indent(4, "{ pkgs, ... }:"),
          indent(4, "(treefmt-nix.lib.evalModule pkgs {"),
          indent(5, 'projectRootFile = "flake.nix";'),
          indent(5, "programs = {"),
          indent(6, "nixfmt.enable = true;"),
          indent(5, "};"),
          indent(4, "}).config.build.wrapper"),
          indent(3, ");"),
          indent(3, "preCommitHooks = eachSystem ("),
          indent(4, "{ system, ... }:"),
          indent(4, "rec {"),
          indent(5, "check = pre-commit-hooks.lib.${system}.run {"),
          indent(6, "src = ./.;"),
          indent(6, "hooks.treefmt = {"),
          indent(7, "enable = true;"),
          indent(7, "package = wrappedTreefmt.${system};"),
          indent(6, "};"),
          indent(5, "};"),
          indent(5, "installationScript = check.shellHook;"),
          indent(4, "}"),
          indent(3, ");"),
          indent(2, "in"),
          indent(2, "{"),
          indent(3, "formatter = eachSystem ({ system, ... }: wrappedTreefmt.${system});"),
          indent(3, "checks = eachSystem ("),
          indent(4, "{ system, ... }:"),
          indent(4, "{"),
          indent(5, "pre-commit = preCommitHooks.${system}.check;"),
          indent(4, "}"),
          indent(3, ");"),
          indent(3, "devShells = eachSystem ("),
          indent(4, "{ pkgs, system }:"),
          indent(4, "{"),
          indent(5, "default = pkgs.mkShellNoCC {"),
          indent(6, "shellHook = preCommitHooks.${system}.installationScript;"),
          indent(6, "packages = with pkgs; ["),
          indent(7, "git"),
          indent(7, "nil"),
          indent(7, "deadnix"),
          indent(7, "statix"),
          indent(6, "];"),
          indent(5, "};"),
          indent(4, "}"),
          indent(3, ");"),
          indent(2, "};"),
          "}",
        }),
      })
    end),
  }),
  s({
    trig = "flakept",
    desc = "Nix flake boilerplate using flake-parts",
    condition = valid_blank_flake_cond,
    show_condition = valid_blank_flake_cond,
  }, {
    d(1, function()
      -- A dynamic node is used to track the
      -- real current buffer shiftwidth.
      local indent = util.whitespace.indenter()

      return sn(nil, {
        t({
          "{",
          indent("inputs = {"),
          indent(2, 'systems.url = "github:nix-systems/default";'),
          indent(2, 'nixpkgs.url = "github:NixOS/nixpkgs/'),
        }),
        i(1, "nixos-unstable"),
        t({
          '";',
          indent(2, "flake-parts = {"),
          indent(3, 'url = "github:hercules-ci/flake-parts";'),
          indent(3, 'inputs.nixpkgs-lib.follows = "nixpkgs";'),
          indent(2, "};"),
          "",
          indent(2, "treefmt-nix = {"),
          indent(3, 'url = "github:numtide/treefmt-nix";'),
          indent(3, 'inputs.nixpkgs.follows = "nixpkgs";'),
          indent(2, "};"),
          indent(2, "pre-commit-hooks = {"),
          indent(3, 'url = "github:cachix/git-hooks.nix";'),
          indent(3, 'inputs.nixpkgs.follows = "nixpkgs";'),
          indent(2, "};"),
          indent("};"),
        }),
        t({
          "",
          "",
          indent("outputs ="),
          indent(2, "{"),
          indent(3, "systems,"),
          indent(3, "flake-parts,"),
          indent(3, "treefmt-nix,"),
          indent(3, "pre-commit-hooks,"),
          indent(3, "..."),
          indent(2, "}@inputs:"),
          indent(2, "flake-parts.lib.mkFlake { inherit inputs; } {"),
          indent(3, "systems = import systems;"),
          "",
          indent(3, "imports = ["),
          indent(4, "treefmt-nix.flakeModule"),
          indent(4, "pre-commit-hooks.flakeModule"),
          indent(3, "];"),
          "",
          indent(3, "perSystem ="),
          indent(4, "{ config, pkgs, ... }:"),
          indent(4, "{"),
          indent(5, "treefmt = {"),
          indent(6, "# Whether to set `formatter` to the wrapped `treefmt`"),
          indent(6, "# derivation that will use a generated config file and"),
          indent(6, "# the needed formatters."),
          indent(6, "flakeFormatter = true;"),
          indent(6, "# Whether to add the formatting check `checks.treefmt`."),
          indent(6, "# This concern is handled by `checks.pre-commit` when"),
          indent(6, "# `hooks.treefmt.enable` is set as it runs `flakeFormatter`"),
          indent(6, "# already. Having both is redundant."),
          indent(
            6,
            "flakeCheck = !(config.pre-commit.check.enable && config.pre-commit.settings.hooks.treefmt.enable);"
          ),
          indent(6, "programs = {"),
          indent(7, "nixfmt.enable = true;"),
          indent(6, "};"),
          indent(5, "};"),
          "",
          indent(5, "pre-commit = {"),
          indent(6, "# Whether to add the check `checks.pre-commit` that will"),
          indent(6, "# run the hook checks."),
          indent(6, "check.enable = true;"),
          indent(6, "settings.hooks = {"),
          indent(7, "treefmt = {"),
          indent(8, "enable = true;"),
          indent(8, "# The flake-module already does this, but ensuring"),
          indent(8, "# doesn't hurt."),
          indent(8, "package = config.treefmt.build.wrapper;"),
          indent(7, "};"),
          indent(6, "};"),
          indent(5, "};"),
          "",
          indent(5, "devShells.default = pkgs.mkShellNoCC {"),
          indent(6, "shellHook = config.pre-commit.installationScript;"),
          indent(6, "packages = with pkgs; ["),
          indent(7, "git"),
          indent(7, "nil"),
          indent(7, "deadnix"),
          indent(7, "statix"),
          indent(6, "];"),
          indent(5, "};"),
          indent(4, "};"),
          indent(2, "};"),
          "}",
        }),
      })
    end),
  }),
}

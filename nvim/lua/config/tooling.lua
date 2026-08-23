--[[ Configure LSP servers, DAP adapters, Linters and Formatters

     Make sure mason's bin directory is available and trumps any system
     installed version of the tools. Mason may not yet be lazy loaded.

]]

local functional = require 'lib.functional'
local platform = require 'core.platform'

local concat = functional.concat_arrays
local flatten = functional.flatten_array
local keys = functional.get_table_keys
local sort_uniq = functional.sort_array_uniq
local values = functional.get_table_values

local M = {}

vim.env.PATH = vim.fs.joinpath(vim.fn.stdpath 'data', 'mason', 'bin')
   .. platform.path_list_sep
   .. vim.env.PATH

-- -- hererocks' bin, so lazy.nvim can resolve `luarocks.bat` by name.
-- -- libuv resolves bare command names against the parent process's
-- -- PATH, not the `env` table passed to the child -- so lazy's own
-- -- env is not enough.
-- vim.env.PATH = vim.fs.joinpath(
--    vim.fn.stdpath 'data',
--    'lazy-rocks',
--    'hererocks',
--    'bin'
-- ) .. platform.path_list_sep .. vim.env.PATH

-- LSP servers managed by Neovim via ~/.config/nvim/lsp/
local lsp_servers_nvim = {
   ast_grep = 'ast-grep',
   bashls = 'bash-language-server',
   cssls = 'css-lsp',
   cssmodules_ls = 'cssmodules-language-server',
   css_variables = 'css-variables-language-server',
   html = 'html-lsp',
   lua_ls = 'lua-language-server',
   marksman = 'marksman',
   ruff = 'ruff',
   tombi = 'tombi',
   zls = 'zls',
   zuban = 'zuban',
}

-- LSP servers managed by plugins
local lsp_servers_plugins = {
   luau_lsp = 'luau-lsp', -- plugin: lopi-py/luau-lsp.nvim
   rust_analyzer = 'rust-analyzer', -- plugin: mrcjkb/rustaceanvim
   -- plugin: nvim-metals installs Metals via Coursier
}

M.lsp_servers_nvim = keys(lsp_servers_nvim)
M.lsp_servers_mason =
   concat(values(lsp_servers_nvim), values(lsp_servers_plugins))

local debug_adapters = {
   python = 'debugpy',
   codelldb = 'codelldb',
}

M.debug_adapters_dap = keys(debug_adapters)
M.debug_adapters_mason = values(debug_adapters)

M.linters = {
   css = { 'stylelint' },
   gitcommit = { 'gitlint' },
   haskell = { 'hlint' },
   html = { 'markuplint' },
   javascript = { 'eslint_d' },
   javascriptreact = { 'eslint_d' },
   json = { 'jsonlint' },
   lua = { 'selene' },
   luau = { 'selene' },
   markdown = { 'markdownlint-cli2' },
   python = { 'sphinx-lint' },
   rst = { 'rstcheck', 'sphinx-lint' },
   sh = { 'shellcheck' },
   svelte = { 'eslint_d' },
   typescript = { 'eslint_d' },
   typescriptreact = { 'eslint_d' },
   vue = { 'eslint_d' },
}

M.formatters = {
   c = { 'clang-format' },
   clojure = { 'cljfmt' },
   cpp = { 'clang-format' },
   css = { 'prettierd' },
   haskell = { 'fourmolu' },
   html = { 'prettierd' },
   java = { 'clang-format' },
   js = { 'clang-format' },
   lua = { 'stylua' },
   luau = { 'stylua' },
   markdown = { 'mdformat', 'markdown-toc' },
   sh = { 'shfmt' },
   json = { 'clang-format' },
   yaml = { 'prettierd' },
}

M.linters_and_formatters_mason = sort_uniq(
   concat(flatten(values(M.linters)), flatten(values(M.formatters)))
)

return M

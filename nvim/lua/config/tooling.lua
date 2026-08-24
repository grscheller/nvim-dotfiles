--[[ Configure LSP servers, DAP adapters, linters and formatters

     Pure data, with one exception: the `$PATH` adjustment just above
     `return M`. That belongs here because this module is required by
     `core.lsp`, which `init.lua` runs before `core.lazy` -- so Mason's
     `bin` is on the path before any plugin loads, including Mason
     itself, which is lazy loaded on its own commands.

]]

local functional = require 'lib.functional'
local platform = require 'core.platform'

local concat = functional.concat_arrays
local flatten = functional.flatten_array
local keys = functional.get_table_keys
local sort_uniq = functional.sort_array_uniq
local values = functional.get_table_values

local M = {}

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
   -- cljfmt is a JVM program. On Linux the fish function `jdk_version`
   -- puts a JDK on $PATH; there is no equivalent here.
   clojure = platform.is_windows and {} or { 'cljfmt' },
   cpp = { 'clang-format' },
   css = { 'prettierd' },
   -- fourmolu publishes Linux binaries only. Mason's manifest has no
   -- Windows target: "The current platform is unsupported."
   haskell = platform.is_windows and {} or { 'fourmolu' },
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

--[[ $PATH adjustment

     Mason's `bin` goes first so its tools win over any system
     installed version. Runs once, when this module is first required.
]]

vim.env.PATH = vim.fs.joinpath(vim.fn.stdpath 'data', 'mason', 'bin')
   .. platform.path_list_sep
   .. vim.env.PATH

--[[ Rejected: hererocks on Windows -- do not re-enable

     Kept as a record, because the obvious fix makes things worse.

     hererocks itself builds fine on Windows once a `python` is on
     $PATH. What fails is lazy.nvim invoking the luarocks it produced:

       Failed to spawn process luarocks.bat ... env = { PATH = ... }

     The env lazy.nvim passes is correct, but libuv resolves a bare
     command name against the *parent* process's $PATH, not the env
     handed to the child. Demonstrated with:

       :=vim.system({'luarocks.bat', '--version'}):wait()
       -> ENOENT: no such file or directory (cmd): 'luarocks.bat'

       :lua vim.env.PATH = <hererocks>/bin .. ';' .. vim.env.PATH
       :=vim.system({'luarocks.bat', '--version'}):wait()
       -> code = 0, LuaRocks 3.13.0

     So prepending hererocks' bin below looks like the fix. It is not.
     With a luarocks visible on $PATH, lazy.nvim concludes hererocks is
     unnecessary, marks it for Clean, and switches to invoking bare
     `luarocks` with an empty env -- which fails the same way, minus
     the `.bat` extension. Strictly worse than leaving it alone.

     Neorg and its two tree-sitter-norg rocks are disabled on Windows
     instead. See `plugins/neorg.lua`.
]]

-- vim.env.PATH = vim.fs.joinpath(
--    vim.fn.stdpath 'data',
--    'lazy-rocks',
--    'hererocks',
--    'bin'
-- ) .. platform.path_list_sep .. vim.env.PATH

return M

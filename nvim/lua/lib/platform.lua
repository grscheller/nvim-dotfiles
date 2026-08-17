--[[ Platform detection

     Single source of truth for the handful of places where this
     configuration must behave differently on MS Windows than on
     Linux. Keeping the tests here rather than scattered through
     the config makes the platform surface auditable -- grep this
     module's consumers to see the whole of it.

]]

local M = {}

--[[ Predicates ]]

-- `win32` means "MS Windows", not "32-bit". It is 1 on 64-bit Windows as well,
-- and is the test Neovim itself documents.
M.is_windows = vim.fn.has 'win32' == 1

--[[ Path components ]]

-- Separator between entries of $PATH and friends.
--
-- NOTE: There is deliberately no `path_sep` ('\' vs '/') here. Neovim accepts
--       forward slashes on Windows, and `vim.fs.joinpath` already produces
--       portable results, so nothing in this config needs to build a path by
--       hand.
M.path_list_sep = M.is_windows and ';' or ':'

--[[ Shells ]]

-- Two distinct concerns:
--
-- - `shell` is what `vim.o.shell` gets. Plugins, `:!` and lazy
--   build strings drive it non-interactively and expect POSIX
--   syntax, so it is a POSIX shell on both platforms.
-- - `term_shell` is what `:terminal` gets when opened by hand.
--   Personal preference, not a compatibility constraint.
--
-- On Windows the POSIX shell comes from MSYS2. `dash.exe` is an
-- MSYS-runtime binary, but it resolves `msys-2.0.dll` out of its
-- own directory, so MSYS2 need not be on the native $PATH --
-- which is just as well, since putting it there would shadow
-- Windows' own find.exe, sort.exe and friends.
--
-- $MSYS2_ROOT overrides the install location. Falling back to
-- `pwsh` keeps Neovim usable on a box without MSYS2, at the cost
-- of POSIX syntax in `:!` and lazy build strings.

---@return string
local function windows_posix_shell()
   local root = vim.env.MSYS2_ROOT or 'C:/msys64'
   local dash = vim.fs.joinpath(root, 'usr', 'bin', 'dash.exe')
   return vim.uv.fs_stat(dash) and dash or 'pwsh'
end

M.shell = M.is_windows and windows_posix_shell() or '/bin/sh'
M.term_shell = M.is_windows and 'pwsh' or 'fish'

-- True when `M.shell` actually understands POSIX syntax. Only
-- false on Windows when the MSYS2 fallback to `pwsh` kicked in.
M.shell_is_posix = not M.is_windows or M.shell ~= 'pwsh'

--[[ Executable resolution ]]

---Resolve an executable to a full path.
---
---Needed because Mason and npm install `.cmd` shims on Windows
---rather than extension-less files, so an absolute path built by
---hand will not resolve. `exepath` applies $PATHEXT for us.
---
---Returns nil rather than a bare name when nothing is found, so
---callers decide whether a miss is fatal:
---
---```lua
---command = platform.exe 'codelldb' or 'codelldb',
---```
---
---@param name string  Executable to look for on $PATH.
---@return string|nil  Full path, or nil when not found.
function M.exe(name)
   local path = vim.fn.exepath(name)
   return path ~= '' and path or nil
end

return M

-- Define filetype overrides before loading plugins
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.bash_secure",
	command = "set filetype=secure",
})

-- bootstrap lazy.nvim
require("config.lazy")
-- require("config.keymaps")
require("config.autocmds")

-- Set line numbers
vim.opt.number = true

-- Minimum number of screen lines above/below the cursor
vim.opt.scrolloff = 10

-- Show the line and column number of the cursor position
vim.opt.ruler = true

-- Set the width of the tab character
vim.opt.tabstop = 2

-- Set the width of the soft tab character
vim.opt.shiftwidth = 2

-- Set Paste mode for easier pasting from external sources
-- vim.opt.paste = true

-- Show (partial) command in the last line of the screen
-- vim.opt.showcmd = true

-- When a bracket is inserted, briefly jump to the matching one
-- vim.opt.showmatch = true

-- Configuring the statusline. For appending, you have to reconstruct it since there's no direct append method in Lua.
-- Assuming 'statusline' is already set to something, and you want to add to it:
-- Note: Direct manipulation like this might not directly translate. You'll likely need to adjust the statusline setup more comprehensively in Lua.
-- vim.opt.statusline = vim.opt.statusline:get() .. "%#warningmsg#" -- switch to warningmsg color
-- vim.opt.statusline = vim.opt.statusline:get() .. "%*" -- back to normal color

-- Allows backspace to delete over line breaks, indentation, and the start of insert action
-- vim.opt.backspace = { "indent", "eol", "start" }
--
--     local au = vim.api.nvim_create_autocmd
--

-- Disable mouse mode
-- TODO: This shouldn't be disabled but clipboard isn't working
vim.opt.mouse = ''

return {
	{
		"jmbuhr/otter.nvim",
		config = function()
			-- function otter_extensions(arglead, _, _)
			-- 	local extensions = require 'otter.tools.extensions'
			-- 	local out = {
			-- 		"*.otter.jq",
			-- 	}
			-- 	for k, v in pairs(extensions) do
			-- 		if arglead == nil then
			-- 			table.insert(out, "*.otter." .. v)
			-- 		elseif k:find("^" .. arglead) ~= nil then
			-- 			table.insert(out, k)
			-- 		end
			-- 	end
			-- 	return out
			-- end
			--
			-- print(vim.inspect(otter_extensions()))
			-- vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
			-- 	group = vim.api.nvim_create_augroup("lspconfig", { clear = false }),
			-- 	pattern = otter_extensions(),
			-- 	callback = function(ev)
			-- 		local buf = ev.buf
			-- 		local ft = vim.api.nvim_get_option_value("filetype", { buf = ev.buf })
			-- 		local matching_configs = require('lspconfig.util').get_config_by_ft(ft)
			-- 		for _, config in ipairs(matching_configs) do
			-- 			print("Activating ", config.name, " LspOtter in buffer ", buf, "...")
			-- 			config.launch(buf)
			-- 		end
			-- 	end
			-- })
			-- vim.cmd [[ command! -nargs=* -complete=customlist,v:lua.otter_extensions LspOtter lua require'otter'.activate({<f-args>}) ]]
		end
	},
}

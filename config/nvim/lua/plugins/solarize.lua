return {
	{
		"ishan9299/nvim-solarized-lua",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd [[
			  colorscheme solarized
				verbose set termguicolors
				highlight @constant.bash guifg=#cb4b16
				highlight @variable.parameter.bash guifg=#dc322f
				highlight @punctuation.bracket.bash guifg=#dc322f
				highlight LineNr guibg=#101D22
			]]
		end
	}
}

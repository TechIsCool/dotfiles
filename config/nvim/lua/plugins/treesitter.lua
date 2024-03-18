return {
	-- nvim-treesitter: Neovim treesitter configurations for better syntax highlighting
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require 'nvim-treesitter.configs'.setup {
				-- Add all the languages you want to enable here
				ensure_installed = {
					"lua",
					"python",
					"terraform",
					"yaml",
					"json",
					"bash",
					"jq"
				},

				-- Enable Tree-sitter based highlighting
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
				},

				-- Additional Tree-sitter modules can be configured here
				indent = {
					enable = true,
				},
			}
		end
	},

	-- Additional Tree-sitter related plugins can be added here
	{ "nvim-treesitter/playground" }
}

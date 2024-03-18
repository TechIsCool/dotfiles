return {
	{
		"fatih/vim-go",
		config = function()
			vim.g.go_fmt_command = "goimports"
		end
	}
}

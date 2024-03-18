return {
	-- nvim-cmp: Autocompletion plugin
	{ "hrsh7th/nvim-cmp" },

	-- Completion sources
	{ "hrsh7th/cmp-nvim-lsp" }, -- LSP source for nvim-cmp
	{ "hrsh7th/cmp-buffer" },  -- Buffer completions
	{ "hrsh7th/cmp-path" },    -- Path completions
	{ "hrsh7th/cmp-cmdline" }, -- Command line completions
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			require("copilot").setup({})
		end,
	},
	{
		"zbirenbaum/copilot-cmp",
		config = function()
			require("copilot_cmp").setup()
		end
	},

	-- Snippet engine and snippets source
	{
		"L3MON4D3/LuaSnip",
		version = "v2.*",
		config = function()
			require('luasnip.loaders.from_lua').load({ paths = vim.fn.stdpath("config") .. "/lua/snippets/" })
			local ls = require('luasnip')

			local LS = {}

			function LS.expand_or_jump()
				if ls.expand_or_jumpable() then
					ls.expand_or_jump()
				end
			end

			function LS.jump_next()
				if ls.jumpable(1) then
					ls.jump(1)
				end
			end

			function LS.jump_prev()
				if ls.jumpable(-1) then
					ls.jump(-1)
				end
			end

			function LS.change_choice()
				if ls.choice_active() then
					ls.change_choice(1)
				end
			end

			local set = vim.keymap.set

			local mode = { 'i', 's' }

			set(mode, '<c-i>', LS.expand_or_jump)
			set(mode, '<c-n>', LS.jump_prev)
			set(mode, '<c-l>', LS.change_choice)
		end,
	},
	{ "saadparwaiz1/cmp_luasnip" },
	{
		"lukas-reineke/lsp-format.nvim",
		config = function()
			require("lsp-format").setup {}
		end,
	},

	-- Setup nvim-lspconfig and language servers
	{
		"neovim/nvim-lspconfig",
		config = function()
			require('lspconfig').tsserver.setup { on_attach = require("lsp-format").on_attach }
			require('lspconfig').terraform_lsp.setup { on_attach = require("lsp-format").on_attach }
			require('lspconfig').terraformls.setup { on_attach = require("lsp-format").on_attach }
			require('lspconfig').jqls.setup { on_attach = require("lsp-format").on_attach }
			require('lspconfig').gopls.setup { on_attach = require("lsp-format").on_attach }
			require('lspconfig').lua_ls.setup {
				on_attach = require("lsp-format").on_attach,
				settings = {
					Lua = {
						diagnostics = {
							globals = { 'vim' }
						}
					}
				}
			}
		end,
	},

	-- Setup nvim-cmp and preferences
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		config = function()
			local cmp = require 'cmp'
			cmp.setup({
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},

				snippet = {
					expand = function(args)
						require 'luasnip'.lsp_expand(args.body)
					end
				},
				mapping = cmp.mapping.preset.insert({
					['<C-b>']     = cmp.mapping.scroll_docs(-1),
					['<C-f>']     = cmp.mapping.scroll_docs(1),
					-- ['<C-Space>'] = cmp.mapping.complete(),
					['<C-e>']     = cmp.mapping.abort(),
					['<CR>']      = cmp.mapping.confirm({ select = false }), -- Don't automatically control the enter key unless explicitly selected
					['<Tab>']     = cmp.mapping.confirm({ select = true }),
					["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
				}),
				sources = cmp.config.sources({
					{ name = "otter",   group_index = 2 },
					-- Copilot Source
					{ name = "copilot", group_index = 2 },
					-- Other Sources
					{
						name = "nvim_lsp",
						group_index = 2,
						entry_filter = function(entry)
							-- Type Text returns are not the best results from an lsp
							return require("cmp.types").lsp.CompletionItemKind[entry:get_kind()] ~= "Text"
						end,
					},
					{ name = "path",    group_index = 2 },
					{ name = "luasnip", group_index = 2 },
					{ name = 'buffer',  group_index = 2 },
				})
			})

			-- Set up cmdline completion
			cmp.setup.cmdline(':', {
				mapping = cmp.mapping.preset.cmdline({
					['<Down>'] = { c = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }) },
					['<Up>']   = { c = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }) },

				}),
				sources = cmp.config.sources({
					{ name = 'path' },
					{ name = 'cmdline' },
				})
			})
		end
	}
}

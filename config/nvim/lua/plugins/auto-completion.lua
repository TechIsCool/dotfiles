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
			require("copilot").setup({
				filetypes = {
					secure = false, -- disable copilot for secure files
					yaml = true, -- default: false
					markdown = true, -- default: false
					help = false,
					gitcommit = false,
					gitrebase = false,
					hgcommit = false,
					svn = false,
					cvs = false,
					["."] = false,
				},
			})
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
			vim.keymap.set({ "i", "s" }, "<Tab>",
				function() if ls.expand_or_jumpable() then ls.expand_or_jump() else vim.api.nvim_input('<C-V><Tab>') end end,
				{ silent = true })
			vim.keymap.set({ "i", "s" }, "<S-Tab>", function() if ls.jumpable(-1) then ls.jump(-1) end end, { silent = true })
			vim.keymap.set({ "i", "s" }, "<C-u>", function() require("luasnip.extras.select_choice")() end, {})
		end,
	},
	{ "saadparwaiz1/cmp_luasnip" },
	{
		"lukas-reineke/lsp-format.nvim",
		config = function()
			require("lsp-format").setup {}
			vim.api.nvim_create_autocmd("BufWritePre", {
				callback = function()
					-- vim.lsp.buf.format()
					require("lsp-format").format({ sync = true })
				end
			})
		end,
	},

	-- Setup nvim-lspconfig and language servers
	{
		"neovim/nvim-lspconfig",
		config = function()
			local capabilities = require('cmp_nvim_lsp').default_capabilities()

			local servers = {
				{ 'iam-lsp' },
				{ 'emoji-lsp' },
				{ 'terraformls' },
				{ 'terraform_lsp' },
				{ 'jqls' },
				{ 'gopls' },
				{ 'bashls' },
				{
					'lua_ls',
					settings = {
						Lua = {
							diagnostics = {
								globals = { 'vim' }
							}
						}
					}
				},
			}

			local lsp = require('lspconfig')
			for _, server in pairs(servers) do
				local lsp_config = lsp[server[1]]
				if (vim.fn.executable(lsp_config.document_config.default_config.cmd[1]) == 1) then
					local opts = {
						on_attach = require("lsp-format").on_attach,
						capabilities = capabilities,
					}
					for k, v in pairs(server) do
						if type(k) ~= 'number' then
							opts[k] = v
						end
					end
					lsp_config.setup(opts)
				else
					print(
						"Language server '" .. server[1] .. "' not available",
						"Please install the lsp via via https://github.com/neovim/nvim-lspconfig/blob/HEAD/doc/server_configurations.md#" ..
						server[1]
					)
				end
			end
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

				formatting = {
					format = function(entry, item)
						local label = entry.source.name

						if label == 'nvim_lsp' then
							pcall(function()
								label = entry.source.source.client.name
							end)
						end

						label = string.format('[%s]', label)
						if item.menu ~= nil then
							item.menu = string.format('%s %s', label, item.menu)
						else
							item.menu = label
						end
						return item
					end,
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
						-- entry_filter = function(entry)
						-- 	-- Type Text returns are not the best results from an lsp
						-- 	return require("cmp.types").lsp.CompletionItemKind[entry:get_kind()] ~= "Text"
						-- end,
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

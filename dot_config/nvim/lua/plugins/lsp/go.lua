return {
	"ray-x/go.nvim",
	ft = { "go", "gomod", "gosum", "gotmpl" },
	event = { "CmdlineEnter" },
	build = ':lua require("go.install").update_all_sync()',
	dependencies = {
		"mfussenegger/nvim-dap",
		"leoluz/nvim-dap-go",
		"nvim-neotest/neotest",
		"nvim-neotest/neotest-go",
	},
	opts = {
		lsp_cfg = {
			settings = {
				gopls = {
					staticcheck = true,
					analyses = {
						unusedparams = true,
						nilness = true,
						shadow = true,
						unusedwrite = true,
					},
					hints = {
						assignVariableTypes = true,
						compositeLiteralFields = true,
						compositeLiteralTypes = true,
						constantValues = true,
						parameterNames = true,
						rangeVariableTypes = true,
					},
				},
			},
		},
		lsp_inlay_hints = { enable = true },
		trouble = false,
		luasnip = true,
		dap_debug = true,
	},
	config = function(_, opts)
		require("go").setup(opts)

		-- Format & organize imports on save (avoid double-formatting with conform.nvim if you add go there)
		local grp = vim.api.nvim_create_augroup("GoFormat", { clear = true })
		vim.api.nvim_create_autocmd("BufWritePre", {
			pattern = "*.go",
			group = grp,
			callback = function()
				require("go.format").goimports()
			end,
		})

		-- DAP integration (delve) if available
		local ok_dapgo, dap_go = pcall(require, "dap-go")
		if ok_dapgo then
			dap_go.setup()
		end

		-- Extend existing neotest configuration if loaded
		local ok_neotest, neotest = pcall(require, "neotest")
		if ok_neotest then
			-- Append adapter only if not already added
			local adapters = require("neotest.config").adapters or {}
			local has_go = false
			for _, a in ipairs(adapters) do
				if a.name == "neotest-go" then
					has_go = true
					break
				end
			end
			if not has_go then
				neotest.setup({
					adapters = (function()
						table.insert(adapters, require("neotest-go")({
							experimental = { test_table = true },
							args = { "-count=1" },
						}))
						return adapters
					end)(),
				})
			end
		end

		-- Test & debug keymaps now unified under <leader>t in neotest.lua
	end,
}

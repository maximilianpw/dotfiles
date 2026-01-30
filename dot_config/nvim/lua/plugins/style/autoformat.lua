return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>cF",
			function()
				require("conform").format({ async = true, lsp_format = "fallback" })
			end,
			mode = { "n", "v" },
			desc = "Format buffer (Conform)",
		},
	},
	opts = {
		notify_on_error = true,

		format_on_save = function(bufnr)
			-- Skip formatting for huge files using consolidated bigfile config
			local huge_threshold = vim.g.bigfile and vim.g.bigfile.huge or 200 * 1024
			local ok, stat = pcall((vim.uv or vim.loop).fs_stat, vim.api.nvim_buf_get_name(bufnr))
			if ok and stat and stat.size > huge_threshold then
				return nil
			end

			-- Also check buffer-local bigfile marker
			if vim.b[bufnr].bigfile_level == "huge" then
				return nil
			end

			local ft = vim.bo[bufnr].filetype

			-- Disable LSP formatting for C/C++
			local disable_filetypes = { c = true, cpp = true }
			local lsp_format_opt = disable_filetypes[ft] and "never" or "fallback"

			return {
				timeout_ms = 2000,
				lsp_format = lsp_format_opt,
			}
		end,

		formatters_by_ft = {
			lua = { "stylua" },
			javascript = { "prettierd", "prettier", stop_after_first = true },
			typescript = { "prettierd", "prettier", stop_after_first = true },
			javascriptreact = { "prettierd", "prettier", stop_after_first = true },
			typescriptreact = { "prettierd", "prettier", stop_after_first = true },
			vue = { "prettierd", "prettier", stop_after_first = true },
			css = { "prettierd", "prettier" },
			scss = { "prettierd", "prettier" },
			less = { "prettierd", "prettier" },
			html = { "prettierd", "prettier" },
			json = { "prettierd", "prettier" },
			jsonc = { "prettierd", "prettier" },
			yaml = { "prettierd", "prettier" },
			markdown = { "prettierd", "prettier" },
			graphql = { "prettierd", "prettier" },
			nix = { "alejandra" },
			elixir = { "lsp" },
			heex = { "lsp" },
			eex = { "lsp" },
			go = { "goimports", "gofmt" },
			c = { "clang_format" },
			cpp = { "clang_format" },
			cs = { "lsp" },
			csharp = { "lsp" },
			rust = { "rustfmt" },
			terraform = { "terraform_fmt" },
			python = { "ruff_format", "black", stop_after_first = true },
			sh = { "shfmt" },
			bash = { "shfmt" },
			zsh = { "shfmt" },
			toml = { "taplo" },
		},
	},
}

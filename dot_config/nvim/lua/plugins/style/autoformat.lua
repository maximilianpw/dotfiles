return { -- Autoformat
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	opts = {
		-- show errors when they happen, so you can catch mis-configs
		notify_on_error = true,

		-- format on save, with per-filetype lsp fallback control
		format_on_save = function(bufnr)
			-- Skip formatting for large files (performance optimization)
			local ok, stat = pcall((vim.uv or vim.loop).fs_stat, vim.api.nvim_buf_get_name(bufnr))
			if ok and stat and stat.size > vim.g.huge_file_size * 1024 then
				return nil -- Skip formatting for files larger than huge_file_size
			end

			local ft = vim.bo[bufnr].filetype

			-- disable LSP formatting for C/C++
			local disable_filetypes = { c = true, cpp = true }
			local lsp_format_opt = disable_filetypes[ft] and "never" or "fallback"

			return {
				timeout_ms = 2000,
				lsp_format = lsp_format_opt,
			}
		end,

		-- map filetypes to formatter names (runs in order)
		formatters_by_ft = {
			lua = { "stylua" },
			javascript = { "eslint_d", "prettierd", "prettier", stop_after_first = false },
			typescript = { "eslint_d", "prettierd", "prettier", stop_after_first = false },
			javascriptreact = { "eslint_d", "prettierd", "prettier", stop_after_first = false },
			typescriptreact = { "eslint_d", "prettierd", "prettier", stop_after_first = false },
			vue = { "eslint_d", "prettierd", "prettier", stop_after_first = false },
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

			-- Add C/C++ formatting via clang-format
			c = { "clang_format" },
			cpp = { "clang_format" },

			-- C# formatting via LSP (omnisharp)
			cs = { "lsp" },
			csharp = { "lsp" },

			-- Rust, Go, Terraform support
			rust = { "rustfmt" },
			terraform = { "terraform_fmt" },
		},
	},
}

return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			-- Enable treesitter highlighting for all buffers
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					local bufnr = args.buf

					-- Skip large files
					local name = vim.api.nvim_buf_get_name(bufnr)
					if name:match("/node_modules/") or name:match("/vendor/") then
						return
					end
					local ok, stat = pcall((vim.uv or vim.loop).fs_stat, name)
					if ok and stat and stat.size > (vim.g.max_file_size or 150) * 1024 then
						return
					end

					-- Try to start treesitter highlighting
					pcall(vim.treesitter.start, bufnr)
				end,
			})
		end,
	},
}

-- Consolidated big-file handling
-- Single source of truth for all file size thresholds

vim.g.bigfile = {
	large = 100 * 1024, -- 100KB: Disable expensive UI features
	max_ts = 150 * 1024, -- 150KB: Disable treesitter, completion buffer sources
	huge = 200 * 1024, -- 200KB: Disable formatting
}

-- Performance: Large file optimizations
vim.api.nvim_create_autocmd("BufReadPost", {
	desc = "Disable expensive features for large files",
	group = vim.api.nvim_create_augroup("bigfile-optimizations", { clear = true }),
	callback = function(args)
		local bufnr = args.buf
		local name = vim.api.nvim_buf_get_name(bufnr)

		-- Skip special buffers
		if name == "" or vim.bo[bufnr].buftype ~= "" then
			return
		end

		local ok, stat = pcall((vim.uv or vim.loop).fs_stat, name)
		if not ok or not stat then
			return
		end

		local size = stat.size

		-- Large file: disable expensive UI features
		if size > vim.g.bigfile.large then
			vim.opt_local.updatetime = 1000
			vim.opt_local.cursorline = false
			vim.opt_local.relativenumber = false
			vim.opt_local.scrolloff = 3
			vim.b[bufnr].bigfile = true
			vim.b[bufnr].bigfile_level = "large"
		end

		-- Max treesitter: disable syntax features
		if size > vim.g.bigfile.max_ts then
			vim.b[bufnr].bigfile_level = "max_ts"
			vim.opt_local.syntax = "off"
			vim.opt_local.foldmethod = "manual"
		end

		-- Huge file: will skip formatting (handled by conform)
		if size > vim.g.bigfile.huge then
			vim.b[bufnr].bigfile_level = "huge"
		end
	end,
})

-- Helper function for other modules to check file size
_G.is_bigfile = function(bufnr, level)
	bufnr = bufnr or 0
	level = level or "large"

	if vim.b[bufnr].bigfile then
		if level == "large" then
			return true
		end
		local buf_level = vim.b[bufnr].bigfile_level
		if level == "max_ts" and (buf_level == "max_ts" or buf_level == "huge") then
			return true
		end
		if level == "huge" and buf_level == "huge" then
			return true
		end
	end
	return false
end

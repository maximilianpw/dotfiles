-- Basic keymaps (non-plugin)

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Split navigation with CTRL+<hjkl>
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Copy file path with line number/range
vim.keymap.set({ "n", "v" }, "<leader>yd", function()
	local filepath = vim.fn.expand("%")
	local start_line = vim.fn.line(".")
	local end_line = vim.fn.line("v")

	local text
	if vim.fn.mode() == "v" or vim.fn.mode() == "V" or vim.fn.mode() == "\22" then
		start_line = vim.fn.line("v")
		end_line = vim.fn.line(".")
		if start_line > end_line then
			start_line, end_line = end_line, start_line
		end
		text = string.format("%s:%d-%d", filepath, start_line, end_line)
	else
		text = string.format("%s:%d", filepath, start_line)
	end

	vim.fn.setreg("+", text)
	vim.notify("Copied: " .. text, vim.log.levels.INFO)
end, { desc = "Copy file path with line number/range" })

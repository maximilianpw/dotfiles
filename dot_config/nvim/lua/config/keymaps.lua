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

-- Better buffer navigation
vim.keymap.set("n", "<leader>bf", "<cmd>bfirst<cr>", { desc = "First buffer" })
vim.keymap.set("n", "<leader>bL", "<cmd>blast<cr>", { desc = "Last buffer" })

-- Diagnostic navigation
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

-- Quickfix navigation
vim.keymap.set("n", "[q", "<cmd>cprevious<cr>", { desc = "Previous quickfix" })
vim.keymap.set("n", "]q", "<cmd>cnext<cr>", { desc = "Next quickfix" })
vim.keymap.set("n", "[Q", "<cmd>cfirst<cr>", { desc = "First quickfix" })
vim.keymap.set("n", "]Q", "<cmd>clast<cr>", { desc = "Last quickfix" })

-- Better visual indentation (stay in visual mode)
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Window resize with arrows
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

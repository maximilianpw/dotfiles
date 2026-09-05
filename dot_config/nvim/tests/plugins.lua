-- Run only in test.sh's disposable --ci XDG directories.
local root = assert(vim.env.NVIM_CONFIG_TEST_ROOT)
local lock = vim.json.decode(table.concat(vim.fn.readfile(assert(vim.env.NVIM_CONFIG_TEST_LOCK)), "\n"))
local plugins = require("lazy.core.config").plugins
for name, entry in pairs(lock) do
  local plugin = assert(plugins[name], "Missing locked plugin: " .. name)
  local revision = vim.fn.system({ "git", "-C", plugin.dir, "rev-parse", "HEAD" })
  assert(vim.v.shell_error == 0 and vim.trim(revision) == entry.commit, "Lock drift: " .. name)
end

require("lazy").load({ plugins = { "nvim-treesitter" } })
local fixture = vim.fs.joinpath(vim.fn.stdpath("state"), "textobjects.js")
vim.fn.writefile({ "function first() { return 1; }", "", "function second() { return 2; }" }, fixture)
vim.cmd.edit(vim.fn.fnameescape(fixture))
for _, key in ipairs({ "af", "if", "ac", "ic", "aa", "ia" }) do
  for _, mode in ipairs({ "x", "o" }) do
    assert(type(vim.fn.maparg(key, mode, false, true).callback) == "function", "Missing textobject: " .. key)
  end
end
for _, key in ipairs({ "]f", "]c", "]a", "]F", "]C", "]A", "[f", "[c", "[a", "[F", "[C", "[A" }) do
  assert(type(vim.fn.maparg(key, "n", false, true).callback) == "function", "Missing motion: " .. key)
end
vim.api.nvim_win_set_cursor(0, { 1, 0 })
vim.fn.maparg("]f", "n", false, true).callback()
assert(vim.api.nvim_win_get_cursor(0)[1] == 3, "]f did not move to the second function")
vim.fn.maparg("[f", "n", false, true).callback()
assert(vim.api.nvim_win_get_cursor(0)[1] == 1, "[f did not move to the first function")
vim.b.bigfile = true
vim.b.bigfile_level = "max_ts"
vim.fn.maparg("]f", "n", false, true).callback()
assert(vim.api.nvim_win_get_cursor(0)[1] == 1, "Textobject motion ignored the bigfile guard")
vim.b.bigfile = false

local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
vim.api.nvim_buf_set_lines(0, 0, -1, false, { "// " .. string.rep("x", vim.g.bigfile.huge) })
vim.api.nvim_exec_autocmds("TextChanged", { buffer = 0 })
assert(not vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()], "growing buffer retained highlighting")
assert(vim.bo.syntax == "off", "stopping Treesitter re-enabled legacy syntax in a large buffer")
vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
vim.api.nvim_exec_autocmds("TextChanged", { buffer = 0 })
assert(
  vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()],
  "shrinking buffer did not restart highlighting"
)
assert(vim.bo.indentexpr ~= "", "shrinking buffer did not restore treesitter indentation")

-- Inspect merged key configuration without starting the AI service.
local ai = dofile(plugins["supermaven-nvim"].dir .. "/lua/supermaven-nvim/config.lua")
ai.setup(dofile(root .. "/lua/plugins/ai/supermaven.lua").opts)
local blink = dofile(root .. "/lua/plugins/editor/blink.lua").opts
assert(blink.keymap[ai.keymaps.accept_suggestion] == nil, "AI acceptance conflicts with Blink")
assert(ai.keymaps.accept_suggestion ~= "<Tab>", "AI still owns snippet Tab")

-- Use the real persistence APIs through the configured keys, then emulate
-- late setup with an already-open buffer and no in-memory DAP breakpoints.
require("lazy").load({ plugins = { "nvim-dap" } })
vim.fn.maparg("<leader>db", "n", false, true).callback()
local bps = require("dap.breakpoints")
local buf = vim.api.nvim_get_current_buf()
assert(bps.get()[buf][1].line == 1, "Toggle mapping did not create a breakpoint")
bps.clear()
require("config.dap.breakpoints").setup()
assert(bps.get()[buf] and bps.get()[buf][1].line == 1, "Breakpoint was not persisted/restored on late setup")
local input = vim.fn.input
vim.fn.input = function()
  return "value > 1"
end
vim.api.nvim_win_set_cursor(0, { 3, 0 })
vim.fn.maparg("<leader>dB", "n", false, true).callback()
vim.fn.input = input
bps.clear()
require("config.dap.breakpoints").setup()
assert(bps.get()[buf][2].condition == "value > 1", "Conditional breakpoint was not persisted")

for _, case in ipairs({
  { "", {} },
  { "   ", {} },
  { [[one "two words" 'three words']], { "one", "two words", "three words" } },
}) do
  vim.fn.input = function()
    return case[1]
  end
  assert(vim.deep_equal(require("dap").configurations.rust[2].args(), case[2]), "Rust argument parsing failed")
end
vim.fn.input = input

require("lazy").load({ plugins = { "bufferline.nvim" } })
local bufferline = require("bufferline")
local spec = dofile(root .. "/lua/plugins/ui/bufferline.lua")
spec.config(nil, spec.opts)
spec.config(nil, spec.opts)
local autocmds = vim.api.nvim_get_autocmds({ group = "bufferline-session-refresh" })
assert(#autocmds == 2, "bufferline reload accumulated autocmds")
local refresh, count = bufferline.refresh, 0
bufferline.refresh = function()
  count = count + 1
end
autocmds[1].callback()
autocmds[1].callback()
vim.wait(200, function()
  return count > 0
end)
bufferline.refresh = refresh
assert(count == 1, "bufferline did not coalesce refresh events")
print("plugin contracts passed")

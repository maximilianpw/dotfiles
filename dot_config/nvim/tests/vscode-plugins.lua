-- Integration test with real locked plugins; test.sh runs this only in --ci.
local root = assert(vim.env.NVIM_CONFIG_TEST_ROOT)
vim.g.vscode = true
local actions = {}
package.preload.vscode = function()
  return {
    action = function(name)
      actions[#actions + 1] = name
    end,
  }
end
dofile(root .. "/init.lua")
local config = require("lazy.core.config")
local allowed = {
  ["lazy.nvim"] = true,
  ["mini.nvim"] = true,
  ["flash.nvim"] = true,
  ["nvim-treesitter"] = true,
  ["nvim-treesitter-textobjects"] = true,
  ["ts-comments.nvim"] = true,
}
for name in pairs(config.plugins) do
  assert(allowed[name], "terminal plugin remains active in VS Code: " .. name)
end
require("lazy").load({ plugins = vim.tbl_keys(allowed) })
vim.bo.filetype = "typescript"
for _, event in ipairs({ "InsertEnter", "LspAttach" }) do
  vim.api.nvim_exec_autocmds(event, { buffer = 0 })
end
vim.api.nvim_exec_autocmds("User", { pattern = "VeryLazy" })
for key, action in pairs({
  gd = "editor.action.revealDefinition",
  ["<leader>cf"] = "editor.action.formatDocument",
  ["<leader>ff"] = "workbench.action.quickOpen",
  ["<C-h>"] = "workbench.action.focusLeftGroup",
}) do
  vim.fn.maparg(key, "n", false, true).callback()
  assert(actions[#actions] == action, "plugin overwrote bridge: " .. key)
end
require("lazy.manage.lock").update()
local function read(path)
  return vim.json.decode(table.concat(vim.fn.readfile(path), "\n"))
end
assert(
  vim.deep_equal(read(config.options.lockfile), read(assert(vim.env.NVIM_CONFIG_TEST_LOCK))),
  "VS Code rewrote terminal plugin lock entries"
)
assert(#vim.lsp.get_clients() == 0, "VS Code started a terminal language server")
print("real VS Code plugin boundary and lock preservation passed")

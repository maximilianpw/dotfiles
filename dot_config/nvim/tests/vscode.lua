local root = assert(vim.env.NVIM_CONFIG_TEST_ROOT, "NVIM_CONFIG_TEST_ROOT is required")
vim.opt.runtimepath:prepend(root)
vim.g.vscode = true

local actions = {}
package.preload["vscode"] = function()
  return {
    action = function(name)
      actions[#actions + 1] = name
    end,
  }
end

local specs, options
package.preload["lazy"] = function()
  return {
    setup = function(plugin_specs, opts)
      specs = plugin_specs
      options = opts
    end,
  }
end

-- Keep this test isolated from lazy.nvim installation state. The manager itself
-- is mocked; only the import boundary and bridge mappings are under test.
local uv = vim.uv or vim.loop
local fs_stat = uv.fs_stat
uv.fs_stat = function(path, ...)
  if path:match("/lazy/lazy%.nvim$") then
    return { type = "directory" }
  end
  return fs_stat(path, ...)
end

dofile(vim.fs.joinpath(root, "init.lua"))

assert(#specs == 7, "full graph must remain present to preserve the shared lock")
for _, name in ipairs({
  "mini.nvim",
  "flash.nvim",
  "nvim-treesitter",
  "nvim-treesitter-textobjects",
  "ts-comments.nvim",
}) do
  assert(options.defaults.cond({ name = name }), "VS Code editing primitive excluded: " .. name)
end
for _, name in ipairs({
  "snacks.nvim",
  "fff.nvim",
  "nvim-lspconfig",
  "blink.cmp",
  "supermaven-nvim",
  "vim-tmux-navigator",
  "bufferline.nvim",
  "neo-tree.nvim",
  "conform.nvim",
  "nvim-dap",
}) do
  assert(not options.defaults.cond({ name = name }), "VS Code terminal owner enabled: " .. name)
end

local configured = {}
for _, module in ipairs({
  "mini.ai",
  "mini.move",
  "mini.surround",
  "mini.pairs",
  "mini.splitjoin",
  "mini.align",
  "mini.trailspace",
  "mini.sessions",
  "mini.hipatterns",
}) do
  package.preload[module] = function()
    return {
      setup = function()
        configured[module] = true
      end,
    }
  end
end
local mini = dofile(vim.fs.joinpath(root, "lua", "plugins", "editor", "mini.lua"))
mini.config()
for _, module in ipairs({ "mini.ai", "mini.move", "mini.surround", "mini.pairs", "mini.splitjoin", "mini.align" }) do
  assert(configured[module], "VS Code is missing editing primitive: " .. module)
end
for _, module in ipairs({ "mini.trailspace", "mini.sessions", "mini.hipatterns" }) do
  assert(not configured[module], "VS Code loaded terminal-only module: " .. module)
end
assert(#mini.keys == 0, "VS Code mini spec includes terminal/session keys")

local function assert_bridge(lhs, action)
  local mapping = vim.fn.maparg(lhs, "n", false, true)
  assert(type(mapping.callback) == "function", "Missing VS Code bridge mapping: " .. lhs)
  actions = {}
  mapping.callback()
  assert(actions[1] == action, lhs .. " is no longer owned by the VS Code bridge")
end

local function assert_bindings()
  assert_bridge("gd", "editor.action.revealDefinition")
  assert_bridge("<leader>ff", "workbench.action.quickOpen")
  assert_bridge("<C-h>", "workbench.action.focusLeftGroup")
  assert_bridge("<leader>e", "workbench.view.explorer")
end

assert_bindings()
for _, event in ipairs({ "FileType", "InsertEnter", "LspAttach", "VeryLazy" }) do
  if event == "VeryLazy" then
    vim.api.nvim_exec_autocmds("User", { pattern = event, modeline = false })
  else
    vim.api.nvim_exec_autocmds(event, { buffer = 0, modeline = false })
  end
  assert_bindings()
end

print("vscode boundary checks passed")

-- Standalone config contract; tests/plugins.lua also runs it with the real plugin.
local root = assert(vim.env.NVIM_CONFIG_TEST_ROOT)
local original_bufferline = package.loaded.bufferline
if not original_bufferline then
  package.loaded.bufferline = { setup = function() end }
end

local spec = dofile(root .. "/lua/plugins/ui/bufferline.lua")
spec.config(nil, spec.opts)
spec.config(nil, spec.opts)
local group = "bufferline-session-refresh"
assert(#vim.api.nvim_get_autocmds({ group = group }) == 2, "bufferline reload accumulated autocmds")

-- Observe the real redraw command rather than inventing a plugin refresh API.
local redrawtabline, count = vim.cmd.redrawtabline, 0
vim.cmd.redrawtabline = function(...)
  count = count + 1
  return redrawtabline(...)
end
local previous_error = vim.v.errmsg
vim.v.errmsg = ""
local ok, err = pcall(function()
  for burst = 1, 2 do
    vim.api.nvim_exec_autocmds("BufAdd", { group = group })
    vim.api.nvim_exec_autocmds("BufDelete", { group = group })
    vim.api.nvim_exec_autocmds("BufAdd", { group = group })
    assert(count == burst - 1, "bufferline redraw was not deferred")
    -- Wait past the timer deadline to catch duplicate redraws and async errors.
    vim.wait(250, function()
      return vim.v.errmsg ~= ""
    end)
    assert(vim.v.errmsg == "", vim.v.errmsg)
    assert(count == burst, "bufferline did not coalesce events or reset its pending flag")
  end
end)
vim.cmd.redrawtabline = redrawtabline
vim.v.errmsg = previous_error
package.loaded.bufferline = original_bufferline
assert(ok, err)
print("bufferline deferred redraw contracts passed")

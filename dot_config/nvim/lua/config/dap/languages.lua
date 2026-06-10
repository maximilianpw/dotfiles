local M = {}

function M.setup(dap)
  local ok_dap_go, dap_go = pcall(require, "dap-go")
  if ok_dap_go then
    dap_go.setup({
      dap_configurations = {
        {
          type = "go",
          name = "Attach remote",
          mode = "remote",
          request = "attach",
        },
      },
      delve = {
        path = "dlv",
        initialize_timeout_sec = 20,
        port = "${port}",
        args = {},
        build_flags = "",
      },
    })
  end

  dap.adapters.lldb = {
    type = "executable",
    command = "lldb-dap",
    name = "lldb",
  }

  dap.configurations.rust = {
    {
      name = "Launch file",
      type = "lldb",
      request = "launch",
      program = function()
        local cwd = vim.fn.getcwd()
        local cargo_toml = vim.fn.glob(cwd .. "/Cargo.toml")
        if cargo_toml ~= "" then
          local lines = vim.fn.readfile(cargo_toml)
          for _, line in ipairs(lines) do
            local name = line:match('^name%s*=%s*"([^"]+)"')
            if name then
              local binary = cwd .. "/target/debug/" .. name
              if vim.fn.filereadable(binary) == 1 then
                return vim.fn.input("Path to executable: ", binary, "file")
              end
            end
          end
        end
        return vim.fn.input("Path to executable: ", cwd .. "/target/debug/", "file")
      end,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
      args = {},
    },
    {
      name = "Launch file with args",
      type = "lldb",
      request = "launch",
      program = function()
        local cwd = vim.fn.getcwd()
        return vim.fn.input("Path to executable: ", cwd .. "/target/debug/", "file")
      end,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
      args = function()
        local args_string = vim.fn.input("Arguments: ")
        return vim.split(args_string, " +")
      end,
    },
    {
      name = "Attach to process",
      type = "lldb",
      request = "attach",
      pid = require("dap.utils").pick_process,
      args = {},
    },
  }
end

return M

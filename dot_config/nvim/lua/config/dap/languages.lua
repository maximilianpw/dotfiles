local M = {}

function M.setup(dap)
  -- C# debugging using netcoredbg.
  dap.adapters.coreclr = {
    type = "executable",
    command = "netcoredbg",
    args = { "--interpreter=vscode" },
  }

  dap.configurations.cs = {
    {
      type = "coreclr",
      name = "launch - netcoredbg",
      request = "launch",
      program = function()
        local cwd = vim.fn.getcwd()
        local dll_patterns = {
          cwd .. "/bin/Debug/**/*.dll",
          cwd .. "/bin/Release/**/*.dll",
          cwd .. "/**/bin/Debug/**/*.dll",
        }

        for _, pattern in ipairs(dll_patterns) do
          local dlls = vim.fn.glob(pattern, false, true)
          if #dlls > 0 then
            table.sort(dlls, function(a, b)
              return vim.fn.getftime(a) > vim.fn.getftime(b)
            end)
            return vim.fn.input("Path to dll: ", dlls[1], "file")
          end
        end

        return vim.fn.input("Path to dll: ", cwd .. "/bin/Debug/", "file")
      end,
    },
    {
      type = "coreclr",
      name = "attach - netcoredbg",
      request = "attach",
      processId = require("dap.utils").pick_process,
    },
  }

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

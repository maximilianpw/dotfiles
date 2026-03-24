-- Debug configuration with DAP
return {
  "mfussenegger/nvim-dap",
  dependencies = {
    -- Creates a beautiful debugger UI
    "rcarriga/nvim-dap-ui",

    -- Required dependency for nvim-dap-ui
    "nvim-neotest/nvim-nio",

    -- Virtual text support for variables
    "theHamsta/nvim-dap-virtual-text",

    -- Persistent breakpoints across sessions
    "Weissle/persistent-breakpoints.nvim",

    -- Add your own debuggers here
    "leoluz/nvim-dap-go",
  },
  keys = {
    -- Debug keymaps using <leader>d prefix
    {
      "<leader>dc",
      function()
        require("dap").continue()
      end,
      desc = "Debug: Start/Continue",
    },
    {
      "<leader>di",
      function()
        require("dap").step_into()
      end,
      desc = "Debug: Step Into",
    },
    {
      "<leader>do",
      function()
        require("dap").step_over()
      end,
      desc = "Debug: Step Over",
    },
    {
      "<leader>dO",
      function()
        require("dap").step_out()
      end,
      desc = "Debug: Step Out",
    },
    {
      "<leader>db",
      function()
        require("dap").toggle_breakpoint()
      end,
      desc = "Debug: Toggle Breakpoint",
    },
    {
      "<leader>dB",
      function()
        require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end,
      desc = "Debug: Set Conditional Breakpoint",
    },
    {
      "<leader>dr",
      function()
        require("dap").repl.open()
      end,
      desc = "Debug: Open REPL",
    },
    {
      "<leader>dl",
      function()
        require("dap").run_last()
      end,
      desc = "Debug: Run Last",
    },
    {
      "<leader>dt",
      function()
        require("dap").terminate()
      end,
      desc = "Debug: Terminate",
    },
    {
      "<leader>du",
      function()
        require("dapui").toggle()
      end,
      desc = "Debug: Toggle UI",
    },
    {
      "<leader>de",
      function()
        require("dapui").eval()
      end,
      desc = "Debug: Evaluate Expression",
      mode = { "n", "v" },
    },
    {
      "<leader>dR",
      function()
        require("dap").restart()
      end,
      desc = "Debug: Restart",
    },
    {
      "<leader>dC",
      function()
        require("dap").run_to_cursor()
      end,
      desc = "Debug: Run to Cursor",
    },
    {
      "<leader>dh",
      function()
        require("dap.ui.widgets").hover()
      end,
      desc = "Debug: Hover Variables",
      mode = { "n", "v" },
    },
    {
      "<leader>dj",
      function()
        require("dap").down()
      end,
      desc = "Debug: Down Stack Frame",
    },
    {
      "<leader>dk",
      function()
        require("dap").up()
      end,
      desc = "Debug: Up Stack Frame",
    },
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    local function first_executable(paths)
      for _, path in ipairs(paths) do
        if path and path ~= "" and vim.fn.executable(path) == 1 then
          return path
        end
      end
    end

    local function file_exists(path)
      return path and path ~= "" and vim.fn.filereadable(path) == 1
    end

    local function resolve_js_debug_command()
      local data_dir = vim.fn.stdpath("data")
      local mason_dir = data_dir .. "/mason"
      local node_path = vim.fn.exepath("node")
      local candidates = {
        vim.fn.exepath("js-debug"),
        vim.fn.exepath("js-debug-adapter"),
        mason_dir .. "/bin/js-debug-adapter",
        mason_dir .. "/packages/js-debug-adapter/js-debug-adapter",
      }

      local executable = first_executable(candidates)
      if executable then
        return executable
      end

      local vscode_js_debug_root = mason_dir .. "/packages/js-debug-adapter/node_modules/js-debug"
      local bundled_server = vscode_js_debug_root .. "/src/dapDebugServer.js"
      if file_exists(bundled_server) and node_path ~= "" then
        return { node_path, bundled_server }
      end
    end

    local js_debug_command = resolve_js_debug_command()

    local function js_debug_args()
      return { "${port}", "127.0.0.1" }
    end

    local function js_debug_executable()
      if type(js_debug_command) == "table" then
        return {
          command = js_debug_command[1],
          args = vim.list_extend({ js_debug_command[2] }, js_debug_args()),
        }
      end

      return {
        command = js_debug_command,
        args = js_debug_args(),
      }
    end

    local function prompt_debug_port(default_port)
      local value = vim.fn.input("Debug port: ", tostring(default_port or 9229))
      return tonumber(value) or default_port or 9229
    end

    local function prompt_text(label, default_value)
      local value = vim.fn.input(label, default_value or "")
      return value ~= "" and value or default_value
    end

    local function prompt_remote_root(default_path)
      local value = prompt_text("Remote root: ", default_path or "/app")
      return value ~= "" and value or default_path or "/app"
    end

    local function detect_remote_root()
      local cwd = vim.fn.getcwd()

      for _, dockerfile in ipairs({ "Dockerfile", "docker/Dockerfile" }) do
        local path = cwd .. "/" .. dockerfile
        if vim.fn.filereadable(path) == 1 then
          for _, line in ipairs(vim.fn.readfile(path)) do
            local workdir = line:match("^WORKDIR%s+(.+)$")
            if workdir and workdir ~= "" then
              return workdir
            end
          end
        end
      end
    end

    local function resolve_remote_root(default_path)
      return detect_remote_root() or prompt_remote_root(default_path)
    end

    local function config_with(base, extra)
      return vim.tbl_deep_extend("force", vim.deepcopy(base), extra or {})
    end

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup({
      icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
      controls = {
        enabled = true,
        element = "repl",
        icons = {
          pause = "⏸",
          play = "▶",
          step_into = "⏎",
          step_over = "⏭",
          step_out = "⏮",
          step_back = "b",
          run_last = "▶▶",
          terminate = "⏹",
          disconnect = "⏏",
        },
      },
      layouts = {
        {
          elements = {
            -- Elements can be strings or table with id and size keys.
            { id = "scopes", size = 0.25 },
            "breakpoints",
            "stacks",
            "watches",
          },
          size = 40, -- 40 columns
          position = "left",
        },
        {
          elements = {
            "repl",
            "console",
          },
          size = 0.25, -- 25% of total lines
          position = "bottom",
        },
      },
      floating = {
        max_height = nil, -- These can be integers or a float between 0 and 1.
        max_width = nil, -- Floats will be treated as percentage of your screen.
        border = "single", -- Border style. Can be 'single', 'double' or 'rounded'
        mappings = {
          close = { "q", "<Esc>" },
        },
      },
      -- Mappings for all elements
      mappings = {
        -- edit value, expand tree, open element, remove, repl, toggle
        edit = "e",
        expand = { "<CR>", "o" },
        open = "o",
        remove = "d",
        repl = "r",
        toggle = "t",
      },

      -- Per-element overrides (empty by default)
      element_mappings = {},

      -- Show full lines when expanded, use buffer windows
      expand_lines = false,
      force_buffers = false,

      -- How to render variable values
      render = {
        indent = 1,
        max_value_lines = 100,
      },
    })

    -- VSCode-like breakpoint colors and highlights
    vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#e51400" })
    vim.api.nvim_set_hl(0, "DapBreakpointCondition", { fg = "#f89c1c" })
    vim.api.nvim_set_hl(0, "DapBreakpointRejected", { fg = "#848484" })
    vim.api.nvim_set_hl(0, "DapLogPoint", { fg = "#61afef" })
    vim.api.nvim_set_hl(0, "DapStopped", { fg = "#ffcc00" })
    vim.api.nvim_set_hl(0, "DapStoppedLine", { bg = "#555530" })

    -- Use plain glyphs for DAP signs so breakpoints stay visible even when Nerd Font
    -- detection is wrong or the terminal font lacks specific icons.
    local breakpoint_icons = {
      Breakpoint = "●",
      BreakpointCondition = "◉",
      BreakpointRejected = "○",
      LogPoint = "◆",
      Stopped = "▶",
    }

    -- Configure DAP signs with VSCode-like styling
    vim.fn.sign_define("DapBreakpoint", {
      text = breakpoint_icons.Breakpoint,
      texthl = "DapBreakpoint",
      linehl = "",
      numhl = "DapBreakpoint",
    })
    vim.fn.sign_define("DapBreakpointCondition", {
      text = breakpoint_icons.BreakpointCondition,
      texthl = "DapBreakpointCondition",
      linehl = "",
      numhl = "DapBreakpointCondition",
    })
    vim.fn.sign_define("DapBreakpointRejected", {
      text = breakpoint_icons.BreakpointRejected,
      texthl = "DapBreakpointRejected",
      linehl = "",
      numhl = "DapBreakpointRejected",
    })
    vim.fn.sign_define("DapLogPoint", {
      text = breakpoint_icons.LogPoint,
      texthl = "DapLogPoint",
      linehl = "",
      numhl = "DapLogPoint",
    })
    vim.fn.sign_define("DapStopped", {
      text = breakpoint_icons.Stopped,
      texthl = "DapStopped",
      linehl = "DapStoppedLine",
      numhl = "DapStopped",
    })

    -- Configure DAP virtual text
    local ok_virtual_text, nvim_dap_virtual_text = pcall(require, "nvim-dap-virtual-text")
    if ok_virtual_text then
      nvim_dap_virtual_text.setup({
        enabled = true, -- turn the plugin on
        enable_commands = true, -- create DapVirtualTextEnable/Disable/Toggle/ForceRefresh commands
        highlight_changed_variables = true, -- highlight when values change
        highlight_new_as_changed = false, -- new variables aren’t “changed”
        show_stop_reason = true, -- show reason on exception
        commented = false, -- prefix with commentstring
        only_first_definition = true, -- don’t repeat virtual text for later references
        all_references = false, -- show for all references, not just definitions
        clear_on_continue = false, -- clear text when you hit continue
        filter_references_pattern = "<module", -- filter what refs get shown
        virt_text_pos = vim.fn.has("nvim-0.10") == 1 and "inline" or "eol",
        all_frames = false, -- show frames for all threads
        virt_lines = false, -- use virtual lines instead of text
        virt_lines_above = false, -- put virtual lines above the line, not below
        virt_text_win_col = nil, -- fixed column for virtual text
        text_prefix = "", -- prefix every variable with this
        separator = " | ", -- separator between name and value
        error_prefix = "✖ ", -- prefix on error messages
        info_prefix = "ℹ ", -- prefix for info messages
        display_callback = function(variable, _buf, _stackframe, _node, options)
          if options.virt_text_pos == "inline" then
            return " = " .. variable.value
          else
            return variable.name .. " = " .. variable.value
          end
        end,
      })
    end

    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
    end

    -- Configure C# debugging using netcoredbg
    -- Note: On NixOS, install netcoredbg via system packages or nix-shell
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
          -- Try to find the most recent DLL in bin/Debug or bin/Release
          local cwd = vim.fn.getcwd()
          local dll_patterns = {
            cwd .. "/bin/Debug/**/*.dll",
            cwd .. "/bin/Release/**/*.dll",
            cwd .. "/**/bin/Debug/**/*.dll",
          }

          for _, pattern in ipairs(dll_patterns) do
            local dlls = vim.fn.glob(pattern, false, true)
            if #dlls > 0 then
              -- Return the most recently modified DLL
              table.sort(dlls, function(a, b)
                return vim.fn.getftime(a) > vim.fn.getftime(b)
              end)
              return vim.fn.input("Path to dll: ", dlls[1], "file")
            end
          end

          -- Fallback to manual input if no DLL found
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

    -- Configure TypeScript/JavaScript debugging. Prefer an explicit adapter path so the
    -- debug server works with Mason, Nix, and standalone installs.
    if js_debug_command then
      for _, adapter in ipairs({ "pwa-node", "pwa-chrome" }) do
        dap.adapters[adapter] = {
          type = "server",
          host = "127.0.0.1",
          port = "${port}",
          executable = js_debug_executable(),
        }
      end
    else
      vim.schedule(function()
        vim.notify_once(
          "JavaScript debug adapter not found. Install `js-debug-adapter` (Mason) or put `js-debug` on PATH.",
          vim.log.levels.WARN
        )
      end)
    end

    local js_languages = { "typescript", "javascript", "typescriptreact", "javascriptreact" }
    local workspace_root = "${workspaceFolder}"

    local node_launch_defaults = {
      type = "pwa-node",
      request = "launch",
      cwd = workspace_root,
      sourceMaps = true,
      resolveSourceMapLocations = {
        "${workspaceFolder}/**",
        "!**/node_modules/**",
      },
      outFiles = {
        "${workspaceFolder}/**/*.js",
        "!**/node_modules/**",
      },
      skipFiles = { "<node_internals>/**" },
    }

    local node_attach_defaults = {
      type = "pwa-node",
      request = "attach",
      cwd = workspace_root,
      restart = true,
      localRoot = workspace_root,
      remoteRoot = workspace_root,
      smartStep = true,
      sourceMaps = true,
      outFiles = {
        "${workspaceFolder}/dist/**/*.js",
        "${workspaceFolder}/build/**/*.js",
        "${workspaceFolder}/**/*.js",
        "!**/node_modules/**",
      },
      resolveSourceMapLocations = {
        "${workspaceFolder}/**",
        "!**/node_modules/**",
      },
      skipFiles = { "<node_internals>/**", "**/node_modules/**" },
    }

    local chrome_defaults = {
      type = "pwa-chrome",
      webRoot = workspace_root,
      sourceMaps = true,
      breakOnLoad = true,
      skipFiles = { "<node_internals>/**/*.js" },
    }

    local nest_attach_defaults = config_with(node_attach_defaults, {
      attachExistingChildren = true,
      autoAttachChildProcesses = true,
      pauseForSourceMap = true,
      remoteRoot = function()
        return resolve_remote_root("/app")
      end,
      outFiles = {
        "${workspaceFolder}/dist/**/*.js",
        "${workspaceFolder}/**/*.js",
        "!**/node_modules/**",
      },
      resolveSourceMapLocations = {
        "${workspaceFolder}/dist/**/*.map",
        "${workspaceFolder}/**/*.map",
        "!**/node_modules/**",
      },
      sourceMapPathOverrides = {
        ["webpack:///./~/*"] = "${workspaceFolder}/node_modules/*",
        ["webpack:///./*"] = "${workspaceFolder}/*",
        ["webpack://./*"] = "${workspaceFolder}/*",
        ["webpack:///apps/*"] = "${workspaceFolder}/apps/*",
        ["webpack:///libs/*"] = "${workspaceFolder}/libs/*",
        ["webpack://?:*/apps/*"] = "${workspaceFolder}/apps/*",
        ["webpack://?:*/libs/*"] = "${workspaceFolder}/libs/*",
        ["webpack://?:*/*"] = "${workspaceFolder}/*",
      },
    })

    local function docker_nest_attach(name, port)
      return config_with(nest_attach_defaults, {
        name = name,
        port = port,
        remoteRoot = "/usr/src/app",
      })
    end

    local js_configurations = {
      docker_nest_attach("Node: Attach vev-ocpi (Docker)", 9589),
      docker_nest_attach("Node: Attach vev-server (Docker)", 9681),
      config_with(node_attach_defaults, {
        name = "Node: Attach by port",
        port = function()
          return prompt_debug_port(9229)
        end,
      }),
      config_with(nest_attach_defaults, {
        name = "Node: Attach NestJS",
        port = function()
          return prompt_debug_port(9229)
        end,
      }),
      config_with(chrome_defaults, {
        request = "launch",
        name = "Chrome: Launch URL",
        url = function()
          return prompt_text("URL: ", "http://localhost:3000")
        end,
      }),
      config_with(chrome_defaults, {
        request = "attach",
        name = "Chrome: Attach (9222)",
        port = 9222,
      }),
      config_with(node_launch_defaults, {
        name = "Node: Launch TSX current file",
        program = "${file}",
        runtimeExecutable = "npx",
        runtimeArgs = { "tsx" },
      }),
      {
        type = "pwa-node",
        request = "launch",
        name = "Node: Launch Jest",
        runtimeExecutable = "node",
        runtimeArgs = {
          "./node_modules/jest/bin/jest.js",
          "--runInBand",
        },
        rootPath = workspace_root,
        cwd = workspace_root,
        console = "integratedTerminal",
        internalConsoleOptions = "neverOpen",
        skipFiles = { "<node_internals>/**", "node_modules/**" },
      },
    }

    for _, language in ipairs(js_languages) do
      dap.configurations[language] = vim.deepcopy(js_configurations)
    end

    -- Configure Go debugging
    -- Note: On NixOS, install delve via system packages or nix-shell
    local ok_dap_go, dap_go = pcall(require, "dap-go")
    if ok_dap_go then
      dap_go.setup({
        -- Additional dap configurations can be added here
        dap_configurations = {
          {
            type = "go",
            name = "Attach remote",
            mode = "remote",
            request = "attach",
          },
        },
        -- delve configurations
        delve = {
          -- Path to delve (use system-installed)
          path = "dlv",
          -- Default port for delve
          initialize_timeout_sec = 20,
          port = "${port}",
          args = {},
          build_flags = "",
        },
      })
    end

    -- Configure Rust debugging using lldb-dap (comes with LLVM)
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
          -- Try to find the executable in target/debug
          local cwd = vim.fn.getcwd()
          local cargo_toml = vim.fn.glob(cwd .. "/Cargo.toml")
          if cargo_toml ~= "" then
            -- Get the package name from Cargo.toml
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

    -- Setup persistent breakpoints
    local ok_persistent_breakpoints, persistent_breakpoints = pcall(require, "persistent-breakpoints")
    if ok_persistent_breakpoints then
      persistent_breakpoints.setup({
        -- Save breakpoints to project directory
        save_dir = vim.fn.stdpath("data") .. "/breakpoints",
        -- Load breakpoints when opening buffer
        load_breakpoints_event = { "BufReadPost" },
        -- Automatically save breakpoints
        perf_record = false,
      })
    end
  end,
}

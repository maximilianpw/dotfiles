return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  init = function()
    vim.g.lualine_laststatus = vim.o.laststatus
    if vim.fn.argc(-1) > 0 then
      -- set an empty statusline till lualine loads
      vim.o.statusline = " "
    else
      -- hide the statusline on the starter page
      vim.o.laststatus = 0
    end
  end,
  opts = function()
    -- PERF: we don't need this lualine require madness 🤷
    local lualine_require = require("lualine_require")
    lualine_require.require = require

    -- Define icons without LazyVim dependency
    local icons = {
      diagnostics = {
        Error = "󰅚 ",
        Warn = "󰀪 ",
        Info = "󰋽 ",
        Hint = "󰌶 ",
      },
      git = {
        added = " ",
        modified = " ",
        removed = " ",
      },
    }

    vim.o.laststatus = vim.g.lualine_laststatus

    local opts = {
      options = {
        theme = "auto",
        globalstatus = vim.o.laststatus == 3,
        disabled_filetypes = { statusline = { "dashboard", "alpha", "ministarter", "neo-tree" } },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch" },

        lualine_c = {
          -- Root directory display
          {
            function()
              local root = vim.fn.getcwd()
              return vim.fn.fnamemodify(root, ":~")
            end,
            icon = "󰉋 ",
            color = { gui = "bold" },
          },
          {
            "diagnostics",
            symbols = {
              error = icons.diagnostics.Error,
              warn = icons.diagnostics.Warn,
              info = icons.diagnostics.Info,
              hint = icons.diagnostics.Hint,
            },
          },
          { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
          {
            "filename",
            path = 1, -- 0 = just filename, 1 = relative path, 2 = absolute path
            shorting_target = 40,
            symbols = {
              modified = " ●",
              readonly = " ",
              unnamed = "[No Name]",
            },
          },
        },
        lualine_x = {
          -- Snacks profiler status
          {
            function()
              if package.loaded["snacks"] then
                return require("snacks").profiler.status()
              end
              return ""
            end,
            cond = function()
              return package.loaded["snacks"] and require("snacks").profiler.status() ~= ""
            end,
          },
          -- Noice command status
          {
            function() 
              return require("noice").api.status.command.get() 
            end,
            cond = function() 
              return package.loaded["noice"] and require("noice").api.status.command.has() 
            end,
            color = function() 
              if package.loaded["snacks"] then
                return { fg = require("snacks").util.color("Statement") }
              end
              return { fg = "#7aa2f7" }
            end,
          },
          -- Noice mode status
          {
            function() 
              return require("noice").api.status.mode.get() 
            end,
            cond = function() 
              return package.loaded["noice"] and require("noice").api.status.mode.has() 
            end,
            color = function() 
              if package.loaded["snacks"] then
                return { fg = require("snacks").util.color("Constant") }
              end
              return { fg = "#bb9af7" }
            end,
          },
          -- DAP status with Snacks color
          {
            function()
              if not package.loaded["dap"] then
                return ""
              end
              local status = require("dap").status()
              return status ~= "" and "  " .. status or ""
            end,
            cond = function()
              return package.loaded["dap"] and require("dap").status() ~= ""
            end,
            color = function() 
              if package.loaded["snacks"] then
                return { fg = require("snacks").util.color("Debug") }
              end
              return { fg = "#ff9e64" }
            end,
          },
          -- Lazy updates with Snacks color
          {
            function()
              if not package.loaded["lazy"] then
                return ""
              end
              local lazy_status = require("lazy.status")
              return lazy_status.has_updates() and lazy_status.updates() or ""
            end,
            cond = function()
              return package.loaded["lazy"] and require("lazy.status").has_updates()
            end,
            color = function() 
              if package.loaded["snacks"] then
                return { fg = require("snacks").util.color("Special") }
              end
              return { fg = "#ff9e64" }
            end,
          },
          {
            "diff",
            symbols = {
              added = icons.git.added,
              modified = icons.git.modified,
              removed = icons.git.removed,
            },
            source = function()
              local gitsigns = vim.b.gitsigns_status_dict
              if gitsigns then
                return {
                  added = gitsigns.added,
                  modified = gitsigns.changed,
                  removed = gitsigns.removed,
                }
              end
            end,
          },
        },
        lualine_y = {
          { "progress", separator = " ", padding = { left = 1, right = 0 } },
          { "location", padding = { left = 0, right = 1 } },
        },
        lualine_z = {
          function()
            return " " .. os.date("%R")
          end,
        },
      },
      extensions = { "neo-tree", "lazy", "fzf" },
    }

    -- Add trouble symbols if available
    if package.loaded["trouble"] then
      local trouble = require("trouble")
      local symbols = trouble.statusline({
        mode = "symbols",
        groups = {},
        title = false,
        filter = { range = true },
        format = "{kind_icon}{symbol.name:Normal}",
        hl_group = "lualine_c_normal",
      })
      table.insert(opts.sections.lualine_c, {
        symbols and symbols.get,
        cond = function()
          return vim.b.trouble_lualine ~= false and symbols.has()
        end,
      })
    end

    return opts
  end,
}

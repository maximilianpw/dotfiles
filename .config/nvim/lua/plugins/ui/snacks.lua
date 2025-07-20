return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    -- Core features
    indent = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = false }, -- we set this in options.lua
    words = { enabled = true },

    -- Dashboard configuration
    dashboard = {
      enabled = true,
      preset = {
        width = 80,
        sections = {
          {
            section = 'header',
            width = 40,
            padding = 1,
          },
          {
            section = 'keys',
            height = 5,
            padding = 1,
          },
          { icon = ' ', title = 'Recent Files', section = 'recent_files', indent = 2, padding = 1 },
          { icon = ' ', title = 'Projects', section = 'projects', indent = 2, padding = 1 },
        },
        header = [[
         _          __________                              _,            
     _.-(_)._     ."          ".      .--""--.          _.-{__}-._        
   .'________'.   | .--------. |    .'        '.      .:-'`____`'-:.      
  [____________] /` |________| `\  /   .'``'.   \    /_.-"`_  _`"-._\     
  /  / .\/. \  \|  / / .\/. \ \  ||  .'/.\/.\'.  |  /`   / .\/. \   `\    
  |  \__/\__/  |\_/  \__/\__/  \_/|  : |_/\_| ;  |  |    \__/\__/    |    
  \            /  \            /   \ '.\    /.' / .-\                /-.  
  /'._  --  _.'\  /'._  --  _.'\   /'. `'--'` .'\/   '._-.__--__.-_.'   \ 
 /_   `""""`   _\/_   `""""`   _\ /_  `-./\.-'  _\'.    `""""""""`    .'`\
(__/    '|    \ _)_|           |_)_/            \__)|        '       |   |
  |_____'|_____|   \__________/   |              | `_________'________`;-'
   '----------'    '----------'   '--------------'`--------------------`  
]],
        -- Dashboard keys without LazyVim dependencies
        keys = {
          {
            icon = ' ',
            key = 'f',
            desc = 'Find File',
            action = function()
              if vim.fn.exists ':Telescope' == 2 then
                vim.cmd 'Telescope find_files'
              elseif vim.fn.exists ':FzfLua' == 2 then
                vim.cmd 'FzfLua files'
              else
                vim.cmd 'edit .'
              end
            end,
          },
          { icon = ' ', key = 'n', desc = 'New File', action = ':ene | startinsert' },
          {
            icon = ' ',
            key = 'g',
            desc = 'Find Text',
            action = function()
              if vim.fn.exists ':Telescope' == 2 then
                vim.cmd 'Telescope live_grep'
              elseif vim.fn.exists ':FzfLua' == 2 then
                vim.cmd 'FzfLua live_grep'
              else
                vim.cmd 'grep '
              end
            end,
          },
          {
            icon = ' ',
            key = 'r',
            desc = 'Recent Files',
            action = function()
              if vim.fn.exists ':Telescope' == 2 then
                vim.cmd 'Telescope oldfiles'
              elseif vim.fn.exists ':FzfLua' == 2 then
                vim.cmd 'FzfLua oldfiles'
              else
                vim.cmd 'browse oldfiles'
              end
            end,
          },
          {
            icon = ' ',
            key = 'c',
            desc = 'Config',
            action = function()
              local config_dir = vim.fn.stdpath 'config'
              if vim.fn.exists ':Telescope' == 2 then
                vim.cmd('Telescope find_files cwd=' .. config_dir)
              elseif vim.fn.exists ':FzfLua' == 2 then
                vim.cmd('FzfLua files cwd=' .. config_dir)
              else
                vim.cmd('edit ' .. config_dir)
              end
            end,
          },
          {
            icon = '󰒲 ',
            key = 'l',
            desc = 'Lazy',
            action = function()
              if vim.fn.exists ':Lazy' == 2 then
                vim.cmd 'Lazy'
              else
                print 'Lazy.nvim not available'
              end
            end,
          },
          { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
        },
      },
    },
  },
  -- Key mappings
  keys = {
    {
      '<leader>n',
      function()
        local snacks = require 'snacks'
        if snacks.picker and snacks.picker.enabled then
          snacks.picker.notifications()
        else
          snacks.notifier.show_history()
        end
      end,
      desc = 'Notification History',
    },
    {
      '<leader>un',
      function()
        require('snacks').notifier.hide()
      end,
      desc = 'Dismiss All Notifications',
    },
    {
      '<leader>gg',
      function()
        require('snacks').lazygit()
      end,
      desc = 'Lazygit',
    },
    {
      '<leader>gb',
      function()
        require('snacks').git.blame_line()
      end,
      desc = 'Git Blame Line',
    },
    {
      '<leader>gB',
      function()
        require('snacks').gitbrowse()
      end,
      desc = 'Git Browse',
    },
    {
      '<leader>gf',
      function()
        require('snacks').lazygit.log_file()
      end,
      desc = 'Lazygit Current File History',
    },
    {
      '<leader>gl',
      function()
        require('snacks').lazygit.log()
      end,
      desc = 'Lazygit Log (cwd)',
    },
    {
      '<c-/>',
      function()
        require('snacks').terminal()
      end,
      desc = 'Toggle Terminal',
    },
    {
      '<c-_>',
      function()
        require('snacks').terminal()
      end,
      desc = 'which_key_ignore',
    },
  },
  init = function()
    vim.api.nvim_create_autocmd('User', {
      pattern = 'VeryLazy',
      callback = function()
        local dashboard_blue = '#89B4FA'
        vim.api.nvim_set_hl(0, 'SnacksDashboardHeader', {
          fg = dashboard_blue,
          bold = true,
        })
        -- Setup some globals for easier access
        _G.dd = function(...)
          require('snacks').debug.inspect(...)
        end
        _G.bt = function()
          require('snacks').debug.backtrace()
        end
        vim.print = _G.dd -- Override print to use snacks for `:=` command
      end,
    })
  end,
}

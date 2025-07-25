-- Telescope fuzzy finder configuration
return {
  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',

        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = 'make',

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },

      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      -- [[ Configure Telescope ]]
      require('telescope').setup {
        defaults = {
          prompt_prefix = '❯ ',
          selection_caret = '➜ ',
          path_display = { 'smart' },
          file_ignore_patterns = { 'node_modules/', '%.git/' },
          layout_strategy = 'horizontal',
          layout_config = {
            horizontal = { width = 0.9, preview_width = 0.6 },
            vertical = { height = 0.9, preview_height = 0.5 },
          },
          mappings = {
            i = {
              ['<C-j>'] = 'move_selection_next',
              ['<C-k>'] = 'move_selection_previous',
            },
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = 'smart_case',
          },
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      -- Enable Telescope extensions if they are installed
      for _, ext in ipairs { 'fzf', 'ui-select' } do
        if not pcall(require('telescope').load_extension, ext) then
          vim.notify('Couldn’t load Telescope extension: ' .. ext, vim.log.levels.WARN)
        end
      end

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Find Help' })
      vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = 'Search Keymaps' })
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find Files' })
      vim.keymap.set('n', '<leader>fs', builtin.builtin, { desc = 'Search Select Telescope' })
      vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = 'Find current Word' })
      vim.keymap.set('n', '<leader>fl', builtin.live_grep, { desc = 'Find by Grep' })
      vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { desc = 'Search Diagnostics' })
      vim.keymap.set('n', '<leader>fr', builtin.resume, { desc = 'Resume Search' })
      vim.keymap.set('n', '<leader>f.', builtin.oldfiles, { desc = 'Find Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader>fgf', builtin.git_files, { desc = 'Find Git Files' })
      vim.keymap.set('n', '<leader>fgb', builtin.git_branches, { desc = 'Checkout Git Branch' })
      vim.keymap.set('n', '<leader>fgc', builtin.git_commits, { desc = 'Checkout Commit' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = 'Find existing buffers' })

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      vim.keymap.set('n', '<leader>f/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = 'Grep in Open Files' })

      vim.keymap.set('n', '<leader>fc', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = 'Find Config Files' })
    end,
  },
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    vscode = true,
    ---@type Flash.Config
    opts = {},
  -- stylua: ignore
  keys = {
    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    { "S", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  },
  },
}

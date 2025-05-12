-- Telescope fuzzy finder configuration
return { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
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
            -- You can put your default mappings / updates / etc. in here
            --  All the info you're looking for is in `:help telescope.setup()`
            --
            -- defaults = {
            --   mappings = {
            --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
            --   },
            -- },
            -- pickers = {}
            extensions = {
                ['ui-select'] = {
                    require('telescope.themes').get_dropdown(),
                },
            },
        }

        -- Enable Telescope extensions if they are installed
        local success, err = pcall(require('telescope').load_extension, 'fzf')
        if not success then
            vim.notify('Failed to load Telescope extension: fzf', vim.log.levels.ERROR)
        end

        success, err = pcall(require('telescope').load_extension, 'ui-select')
        if not success then
            vim.notify('Failed to load Telescope extension: ui-select', vim.log.levels.ERROR)
        end

        -- See `:help telescope.builtin`
        local builtin = require 'telescope.builtin'
        vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Find Help' })
        vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = 'Search Keymaps' })
        vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find Files' })
        vim.keymap.set('n', '<leader>fs', builtin.builtin, { desc = 'Search Select Telescope' })
        vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = 'Find current Word' })
        vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Find by Grep' })
        vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { desc = 'Search Diagnostics' })
        vim.keymap.set('n', '<leader>fr', builtin.resume, { desc = 'Resume Search' })
        vim.keymap.set('n', '<leader>f.', builtin.oldfiles, { desc = 'Find Recent Files ("." for repeat)' })
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
}
return { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
        {
            '<leader>s',
            function()
                require('conform').format { async = true, lsp_format = 'fallback' }
            end,
            mode = { 'n', 'v' },
            desc = 'Format buffer',
        },
    },
    opts = {
        notify_on_error = false,
        format_on_save = function(bufnr)
            -- Disable "format_on_save lsp_fallback" for languages that don't
            -- have a well standardized coding style. You can add additional
            -- languages here or re-enable it for the disabled ones.
            local disable_filetypes = { c = true, cpp = true }
            local lsp_format_opt
            if disable_filetypes[vim.bo[bufnr].filetype] then
                lsp_format_opt = 'never'
            else
                lsp_format_opt = 'fallback'
            end
            return {
                timeout_ms = 500,
                lsp_format = lsp_format_opt,
            }
        end,
        formatters_by_ft = {
            lua = { 'stylua' },
            -- JavaScript family with Prettier for formatting
            javascript = { 'prettierd', 'prettier' },
            typescript = { 'prettierd', 'prettier' },
            javascriptreact = { 'prettierd', 'prettier' },
            typescriptreact = { 'prettierd', 'prettier' },
            vue = { 'prettierd', 'prettier' },
            css = { 'prettierd', 'prettier' },
            scss = { 'prettierd', 'prettier' },
            less = { 'prettierd', 'prettier' },
            html = { 'prettierd', 'prettier' },
            json = { 'prettierd', 'prettier' },
            jsonc = { 'prettierd', 'prettier' },
            yaml = { 'prettierd', 'prettier' },
            markdown = { 'prettierd', 'prettier' },
            graphql = { 'prettierd', 'prettier' },
            -- Conform can also run multiple formatters sequentially
            python = { 'isort', 'black' },
        },
        -- Set up formatter configurations
        formatters = {
            prettier = {
                -- Use .prettierrc or package.json configs if they exist in the project
                prepend_args = function(self, ctx)
                    -- Check if we should use eslint integration
                    local has_eslint = vim.fs.find({ '.eslintrc', '.eslintrc.js', '.eslintrc.json', '.eslintrc.yml' }, {
                        upward = true,
                        path = ctx.filename,
                    })[1]

                    if has_eslint then
                        return { "--plugin=prettier-plugin-eslint" }
                    end
                    return {}
                end,
            },
            prettierd = {
                -- Use .prettierrc or package.json configs if they exist in the project
                prepend_args = function(self, ctx)
                    -- Check if we should use eslint integration
                    local has_eslint = vim.fs.find({ '.eslintrc', '.eslintrc.js', '.eslintrc.json', '.eslintrc.yml' }, {
                        upward = true,
                        path = ctx.filename,
                    })[1]

                    if has_eslint then
                        return { "--plugin=prettier-plugin-eslint" }
                    end
                    return {}
                end,
            }
        },
    },
}
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    -- BufReadPre (not VeryLazy) so the FileType autocmd below is registered
    -- before the first buffer's FileType event fires.
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
    },
    config = function()
      require("nvim-treesitter").setup()

      -- Install parsers
      require("nvim-treesitter").install({
        "bash",
        "c",
        "cpp",
        "css",
        "diff",
        "go",
        "html",
        "javascript",
        "jsx",
        "json",
        "lua",
        "luadoc",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "rust",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      })

      -- Enable built-in treesitter highlighting and indentation per filetype
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter-setup", { clear = true }),
        callback = function(ev)
          local bufnr = ev.buf
          -- Skip files over the treesitter threshold.
          if _G.is_bigfile and _G.is_bigfile(bufnr, "max_ts") then
            return
          end
          if vim.treesitter.language.add(vim.bo[bufnr].filetype) then
            vim.treesitter.start(bufnr)
            vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

      -- Textobjects
      local ok, configs = pcall(require, "nvim-treesitter-textobjects")
      if ok then
        configs.setup({
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["]f"] = "@function.outer",
              ["]c"] = "@class.outer",
              ["]a"] = "@parameter.inner",
            },
            goto_next_end = {
              ["]F"] = "@function.outer",
              ["]C"] = "@class.outer",
              ["]A"] = "@parameter.inner",
            },
            goto_previous_start = {
              ["[f"] = "@function.outer",
              ["[c"] = "@class.outer",
              ["[a"] = "@parameter.inner",
            },
            goto_previous_end = {
              ["[F"] = "@function.outer",
              ["[C"] = "@class.outer",
              ["[A"] = "@parameter.inner",
            },
          },
        })
      end
    end,
  },
}

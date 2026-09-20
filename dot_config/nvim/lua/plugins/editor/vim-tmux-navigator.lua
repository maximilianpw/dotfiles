return {
  "christoomey/vim-tmux-navigator",
  lazy = false,
  init = function()
    -- Herdr owns these mappings; keep vim-tmux-navigator only as the fallback
    -- when Neovim is running inside tmux instead.
    vim.g.tmux_navigator_no_mappings = 1
  end,
  config = function()
    local function navigate(window_command, direction)
      local previous_window = vim.api.nvim_get_current_win()
      vim.cmd("wincmd " .. window_command)
      if vim.api.nvim_get_current_win() ~= previous_window then
        return
      end

      if vim.env.HERDR_PANE_ID and vim.env.HERDR_PANE_ID ~= "" then
        local herdr = vim.env.HERDR_BIN_PATH
        if not herdr or herdr == "" then
          herdr = "herdr"
        end
        vim.fn.system({ herdr, "pane", "focus", "--direction", direction, "--pane", vim.env.HERDR_PANE_ID })
        return
      end

      if vim.env.TMUX and vim.env.TMUX ~= "" then
        local tmux_direction = {
          left = "Left",
          down = "Down",
          up = "Up",
          right = "Right",
        }
        pcall(vim.cmd, "TmuxNavigate" .. tmux_direction[direction])
      end
    end

    local mappings = {
      { "<C-h>", "h", "left" },
      { "<C-j>", "j", "down" },
      { "<C-k>", "k", "up" },
      { "<C-l>", "l", "right" },
    }

    for _, mapping in ipairs(mappings) do
      vim.keymap.set("n", mapping[1], function()
        navigate(mapping[2], mapping[3])
      end, { silent = true, noremap = true, desc = "Navigate " .. mapping[3] .. " (Vim/Herdr)" })
    end
  end,
}

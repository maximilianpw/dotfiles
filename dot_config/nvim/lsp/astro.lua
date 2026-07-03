local ok_util, util = pcall(require, "lspconfig.util")

local function tsserver_sdk(root_dir)
  if ok_util then
    local local_sdk = util.get_typescript_server_path(root_dir or vim.fn.getcwd())
    if local_sdk ~= "" then
      return local_sdk
    end
  end

  local tsserver = vim.fn.exepath("tsserver")
  if tsserver == "" then
    return nil
  end

  local real_tsserver = vim.uv.fs_realpath(tsserver) or tsserver
  local sdk = vim.fs.normalize(vim.fs.dirname(real_tsserver) .. "/../lib")

  if vim.uv.fs_stat(sdk) then
    return sdk
  end

  return nil
end

return {
  cmd = { "astro-ls", "--stdio" },
  filetypes = { "astro" },
  root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
  init_options = {
    typescript = {},
  },
  before_init = function(_, config)
    if config.init_options and config.init_options.typescript and not config.init_options.typescript.tsdk then
      config.init_options.typescript.tsdk = tsserver_sdk(config.root_dir)
    end
  end,
}

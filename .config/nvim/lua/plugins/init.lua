-- Main plugin entry point that loads all plugin groups
return {
  -- Import all organized plugin groups
  { import = 'plugins.editor' },   -- Editor core functionality
  { import = 'plugins.ui' },       -- User interface enhancements
  { import = 'plugins.git' },      -- Git integration
  { import = 'plugins.coding' },   -- Coding assistance
  { import = 'plugins.lsp' },      -- Language server integration
  { import = 'plugins.style' },    -- Code formatting and linting
  { import = 'plugins.java' },     -- Java specific plugins
}
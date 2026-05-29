-- Canonical config-file name lists for JS/TS tooling.
-- Shared by conform (formatting), nvim-lint (linting), and lsp/ server specs so
-- the "what files mark a prettier/biome/eslint/oxlint project" answer lives in one place.

local M = {}

-- https://prettier.io/docs/configuration
M.prettier = {
  ".prettierrc",
  ".prettierrc.json",
  ".prettierrc.yml",
  ".prettierrc.yaml",
  ".prettierrc.json5",
  ".prettierrc.js",
  ".prettierrc.cjs",
  ".prettierrc.mjs",
  ".prettierrc.toml",
  "prettier.config.js",
  "prettier.config.cjs",
  "prettier.config.mjs",
}

M.biome = {
  "biome.json",
  "biome.jsonc",
}

M.eslint = {
  ".eslintrc",
  ".eslintrc.js",
  ".eslintrc.cjs",
  ".eslintrc.mjs",
  ".eslintrc.json",
  ".eslintrc.yaml",
  ".eslintrc.yml",
  "eslint.config.js",
  "eslint.config.mjs",
  "eslint.config.cjs",
}

M.oxlint = {
  "oxlintrc.json",
  ".oxlintrc.json",
}

return M

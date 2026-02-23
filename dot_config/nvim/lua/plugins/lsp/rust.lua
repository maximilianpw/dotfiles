return {
	"mrcjkb/rustaceanvim",
	version = "^5",
	lazy = false,
	ft = { "rust" },
	config = function()
		vim.g.rustaceanvim = {
			-- LSP configuration
			server = {
				default_settings = {
					["rust-analyzer"] = {
						numThreads = 4,
						cargo = {
							allFeatures = false,
							loadOutDirsFromCheck = false,
							buildScripts = {
								enable = false,
							},
						},
						checkOnSave = {
							command = "check",
							extraArgs = {},
						},
						procMacro = {
							enable = false,
						},
						diagnostics = {
							enable = true,
							experimental = {
								enable = false,
							},
							disabled = {},
							warningsAsHint = {},
							warningsAsInfo = {},
						},
						inlayHints = {
							bindingModeHints = {
								enable = false,
							},
							chainingHints = {
								enable = true,
							},
							closingBraceHints = {
								minLines = 25,
							},
							closureReturnTypeHints = {
								enable = "never",
							},
							lifetimeElisionHints = {
								enable = "never",
								useParameterNames = false,
							},
							maxLength = 25,
							parameterHints = {
								enable = true,
							},
							reborrowHints = {
								enable = "never",
							},
							renderColons = true,
							typeHints = {
								enable = true,
								hideClosureInitialization = false,
								hideNamedConstructor = false,
							},
						},
					},
				},
			},
			-- DAP configuration (disabled as requested)
			dap = {
				adapter = false,
			},
		}
	end,
}

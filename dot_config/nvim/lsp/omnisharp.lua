return {
	cmd = { "omnisharp" },
	filetypes = { "cs" },
	root_markers = { "*.sln", "*.csproj", ".git" },
	enable_roslyn_analyzers = true,
	organize_imports_on_format = true,
	enable_import_completion = true,
	handlers = {
		["textDocument/definition"] = function(...)
			local ok, omnisharp_extended = pcall(require, "omnisharp_extended")
			if ok then
				return omnisharp_extended.handler(...)
			end
			return vim.lsp.handlers["textDocument/definition"](...)
		end,
	},
}

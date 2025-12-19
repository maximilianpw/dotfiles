-- Debug configuration with DAP
return {
	"mfussenegger/nvim-dap",
	dependencies = {
		-- Creates a beautiful debugger UI
		"rcarriga/nvim-dap-ui",

		-- Required dependency for nvim-dap-ui
		"nvim-neotest/nvim-nio",

		-- Virtual text support for variables
		"theHamsta/nvim-dap-virtual-text",

		-- Persistent breakpoints across sessions
		"Weissle/persistent-breakpoints.nvim",

		-- Add your own debuggers here
		"leoluz/nvim-dap-go",
		"mxsdev/nvim-dap-vscode-js",
	},
	keys = {
		-- Debug keymaps using <leader>d prefix
		{
			"<leader>dc",
			function()
				require("dap").continue()
			end,
			desc = "Debug: Start/Continue",
		},
		{
			"<leader>di",
			function()
				require("dap").step_into()
			end,
			desc = "Debug: Step Into",
		},
		{
			"<leader>do",
			function()
				require("dap").step_over()
			end,
			desc = "Debug: Step Over",
		},
		{
			"<leader>dO",
			function()
				require("dap").step_out()
			end,
			desc = "Debug: Step Out",
		},
		{
			"<leader>db",
			function()
				require("dap").toggle_breakpoint()
			end,
			desc = "Debug: Toggle Breakpoint",
		},
		{
			"<leader>dB",
			function()
				require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end,
			desc = "Debug: Set Conditional Breakpoint",
		},
		{
			"<leader>dr",
			function()
				require("dap").repl.open()
			end,
			desc = "Debug: Open REPL",
		},
		{
			"<leader>dl",
			function()
				require("dap").run_last()
			end,
			desc = "Debug: Run Last",
		},
		{
			"<leader>dt",
			function()
				require("dap").terminate()
			end,
			desc = "Debug: Terminate",
		},
		{
			"<leader>du",
			function()
				require("dapui").toggle()
			end,
			desc = "Debug: Toggle UI",
		},
		{
			"<leader>de",
			function()
				require("dapui").eval()
			end,
			desc = "Debug: Evaluate Expression",
			mode = { "n", "v" },
		},
		{
			"<leader>dR",
			function()
				require("dap").restart()
			end,
			desc = "Debug: Restart",
		},
		{
			"<leader>dC",
			function()
				require("dap").run_to_cursor()
			end,
			desc = "Debug: Run to Cursor",
		},
		{
			"<leader>dh",
			function()
				require("dap.ui.widgets").hover()
			end,
			desc = "Debug: Hover Variables",
			mode = { "n", "v" },
		},
		{
			"<leader>dj",
			function()
				require("dap").down()
			end,
			desc = "Debug: Down Stack Frame",
		},
		{
			"<leader>dk",
			function()
				require("dap").up()
			end,
			desc = "Debug: Up Stack Frame",
		},
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")


		-- Dap UI setup
		-- For more information, see |:help nvim-dap-ui|
		dapui.setup({
			icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
			controls = {
				enabled = true,
				element = "repl",
				icons = {
					pause = "⏸",
					play = "▶",
					step_into = "⏎",
					step_over = "⏭",
					step_out = "⏮",
					step_back = "b",
					run_last = "▶▶",
					terminate = "⏹",
					disconnect = "⏏",
				},
			},
			layouts = {
				{
					elements = {
						-- Elements can be strings or table with id and size keys.
						{ id = "scopes", size = 0.25 },
						"breakpoints",
						"stacks",
						"watches",
					},
					size = 40, -- 40 columns
					position = "left",
				},
				{
					elements = {
						"repl",
						"console",
					},
					size = 0.25, -- 25% of total lines
					position = "bottom",
				},
			},
			floating = {
				max_height = nil, -- These can be integers or a float between 0 and 1.
				max_width = nil, -- Floats will be treated as percentage of your screen.
				border = "single", -- Border style. Can be 'single', 'double' or 'rounded'
				mappings = {
					close = { "q", "<Esc>" },
				},
			},
			-- Mappings for all elements
			mappings = {
				-- edit value, expand tree, open element, remove, repl, toggle
				edit = "e",
				expand = { "<CR>", "o" },
				open = "o",
				remove = "d",
				repl = "r",
				toggle = "t",
			}, --  [oai_citation:0‡GitHub](https://github.com/rcarriga/nvim-dap-ui?utm_source=chatgpt.com)

			-- Per-element overrides (empty by default)
			element_mappings = {},

			-- Show full lines when expanded, use buffer windows
			expand_lines = false,
			force_buffers = false,

			-- How to render variable values
			render = {
				indent = 1,
				max_value_lines = 100,
			},
		})

		-- VSCode-like breakpoint colors and highlights
		vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#e51400" })
		vim.api.nvim_set_hl(0, "DapBreakpointCondition", { fg = "#f89c1c" })
		vim.api.nvim_set_hl(0, "DapBreakpointRejected", { fg = "#848484" })
		vim.api.nvim_set_hl(0, "DapLogPoint", { fg = "#61afef" })
		vim.api.nvim_set_hl(0, "DapStopped", { fg = "#ffcc00" })
		vim.api.nvim_set_hl(0, "DapStoppedLine", { bg = "#555530" })

		-- VSCode-like breakpoint icons with circles
		local breakpoint_icons = vim.g.have_nerd_font
				and {
					Breakpoint = "󰝥",          -- Filled circle (red)
					BreakpointCondition = "󰟃", -- Circle with dot (orange)
					BreakpointRejected = "",  -- Hollow circle (gray)
					LogPoint = "󰛿",           -- Diamond (blue)
					Stopped = "",            -- Arrow (yellow)
				}
			or {
				Breakpoint = "●",
				BreakpointCondition = "◉",
				BreakpointRejected = "○",
				LogPoint = "◆",
				Stopped = "▶",
			}

		-- Configure DAP signs with VSCode-like styling
		vim.fn.sign_define("DapBreakpoint", {
			text = breakpoint_icons.Breakpoint,
			texthl = "DapBreakpoint",
			linehl = "",
			numhl = "DapBreakpoint",
		})
		vim.fn.sign_define("DapBreakpointCondition", {
			text = breakpoint_icons.BreakpointCondition,
			texthl = "DapBreakpointCondition",
			linehl = "",
			numhl = "DapBreakpointCondition",
		})
		vim.fn.sign_define("DapBreakpointRejected", {
			text = breakpoint_icons.BreakpointRejected,
			texthl = "DapBreakpointRejected",
			linehl = "",
			numhl = "DapBreakpointRejected",
		})
		vim.fn.sign_define("DapLogPoint", {
			text = breakpoint_icons.LogPoint,
			texthl = "DapLogPoint",
			linehl = "",
			numhl = "DapLogPoint",
		})
		vim.fn.sign_define("DapStopped", {
			text = breakpoint_icons.Stopped,
			texthl = "DapStopped",
			linehl = "DapStoppedLine",
			numhl = "DapStopped",
		})

		-- Configure DAP virtual text
		local ok_virtual_text, nvim_dap_virtual_text = pcall(require, "nvim-dap-virtual-text")
		if ok_virtual_text then
			nvim_dap_virtual_text.setup({
				enabled = true, -- turn the plugin on
				enable_commands = true, -- create DapVirtualTextEnable/Disable/Toggle/ForceRefresh commands
				highlight_changed_variables = true, -- highlight when values change
				highlight_new_as_changed = false, -- new variables aren’t “changed”
				show_stop_reason = true, -- show reason on exception
				commented = false, -- prefix with commentstring
				only_first_definition = true, -- don’t repeat virtual text for later references
				all_references = false, -- show for all references, not just definitions
				clear_on_continue = false, -- clear text when you hit continue
				filter_references_pattern = "<module", -- filter what refs get shown
				virt_text_pos = vim.fn.has("nvim-0.10") == 1 and "inline" or "eol",
				all_frames = false, -- show frames for all threads
				virt_lines = false, -- use virtual lines instead of text
				virt_lines_above = false, -- put virtual lines above the line, not below
				virt_text_win_col = nil, -- fixed column for virtual text
				text_prefix = "", -- prefix every variable with this
				separator = " | ", -- separator between name and value
				error_prefix = "✖ ", -- prefix on error messages
				info_prefix = "ℹ ", -- prefix for info messages
				display_callback = function(variable, _buf, _stackframe, _node, options)
					if options.virt_text_pos == "inline" then
						return " = " .. variable.value
					else
						return variable.name .. " = " .. variable.value
					end
				end,
			})
		end

		dap.listeners.after.event_initialized["dapui_config"] = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated["dapui_config"] = function()
			dapui.close()
		end
		dap.listeners.before.event_exited["dapui_config"] = function()
			dapui.close()
		end

		-- Configure C# debugging using netcoredbg
		-- Note: On NixOS, install netcoredbg via system packages or nix-shell
		dap.adapters.coreclr = {
			type = "executable",
			command = "netcoredbg",
			args = { "--interpreter=vscode" },
		}

		dap.configurations.cs = {
			{
				type = "coreclr",
				name = "launch - netcoredbg",
				request = "launch",
				program = function()
					-- Try to find the most recent DLL in bin/Debug or bin/Release
					local cwd = vim.fn.getcwd()
					local dll_patterns = {
						cwd .. "/bin/Debug/**/*.dll",
						cwd .. "/bin/Release/**/*.dll",
						cwd .. "/**/bin/Debug/**/*.dll",
					}

					for _, pattern in ipairs(dll_patterns) do
						local dlls = vim.fn.glob(pattern, false, true)
						if #dlls > 0 then
							-- Return the most recently modified DLL
							table.sort(dlls, function(a, b)
								return vim.fn.getftime(a) > vim.fn.getftime(b)
							end)
							return vim.fn.input("Path to dll: ", dlls[1], "file")
						end
					end

					-- Fallback to manual input if no DLL found
					return vim.fn.input("Path to dll: ", cwd .. "/bin/Debug/", "file")
				end,
			},
			{
				type = "coreclr",
				name = "attach - netcoredbg",
				request = "attach",
				processId = require("dap.utils").pick_process,
			},
		}

		-- Configure TypeScript/JavaScript debugging
		-- Note: On NixOS, install debuggers via system packages or nix-shell
		local ok_dap_vscode_js, dap_vscode_js = pcall(require, "dap-vscode-js")
		if ok_dap_vscode_js then
			dap_vscode_js.setup({
				-- Use system-installed js-debug-adapter
				debugger_cmd = { "js-debug-adapter" },
				-- which adapters to register in nvim-dap
				adapters = { 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost' },
			})

			-- TypeScript/JavaScript configurations
			for _, language in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
				dap.configurations[language] = {
					{
						type = "pwa-node",
						request = "launch",
						name = "Launch file",
						program = "${file}",
						cwd = "${workspaceFolder}",
						sourceMaps = true,
						skipFiles = { "<node_internals>/**" },
					},
					{
						type = "pwa-node",
						request = "attach",
						name = "Attach",
						processId = require('dap.utils').pick_process,
						cwd = "${workspaceFolder}",
						sourceMaps = true,
						skipFiles = { "<node_internals>/**" },
					},
					{
						type = "pwa-chrome",
						request = "launch",
						name = "Start Chrome with \"localhost\"",
						url = "http://localhost:9229",
						webRoot = "${workspaceFolder}",
						skipFiles = { "<node_internals>/**/*.js" },
					},
					{
						type = "pwa-node",
						request = "launch",
						name = "Launch TypeScript file",
						program = "${file}",
						cwd = "${workspaceFolder}",
						runtimeExecutable = "npx",
						runtimeArgs = { "tsx" },
						sourceMaps = true,
						skipFiles = { "<node_internals>/**" },
					},
					{
						type = "pwa-node",
						request = "launch",
						name = "Launch Jest Tests",
						-- trace = true, -- include debugger info
						runtimeExecutable = "node",
						runtimeArgs = {
							"./node_modules/jest/bin/jest.js",
							"--runInBand",
						},
						rootPath = "${workspaceFolder}",
						cwd = "${workspaceFolder}",
						console = "integratedTerminal",
						internalConsoleOptions = "neverOpen",
						skipFiles = { "<node_internals>/**", "node_modules/**" },
					},
				}
			end
		end

		-- Configure Go debugging
		-- Note: On NixOS, install delve via system packages or nix-shell
		local ok_dap_go, dap_go = pcall(require, "dap-go")
		if ok_dap_go then
			dap_go.setup({
				-- Additional dap configurations can be added here
				dap_configurations = {
					{
						type = "go",
						name = "Attach remote",
						mode = "remote",
						request = "attach",
					},
				},
				-- delve configurations
				delve = {
					-- Path to delve (use system-installed)
					path = "dlv",
					-- Default port for delve
					initialize_timeout_sec = 20,
					port = "${port}",
					args = {},
					build_flags = "",
				},
			})
		end

		-- Configure Rust debugging using lldb-dap (comes with LLVM)
		dap.adapters.lldb = {
			type = "executable",
			command = "lldb-dap",
			name = "lldb",
		}

		dap.configurations.rust = {
			{
				name = "Launch file",
				type = "lldb",
				request = "launch",
				program = function()
					-- Try to find the executable in target/debug
					local cwd = vim.fn.getcwd()
					local cargo_toml = vim.fn.glob(cwd .. "/Cargo.toml")
					if cargo_toml ~= "" then
						-- Get the package name from Cargo.toml
						local lines = vim.fn.readfile(cargo_toml)
						for _, line in ipairs(lines) do
							local name = line:match('^name%s*=%s*"([^"]+)"')
							if name then
								local binary = cwd .. "/target/debug/" .. name
								if vim.fn.filereadable(binary) == 1 then
									return vim.fn.input("Path to executable: ", binary, "file")
								end
							end
						end
					end
					return vim.fn.input("Path to executable: ", cwd .. "/target/debug/", "file")
				end,
				cwd = "${workspaceFolder}",
				stopOnEntry = false,
				args = {},
			},
			{
				name = "Launch file with args",
				type = "lldb",
				request = "launch",
				program = function()
					local cwd = vim.fn.getcwd()
					return vim.fn.input("Path to executable: ", cwd .. "/target/debug/", "file")
				end,
				cwd = "${workspaceFolder}",
				stopOnEntry = false,
				args = function()
					local args_string = vim.fn.input("Arguments: ")
					return vim.split(args_string, " +")
				end,
			},
			{
				name = "Attach to process",
				type = "lldb",
				request = "attach",
				pid = require("dap.utils").pick_process,
				args = {},
			},
		}

		-- Setup persistent breakpoints
		local ok_persistent_breakpoints, persistent_breakpoints = pcall(require, "persistent-breakpoints")
		if ok_persistent_breakpoints then
			persistent_breakpoints.setup({
				-- Save breakpoints to project directory
				save_dir = vim.fn.stdpath("data") .. "/breakpoints",
				-- Load breakpoints when opening buffer
				load_breakpoints_event = { "BufReadPost" },
				-- Automatically save breakpoints
				perf_record = false,
			})
		end
	end,
}

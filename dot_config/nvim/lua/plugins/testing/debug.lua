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

		-- Installs the debug adapters for you
		"williamboman/mason.nvim",
		"jay-babu/mason-nvim-dap.nvim",

		-- Add your own debuggers here
		"leoluz/nvim-dap-go",
		"mfussenegger/nvim-dap-python",
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
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		require("mason-nvim-dap").setup({
			-- Makes a best effort to setup the various debuggers with
			-- reasonable debug configurations
			automatic_installation = true,

			-- You can provide additional configuration to the handlers,
			-- see mason-nvim-dap README for more information
			handlers = {},

			-- Install debuggers for common languages
			ensure_installed = {
				"node2", -- Node.js
				"chrome", -- Chrome/JS debugging
			},
		})

		dap.adapters.chrome = {
			type = "executable",
			command = "node",
			args = {
				vim.fn.stdpath("data") .. "/mason/packages/chrome-debug-adapter/out/src/chromeDebug.js",
			},
		}

		dap.configurations.javascript = {
			{
				type = "chrome",
				request = "attach",
				name = "Attach to Chrome",
				program = "${file}",
				cwd = vim.fn.getcwd(),
				sourceMaps = true,
				protocol = "inspector",
				port = 9222, -- << your desired port here
				webRoot = "${workspaceFolder}",
			},
		}

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

		-- Change breakpoint icons and highlights
		vim.api.nvim_set_hl(0, "DapBreak", { fg = "#e51400" })
		vim.api.nvim_set_hl(0, "DapStop", { fg = "#ffcc00" })

		-- Set DAP signs using the modern approach
		local breakpoint_icons = vim.g.have_nerd_font
				and {
					Breakpoint = "",
					BreakpointCondition = "",
					BreakpointRejected = "",
					LogPoint = "",
					Stopped = "",
				}
			or {
				Breakpoint = "●",
				BreakpointCondition = "⊜",
				BreakpointRejected = "⊘",
				LogPoint = "◆",
				Stopped = "⭔",
			}

		-- Configure DAP signs
		dap.defaults.fallback.sign = {
			DapBreakpoint = { text = breakpoint_icons.Breakpoint, texthl = "DapBreak", linehl = "", numhl = "DapBreak" },
			DapBreakpointCondition = {
				text = breakpoint_icons.BreakpointCondition,
				texthl = "DapBreak",
				linehl = "",
				numhl = "DapBreak",
			},
			DapBreakpointRejected = {
				text = breakpoint_icons.BreakpointRejected,
				texthl = "DapBreak",
				linehl = "",
				numhl = "DapBreak",
			},
			DapLogPoint = { text = breakpoint_icons.LogPoint, texthl = "DapBreak", linehl = "", numhl = "DapBreak" },
			DapStopped = { text = breakpoint_icons.Stopped, texthl = "DapStop", linehl = "", numhl = "DapStop" },
		}

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
	end,
}

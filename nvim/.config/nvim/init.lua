-- leader key
vim.g.mapleader = " "

-- basic options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.wrap = false
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 50
vim.opt.scrolloff = 8

-- filetype-specific indentation
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "python", "yaml", "toml" },
	callback = function()
		vim.opt_local.shiftwidth = 2
		vim.opt_local.tabstop = 2
	end,
})

-- keymaps
vim.keymap.set("n", "<leader>w", ":w<cr>")
vim.keymap.set("n", "<leader>q", ":q<cr>")
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<cr>")
vim.keymap.set("n", "<leader>gt", ":ToggleTerm<cr>")
vim.keymap.set("n", "<leader>gg", ":Git<cr>")
vim.keymap.set("n", "<leader>gp", ":Git push<cr>")
vim.keymap.set("n", "<leader>gs", ":Git status<cr>")

-- Markdown preview
vim.keymap.set("n", "<leader>mp", ":Glow<cr>")

-- Git conflict
vim.keymap.set("n", "<leader>gc1", ":GitConflictChooseOurs<cr>")
vim.keymap.set("n", "<leader>gc2", ":GitConflictChooseTheirs<cr>")
vim.keymap.set("n", "<leader>gc3", ":GitConflictChooseBoth<cr>")
vim.keymap.set("n", "<leader>gcn", ":GitConflictNextConflict<cr>")
vim.keymap.set("n", "<leader>gcp", ":GitConflictPrevConflict<cr>")

-- Navigation
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- Move lines up/down
vim.keymap.set("n", "<A-j>", ":m .+1<cr>==")
vim.keymap.set("n", "<A-k>", ":m .-2<cr>==")
vim.keymap.set("v", "<A-j>", ":m '>+1<cr>gv=gv")
vim.keymap.set("v", "<A-k>", ":m '<-2<cr>gv=gv")

-- Center screen
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "J", "mzJ`z")

-- Delete without yank
vim.keymap.set("n", "d", '"_d')
vim.keymap.set("v", "d", '"_d')
vim.keymap.set("n", "dd", '"_dd')
vim.keymap.set("v", "x", '"_x')

-- Copy to clipboard
vim.keymap.set("n", "Y", "yg$")
vim.keymap.set("n", "<leader>y", '"+y')
vim.keymap.set("v", "<leader>y", '"+y')
vim.keymap.set("n", "<leader>Y", '"+Y')

-- Paste from clipboard
vim.keymap.set("n", "<leader>p", '"+p')
vim.keymap.set("n", "<leader>P", '"+P')
vim.keymap.set("v", "<leader>p", '"+p')
vim.keymap.set("v", "<leader>P", '"+P')

-- Undo/Redo
vim.keymap.set("n", "u", ":undo<cr>")
vim.keymap.set("n", "<C-r>", ":redo<cr>")

-- Search
vim.keymap.set("n", "<leader>/", ":nohlsearch<cr>")

-- Split
vim.keymap.set("n", "<leader>sv", ":vsplit<cr>")
vim.keymap.set("n", "<leader>sh", ":split<cr>")

-- Buffer
vim.keymap.set("n", "<leader>bd", ":bdelete<cr>")
vim.keymap.set("n", "<leader>bn", ":bnext<cr>")
vim.keymap.set("n", "<leader>bp", ":bprevious<cr>")

-- Quick actions
vim.keymap.set("n", "<leader>hs", ":set hlsearch!<cr>")
vim.keymap.set("n", "<leader>wr", ":set wrap!<cr>")
vim.keymap.set("n", "<leader>nu", ":set number!<cr>")
vim.keymap.set("n", "<leader>rn", ":set relativenumber!<cr>")
vim.keymap.set("n", "<leader>sp", ":set spell!<cr>")

-- LSP
vim.keymap.set("n", "<leader>ld", ":lua vim.diagnostic.open_float()<cr>")
vim.keymap.set("n", "<leader>lp", ":lua vim.diagnostic.goto_prev()<cr>")
vim.keymap.set("n", "<leader>ln", ":lua vim.diagnostic.goto_next()<cr>")
vim.keymap.set("n", "<leader>li", ":LspInfo<cr>")
vim.keymap.set("n", "<leader>lI", ":Mason<cr>")

-- Telescope
vim.keymap.set("n", "<leader>fr", ":Telescope resume<cr>")
vim.keymap.set("n", "<leader>fc", ":Telescope commands<cr>")
vim.keymap.set("n", "<leader>fm", ":Telescope marks<cr>")

-- NvimTree
vim.keymap.set("n", "<leader>er", ":NvimTreeRefresh<cr>")
vim.keymap.set("n", "<leader>ef", ":NvimTreeFindFile<cr>")

-- Quick edit
vim.keymap.set("n", "<leader>ev", ":edit $MYVIMRC<cr>")
vim.keymap.set("n", "<leader>sv", ":source $MYVIMRC<cr>")

-- Escape
vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set("i", "kj", "<Esc>")
vim.keymap.set("t", "jk", "<C-\\><C-n>")
vim.keymap.set("t", "kj", "<C-\\><C-n>")

-- IDE-like keymaps
vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "gr", vim.lsp.buf.references)
vim.keymap.set("n", "K", vim.lsp.buf.hover)
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)

-- Telescope keymaps
vim.keymap.set("n", "<leader>ff", ":Telescope find_files<cr>")
vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<cr>")
vim.keymap.set("n", "<leader>fb", ":Telescope buffers<cr>")
vim.keymap.set("n", "<leader>fh", ":Telescope help_tags<cr>")

-- AI keymaps
vim.keymap.set("n", "<leader>ao", "<cmd>ToggleTerm direction=float<cr>", { silent = true })
vim.keymap.set("n", "<leader>ac", "<cmd>ClaudeChat<cr>", { silent = true })
vim.keymap.set("n", "<leader>an", "<cmd>ClaudeChatNew<cr>", { silent = true })
vim.keymap.set("v", "<leader>as", ":ClaudeChatSendSelection<cr>", { silent = true })
vim.keymap.set("n", "<leader>oll", "<cmd>Ollama<cr>", { silent = true })

-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- plugins
require("lazy").setup({

	-- core lib
	"nvim-lua/plenary.nvim",

	-- fuzzy finder
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
	},

	-- treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").setup({
				ensure_installed = {
					"lua",
					"vim",
					"bash",
					"python",
					"javascript",
					"typescript",
					"json",
					"html",
					"css",
					"rust",
					"go",
					"markdown",
					"yaml",
					"toml",
				},
				highlight = { enable = true },
				indent = { enable = true },
			})
		end,
	},

	-- file explorer
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("nvim-tree").setup()
			vim.keymap.set("n", "<c-n>", ":NvimTreeToggle<cr>")
		end,
	},

	-- statusline
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},

	-- theme
	"gruvbox-community/gruvbox",

	-- autocomplete
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			require("luasnip.loaders.from_vscode").lazy_load()

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				sources = {
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer", keyword_length = 3 },
					{ name = "path" },
				},
				mapping = cmp.mapping.preset.insert({
					["<C-n>"] = cmp.mapping.select_next_item(),
					["<C-p>"] = cmp.mapping.select_prev_item(),
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
			})

			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "path" },
					{ name = "cmdline" },
				},
			})
		end,
	},

	-- AI assistants (using toggleterm)
	{
		"akinsho/toggleterm.nvim",
		cmd = { "ToggleTerm", "ToggleTerm direction=float", "LazyGit" },
		config = function()
			require("toggleterm").setup({
				direction = "float",
				float_opts = { border = "curved" },
				open_mapping = "<c-t>",
				hide_numbers = true,
				shade_filetypes = {},
				shade_terminals = true,
				shading_factor = 2,
				start_in_insert = true,
				insert_mappings = true,
				terminal_mappings = true,
				persist_size = true,
				size = function(term)
					if term.direction == "horizontal" then
						return 15
					elseif term.direction == "vertical" then
						return vim.o.columns * 0.4
					else
						return 20
					end
				end,
			})

			local function open_opencode()
				local Terminal = require("toggleterm.terminal").Terminal
				local opencode = Terminal:new({
					cmd = "opencode",
					direction = "float",
					float_opts = { border = "curved", width = 100, height = 30 },
				})
				opencode:toggle()
			end

			local function open_lazygit()
				local Terminal = require("toggleterm.terminal").Terminal
				local lazygit = Terminal:new({
					cmd = "lazygit",
					direction = "float",
					float_opts = { border = "curved", width = 120, height = 35 },
				})
				lazygit:toggle()
			end

			local function open_term_horizontal()
				local Terminal = require("toggleterm.terminal").Terminal
				local term = Terminal:new({ direction = "horizontal", size = 15 })
				term:toggle()
			end

			local function open_term_vertical()
				local Terminal = require("toggleterm.terminal").Terminal
				local term = Terminal:new({ direction = "vertical", size = vim.o.columns * 0.4 })
				term:toggle()
			end

			vim.keymap.set("n", "<leader>ao", open_opencode, { noremap = true, silent = true })
			vim.keymap.set("n", "<leader>gl", open_lazygit, { noremap = true, silent = true })
			vim.keymap.set("n", "<leader>th", open_term_horizontal, { noremap = true, silent = true })
			vim.keymap.set("n", "<leader>tv", open_term_vertical, { noremap = true, silent = true })
		end,
		event = "VeryLazy",
	},
	{
		"wtfox/claude-chat.nvim",
		keys = { { "<leader>ac", "<cmd>ClaudeChat<cr>", desc = "claude: chat" } },
		config = function()
			require("claude-chat").setup({
				split = "vsplit",
				width = 0.5,
			})
		end,
	},

	-- Ollama
	{
		"nomnivore/ollama.nvim",
		keys = { { "<leader>oll", "<cmd>Ollama<cr>", desc = "ollama: chat" } },
		cmd = { "Ollama" },
		config = function()
			require("ollama").setup({
				models = { "llama3.2" },
			})
		end,
	},

	-- LSP manager
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		config = function()
			require("mason").setup()
		end,
	},

	-- LSP
	{
		"neovim/nvim-lspconfig",
		config = function()
			vim.lsp.config("ts_ls", {
				capabilities = require("cmp_nvim_lsp").default_capabilities(),
			})
			vim.lsp.enable("ts_ls")
		end,
	},

	-- Git
	"tpope/vim-fugitive",

	-- Markdown preview (glow)
	{
		"ellisonleao/glow.nvim",
		cmd = "Glow",
		config = function()
			require("glow").setup({
				border = "rounded",
				style = "dark",
				preview = true,
			})
		end,
	},

	-- Merge conflicts
	{
		"akinsho/git-conflict.nvim",
		version = "*",
		config = function()
			require("git-conflict").setup()
		end,
	},
})

vim.cmd("colorscheme gruvbox")

-- LSP setup
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = args.buf })
		vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = args.buf })
		vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = args.buf })
	end,
})

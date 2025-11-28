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

-- keymaps
vim.keymap.set("n", "<leader>w", ":w<cr>")
vim.keymap.set("n", "<leader>q", ":q<cr>")

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
		build = ":tsupdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = "all",
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
			vim.keymap.set("n", "<c-n>", ":nvimtreeToggle<cr>")
		end,
	},

	-- statusline
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = {
					theme = "gruvbox",
					icons_enabled = true,
				},
			})
		end,
	},

	-- theme
	{
		"gruvbox-community/gruvbox",
		config = function()
			vim.cmd("colorscheme gruvbox")
		end,
	},

	-- lsp
	"neovim/nvim-lspconfig",

	-- autocomplete
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
		},
		config = function()
			local cmp = require("cmp")
			cmp.setup({
				sources = {
					{ name = "nvim_lsp" },
					{ name = "buffer" },
				},
				mapping = {
					["<tab>"] = cmp.mapping.select_next_item(),
					["<s-tab>"] = cmp.mapping.select_prev_item(),
					["<cr>"] = cmp.mapping.confirm({ select = true }),
				},
			})

			-- typescript example
			require("lspconfig").tsserver.setup({
				capabilities = require("cmp_nvim_lsp").default_capabilities(),
			})
		end,
	},
})

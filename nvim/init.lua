-- Install packer
local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.execute("!git clone https://github.com/wbthomason/packer.nvim " .. install_path)
end

vim.cmd([[
  augroup Packer
    autocmd!
    autocmd BufWritePost init.lua PackerCompile
  augroup end
]])

local use = require("packer").use
require("packer").startup(function()
  use("wbthomason/packer.nvim") -- Package manager
  use("tpope/vim-fugitive") -- Git commands in nvim
  use("tpope/vim-commentary") -- "gc" to comment visual regions/lines
  -- UI to select things (files, grep results, open buffers...)
  use({ "nvim-telescope/telescope.nvim", requires = { "nvim-lua/plenary.nvim" } })
  use("joshdick/onedark.vim") -- Theme inspired by Atom
  -- Add indentation guides even on blank lines
  use("lukas-reineke/indent-blankline.nvim")
  -- Add git related info in the signs columns and popups
  use({ "lewis6991/gitsigns.nvim", requires = { "nvim-lua/plenary.nvim" } })
  -- Highlight, edit, and navigate code using a fast incremental parsing library
  use("nvim-treesitter/nvim-treesitter")
  -- Additional textobjects for treesitter
  use("nvim-treesitter/nvim-treesitter-textobjects")
  use("neovim/nvim-lspconfig") -- Collection of configurations for built-in LSP client
  use("hrsh7th/nvim-cmp") -- Autocompletion plugin
  use("hrsh7th/cmp-nvim-lsp")
  use("saadparwaiz1/cmp_luasnip")
  use("L3MON4D3/LuaSnip") -- Snippets plugin
  use({ "scalameta/nvim-metals", requires = { "nvim-lua/plenary.nvim" } })
  use({
    "kyazdani42/nvim-tree.lua",
    requires = "kyazdani42/nvim-web-devicons",
    config = function()
      require("nvim-tree").setup({ view = { width = 50 } })
    end,
  })
  -- use 'nvim-lua/lsp-status.nvim'
  use({ "ckipp01/stylua-nvim" })
end)

--Incremental live completion (note: this is now a default on master)
vim.o.inccommand = "nosplit"

--Set highlight on search
vim.o.hlsearch = false

--Make line numbers default
vim.wo.number = true

--Do not save when switching buffers (note: this is now a default on master)
vim.o.hidden = true

--Enable mouse mode
vim.o.mouse = "a"

--Enable break indent
vim.o.breakindent = true

--Save undo history
vim.opt.undofile = true

--Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

--Decrease update time
vim.o.updatetime = 250
vim.wo.signcolumn = "yes"

--Set colorscheme (order is important here)
vim.o.termguicolors = true
vim.g.onedark_terminal_italics = 2
vim.cmd([[colorscheme onedark]])

--Set statusbar
--function metals_status()
--  return vim.g['metals_status']
--end
-- vim.api.nvim_exec(
--   [[
-- function! MetalsStatus()
--   return get(g:, 'metals_status', "")
-- endfunction
-- ]],
--   false
-- )
-- vim.g.lightline = {
--   colorscheme = "onedark",
--   active = { left = { { "mode", "paste" }, { "metals_status", "gitbranch", "readonly", "filename", "modified" } } },
--   component_function = { metals_status = "MetalsStatus", gitbranch = "fugitive#head" },
-- }

require("statusline")
vim.opt.statusline = "%!luaeval('Super_custom_status_line()')"

--Remap space as leader key
vim.api.nvim_set_keymap("", "<Space>", "<Nop>", { noremap = true, silent = true })
vim.g.mapleader = " "
vim.g.maplocalleader = " "

--Remap for dealing with word wrap
vim.api.nvim_set_keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", { noremap = true, expr = true, silent = true })
vim.api.nvim_set_keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", { noremap = true, expr = true, silent = true })

-- Highlight on yank
vim.cmd([[
  augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
  augroup end
]])

-- Y yank until the end of line  (note: this is now a default on master)
vim.api.nvim_set_keymap("n", "Y", "y$", { noremap = true })

--Map blankline
vim.g.indent_blankline_char = "⋅"
vim.g.indent_blankline_filetype_exclude = { "help", "packer" }
vim.g.indent_blankline_buftype_exclude = { "terminal", "nofile" }
vim.g.indent_blankline_char_highlight = "LineNr"
vim.g.indent_blankline_show_trailing_blankline_indent = true

-- Gitsigns
require("gitsigns").setup({
  signs = {
    add = { hl = "GitGutterAdd", text = "+" },
    change = { hl = "GitGutterChange", text = "~" },
    delete = { hl = "GitGutterDelete", text = "_" },
    topdelete = { hl = "GitGutterDelete", text = "‾" },
    changedelete = { hl = "GitGutterChange", text = "~" },
  },
})

-- Telescope
require("telescope").setup({
  defaults = {
    mappings = {
      i = {
        ["<C-u>"] = false,
        ["<C-d>"] = false,
      },
    },
    layout_config = {
      vertical = { width = 0.5 },
      -- other layout configuration here
    },
  },
  pickers = {
    buffers = {
      sort_lastused = true,
    },
  },
})
--Add leader shortcuts
vim.api.nvim_set_keymap(
  "n",
  "<leader><space>",
  [[<cmd>lua require('telescope.builtin').buffers({layout_strategy="vertical"})<CR>]],
  { noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
  "n",
  "<leader>sf",
  [[<cmd>lua require('telescope.builtin').find_files({layout_strategy="vertical"})<CR>]],
  { noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
  "n",
  "<leader>sb",
  [[<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<CR>]],
  { noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
  "n",
  "<leader>sh",
  [[<cmd>lua require('telescope.builtin').help_tags()<CR>]],
  { noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
  "n",
  "<leader>st",
  [[<cmd>lua require('telescope.builtin').tags()<CR>]],
  { noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
  "n",
  "<leader>sd",
  [[<cmd>lua require('telescope.builtin').grep_string()<CR>]],
  { noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
  "n",
  "<leader>sp",
  [[<cmd>lua require('telescope.builtin').live_grep()<CR>]],
  { noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
  "n",
  "<leader>so",
  [[<cmd>lua require('telescope.builtin').tags{ only_current_buffer = true }<CR>]],
  { noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
  "n",
  "<leader>?",
  [[<cmd>lua require('telescope.builtin').oldfiles()<CR>]],
  { noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
  "n",
  "<leader>co",
  [[<cmd>lua require('telescope.builtin').commands()<CR>]],
  { noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
  "n",
  "<leader>ch",
  [[<cmd>lua require('telescope.builtin').command_history()<CR>]],
  { noremap = true, silent = true }
)
-- vim.api.nvim_set_keymap(
--   "n",
--   "<leader>t",
--   [[<cmd>lua require('telescope.builtin').builtin()<CR>]],
--   { noremap = true, silent = true }
-- )

-- Making yanking and pasting to and from system clipboard
vim.api.nvim_set_keymap("v", "y", '"+y', { noremap = true, silent = false })
vim.api.nvim_set_keymap("n", "y", '"+y', { noremap = true, silent = false })
vim.api.nvim_set_keymap("v", "p", '"+p', { noremap = true, silent = false })
vim.api.nvim_set_keymap("n", "p", '"+p', { noremap = true, silent = false })
vim.api.nvim_set_keymap("v", "c", '"+c', { noremap = true, silent = false })

-- Setup nvim-tree shortcuts
vim.api.nvim_set_keymap(
  "n",
  "<leader>t",
  [[<cmd>lua require'nvim-tree'.toggle(false)<CR>]],
  { noremap = true, silent = false }
)
vim.api.nvim_set_keymap(
  "n",
  "<leader>ft",
  [[<cmd>lua require'nvim-tree'.toggle(true)<CR>]],
  { noremap = true, silent = false }
)

-- Treesitter configuration
-- Parsers must be installed manually via :TSInstall
require("nvim-treesitter.configs").setup({
  highlight = {
    enable = true, -- false will disable the whole extension
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },
  indent = {
    enable = true,
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        ["]m"] = "@function.outer",
        ["]]"] = "@class.outer",
      },
      goto_next_end = {
        ["]M"] = "@function.outer",
        ["]["] = "@class.outer",
      },
      goto_previous_start = {
        ["[m"] = "@function.outer",
        ["[["] = "@class.outer",
      },
      goto_previous_end = {
        ["[M"] = "@function.outer",
        ["[]"] = "@class.outer",
      },
    },
  },
})

-- nvim-cmp supports additional completion capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menuone,noselect"

-- luasnip setup
local luasnip = require("luasnip")

-- nvim-cmp setup
local cmp = require("cmp")
cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = {
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.close(),
    ["<CR>"] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    }),
    ["<Tab>"] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end,
    ["<S-Tab>"] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end,
  },
  sources = {
    { name = "nvim_lsp", priority = 10 },
    { name = "luasnip" },
    { name = "vsnip" },
  },
})

local cmd = vim.cmd
local g = vim.g

local function map(mode, lhs, rhs, opts)
  local options = { noremap = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- nvim-metals
g["metals_server_version"] = "0.11.6"

vim.opt_global.shortmess:remove("F"):append("c")

-- LSP
map("n", "<C-b>", "<cmd>lua vim.lsp.buf.definition()<CR>")
map("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>")
map("v", "K", [[<Esc><cmd>lua require("metals").type_of_range()<CR>]])
map("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
map("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>")
map("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>")
map("i", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>")
map("n", "gds", "<cmd>lua vim.lsp.buf.document_symbol()<CR>")
map("n", "gws", "<cmd>lua vim.lsp.buf.workspace_symbol()<CR>")
--map("n", "<leader>tt", [[<cmd>lua require("metals.tvp").toggle_tree_view()<CR>]])
--map("n", "<leader>tr", [[<cmd>lua require("metals.tvp").reveal_in_tree()<CR>]])
map("n", "<leader>cl", [[<cmd>lua vim.lsp.codelens.run()<CR>]])
map("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>")
map("n", "<leader>f", "<cmd>lua vim.lsp.buf.formatting()<CR>")
map("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>")
map("n", "<leader>ws", '<cmd>lua require"metals".worksheet_hover()<CR>')
map("n", "<leader>da", [[<cmd>lua vim.diagnostic.setqflist()<CR>]])
map("n", "<leader>de", [[<cmd>lua vim.diagnostic.setqflist({severity = "E"})<CR>]])
map("n", "<leader>dw", [[<cmd>lua vim.diagnostic.setqflist({severity = "W"})<CR>]])
map("n", "<leader>db", "<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>") -- buffer diagnostics only
map("n", "<leader>dh", [[<cmd>lua vim.diagnostic.open_float(0, {scope = "line"})<CR>]])
map("n", "<leader>st", [[<cmd>lua require("metals").toggle_setting("showImplicitArguments")<CR>]])
map("n", "<leader>pd", "<cmd>lua vim.diagnostic.goto_prev { wrap = false }<CR>")
map("n", "<leader>nd", "<cmd>lua vim.diagnostic.goto_next { wrap = false }<CR>")
map("n", "tds", [[<cmd>lua require("telescope.builtin").lsp_document_symbols()<CR>]])
map("n", "tws", [[<cmd>lua require("telescope.builtin").lsp_dynamic_workspace_symbols()<CR>]])

----------------------------------
-- COMMANDS ----------------------
----------------------------------
-- LSP
cmd([[augroup lsp]])
cmd([[autocmd!]])
cmd([[autocmd FileType scala setlocal omnifunc=v:lua.vim.lsp.omnifunc]])
cmd([[autocmd FileType scala,sbt lua require("metals").initialize_or_attach(metals_config)]])
cmd([[augroup end]])

----------------------------------
-- LSP Setup ---------------------
----------------------------------
metals_config = require("metals").bare_config()

metals_config.init_options.statusBarProvider = "on"
metals_config.settings.showImplicitArguments = true
metals_config.settings.showImplicitConversionsAndClasses = true
metals_config.settings.showInferredType = true
metals_config.settings.superMethodLensesEnabled = true

-- Example if you are including snippets
capabilities.textDocument.completion.completionItem.snippetSupport = true

metals_config.capabilities = capabilities

metals_config.on_attach = function(client, bufnr)
  vim.cmd([[autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()]])
  vim.cmd([[autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()]])
  vim.cmd([[autocmd BufEnter,CursorHold,InsertLeave <buffer> lua vim.lsp.codelens.refresh()]])
end

-- sumneko lua
local lsp_config = require("lspconfig")

lsp_config.util.default_config = vim.tbl_extend("force", lsp_config.util.default_config, {
  capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities),
})

local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

lsp_config.sumneko_lua.setup({
  cmd = {
    "/Users/kharivitalij/Software/lua-language-server/bin/macOS/lua-language-server",
    "-E",
    "/Users/kharivitalij/Software/lua-language-server/main.lua",
  },
  commands = {
    Format = {
      function()
        require("stylua-nvim").format_file()
      end,
    },
  },
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
        path = runtime_path,
      },
      diagnostics = { globals = { "vim", "it", "describe", "before_each" } },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
      },
      telemetry = { enable = false },
    },
  },
})

vim.opt_global.scrolloff = 5
vim.opt.cursorline = true

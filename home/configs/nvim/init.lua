-- Indentation — 2-space soft tabs
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true

-- Appearance
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.colorcolumn = "120"
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.cmd.colorscheme("nightfox")

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true

-- Quality of life
vim.opt.backspace = "indent,eol,start"
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
vim.opt.laststatus = 2
vim.opt.ruler = true
vim.opt.showmatch = true
vim.opt.hidden = true

-- No swap/backup clutter
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false

-- Faster gitgutter updates
vim.opt.updatetime = 100

-- YAML-specific
vim.api.nvim_create_autocmd("FileType", {
  pattern = "yaml",
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
  end,
})

-- Keymaps
vim.keymap.set("n", "<Esc>", ":nohlsearch<CR>", { silent = true })
vim.keymap.set("n", "<C-p>", ":Files<CR>", { silent = true })

-- Autocompletion (nvim-cmp)
local cmp = require("cmp")
cmp.setup({
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "buffer" },
    { name = "path" },
  }),
  mapping = cmp.mapping.preset.insert({
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
  }),
})

-- LSP: yaml-language-server
vim.api.nvim_create_autocmd("FileType", {
  pattern = "yaml",
  callback = function()
    vim.lsp.start({
      name = "yaml-language-server",
      cmd = { "yaml-language-server", "--stdio" },
      root_dir = vim.fs.root(0, { ".git", "." }),
      capabilities = require("cmp_nvim_lsp").default_capabilities(),
      settings = {
        yaml = {
          schemas = {
            kubernetes = "/*.yaml",
          },
          schemaStore = { enable = true },
        },
      },
    })
  end,
})

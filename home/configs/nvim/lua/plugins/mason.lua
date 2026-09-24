-- Disable mason so LazyVim configures LSPs and runs formatters/linters from
-- PATH (nix-provided) instead of downloading its own copies. Both the old
-- williamboman and new mason-org plugin names are covered.
return {
  { "williamboman/mason.nvim", enabled = false },
  { "williamboman/mason-lspconfig.nvim", enabled = false },
  { "mason-org/mason.nvim", enabled = false },
  { "mason-org/mason-lspconfig.nvim", enabled = false },
  { "jay-babu/mason-nvim-dap.nvim", enabled = false },
}

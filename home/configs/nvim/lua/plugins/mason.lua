-- Disable mason so LazyVim configures LSPs and runs formatters/linters from
-- PATH (nix-provided) instead of downloading its own copies.
return {
  { "mason-org/mason.nvim", enabled = false },
  { "mason-org/mason-lspconfig.nvim", enabled = false },
  { "jay-babu/mason-nvim-dap.nvim", enabled = false },
}

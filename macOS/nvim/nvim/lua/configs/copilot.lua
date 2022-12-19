--------------------------------------------------------------------
--                      GITHUB COPILOT                            --
--------------------------------------------------------------------

if (vim.fn.exists('neovide') == 1) then
    vim.cmd([[imap <silent><script><expr> <C-Tab> copilot#Accept("")]]) -- <C-Tab> to accept - only in neovide
else
    vim.cmd([[imap <silent><script><expr> <C-x> copilot#Accept("")]]) -- <C-x> to accept
end

vim.g.copilot_no_tab_map = true

--------------------------------------------------------------------
--                       OMNISHARP                                --
--------------------------------------------------------------------

-- maps Tab to <C-x><C-o> for autocompletion using Omnisharp,
-- also lets you use Tab if the cursor is on a whitespace
-- vim.g.OmniSharp_server_stdio = 1
-- vim.g.OmniSharp_server_use_mono = 1
-- vim.cmd[[autocmd FileType cs inoremap <expr> <Tab> pumvisible() ? '<C-n>' : getline('.')[col('.')-2] =~# '[[:alnum:].-_#$]' ? '<C-x><C-o>' : '<Tab>']]

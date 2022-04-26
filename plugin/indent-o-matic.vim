command! IndentOMatic execute "lua require('indent-o-matic').detect()"

augroup indent_o_matic
    au!
    au BufReadPost * IndentOMatic
    " Run once when saving for new files
    au BufNew * au BufWritePost <buffer=abuf> ++once IndentOMatic
augroup END

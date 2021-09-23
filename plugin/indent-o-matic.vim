lua require 'indent-o-matic'

augroup indent_o_matic
    au!
    au BufReadPost * lua IndentOMatic()
    " Run once when saving for new files
    au BufNew * au BufWritePost <buffer=abuf> ++once lua IndentOMatic()
augroup END

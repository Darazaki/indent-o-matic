lua require 'indent-o-matic'

augroup indent_o_matic
    au!
    au BufReadPost * au BufEnter     <buffer=abuf> ++once lua IndentOMatic()
    au BufNewFile  * au BufWritePost <buffer=abuf> ++once lua IndentOMatic()
augroup END

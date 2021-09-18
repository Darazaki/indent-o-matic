lua require 'indent-o-matic'

augroup indent_o_matic
    au!
    au BufReadPost * au BufEnter     <buffer=abuf> lua indent_o_matic()
    au BufNewFile  * au BufWritePost <buffer=abuf> lua indent_o_matic()
augroup END

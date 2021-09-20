lua require 'indent-o-matic'

augroup indent_o_matic
    au!
    au BufReadPost * lua IndentOMatic()
augroup END

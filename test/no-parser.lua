-- Run from the repository root with Neovim:
-- nvim --headless -u NONE -i NONE -n -l test/no-parser.lua
vim.opt.runtimepath:prepend(vim.fn.getcwd())
vim.cmd('runtime plugin/indent-o-matic.vim')

local function reset(lines)
    vim.cmd('enew!')
    vim.bo.filetype = ''
    vim.bo.expandtab = false
    vim.bo.shiftwidth = 8
    vim.api.nvim_buf_set_lines(0, 0, -1, true, lines)
end

-- A plain buffer has no tree-sitter language/parser, but detection is still supported.
reset { 'first line', '    indented line' }
vim.cmd('IndentOMatic')
assert(vim.bo.expandtab and vim.bo.shiftwidth == 4)

-- Missing tree-sitter support must still allow Vim syntax to skip comments.
reset { '/*', '  comment', '*/', '    code' }
vim.bo.filetype = 'c'
vim.cmd('syntax on')
vim.cmd('setlocal syntax=c')
require('indent-o-matic').detect()
assert(vim.bo.expandtab and vim.bo.shiftwidth == 4)

print('No-parser detection and syntax fallback passed')
vim.cmd('qa!')

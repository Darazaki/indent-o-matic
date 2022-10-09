local indent_o_matic = {}
local preferences = {}

-- Treesitter includes
local parsers
local highlighter = require 'vim.treesitter.highlighter'
local has_ts_utils, ts_utils = pcall(require, 'nvim-treesitter.ts_utils')
if has_ts_utils then
    parsers = require 'nvim-treesitter.parsers'
else
    ts_utils = nil
end

has_ts_utils = nil

-- Get value of option
local function opt(name)
    return vim.api.nvim_buf_get_option(0, name)
end

-- Set value of option
local function setopt(name, value)
    return vim.api.nvim_buf_set_option(0, name, value)
end

-- Get a line's contents as a string (0-indexed)
local function line_at(index)
    return vim.api.nvim_buf_get_lines(0, index, index + 1, true)[1]
end

-- Search if a list has a specific value
-- This should be faster than a binary search for small lists
local function contains(list, value)
    for _, v in ipairs(list) do
        if value == v then
            return true
        end
    end

    return false
end

-- Get the configuration's value or its default if not set
local function config(config_key, default_value)
    -- Attempt to get filetype specific config if available
    local ft_preferences = preferences['filetype_' .. opt('filetype')]
    if type(ft_preferences) == 'table' then
        local value = ft_preferences[config_key]
        if value ~= nil then
            return value
        end
    end

    -- No filetype specific config, try the global one or fallback to default
    local value = preferences[config_key]
    if value == nil then
        value = default_value
    end

    return value
end

-- Detect default indentation values (0 for tabs, N for N spaces)
local function get_default_indent()
    if opt('expandtab') then
        -- If shiftwidth is 0, use tabstop (see: `:help shiftwidth`)
        local ident = opt('shiftwidth')
        if ident == 0 then
            ident = opt('tabstop')
        end
        return ident
    else
        return 0
    end
end

-- `is_multiline` variant based on Vim's syntax module
local function is_multiline_syn(line_number)
    -- Originally taken from leisiji's code:
    -- https://github.com/leisiji/indent-o-matic/blob/c440898e3e6bcc12c9c24d4867875712c4d1b5f7/lua/indent-o-matic.lua#L51-L57
    local syntax = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.synID(line_number, 1, 1)), 'name')
    return syntax == "Comment" or syntax == "String"
end

-- `is_multiline` variant based on Neovim's treesitter module
local function is_multiline_ts(line_number)
    print("using treesitter")

    -- Fallback, this should ideally never happen
    if ts_utils == nil then
        print("fallback to syntax")
        return is_multiline_syn(line_number)
    end

    local parsers = require('nvim-treesitter.parsers')
    local root_lang_tree = parsers.get_parser()
    if not root_lang_tree then
        print("no root_lang_tree")
        -- No syntax tree => no strings/comments
        return false
    end

    local root = ts_utils.get_root_for_position(line_number, 0, root_lang_tree)
    if not root then
        print("no root")
        -- No syntax tree on this line
        return false
    end

    local node = root:named_descendant_for_range(0, line_number, 0, line_number)
    local node_type = node:type()

    print(node_type)
    return node_type == 'comment' or node_type == 'string'
end

-- Detect if the line is a comment or a string
local function is_multiline(line_number)
    local buf = vim.api.nvim_get_current_buf()

    if highlighter.active[buf] then
        return is_multiline_ts(line_number)
    else
        return is_multiline_syn(line_number)
    end
end

-- Configure the plugin
function indent_o_matic.setup(options)
    if type(options) == 'table' then
        preferences = options
    else
        local msg = "Can't setup indent-o-matic, correct syntax is: "
        msg = msg .. "require('indent-o-matic').setup { ... }"
        error(msg)
    end
end

-- Attempt to detect current buffer's indentation and apply it to local settings
function indent_o_matic.detect()
    local default = get_default_indent()
    local detected = default

    -- Options
    local max_lines = config('max_lines', 2048)
    local standard_widths = config('standard_widths', { 2, 4, 8 })
    local skip_multiline = config('skip_multiline', true)

    -- Loop over every line, breaking once it finds something that looks like a
    -- standard indentation or if it reaches end of file
    local i = 0
    while i ~= max_lines do
        local first_char

        local ok, line = pcall(function() return line_at(i) end)
        if not ok then
            -- End of file
            break
        end

        -- Skip empty lines
        if #line == 0 then
            goto continue
        end

        -- If a line starts with a tab then the file must be tab indented
        -- else if it starts with spaces it tries to detect if it's the file's indentation
        first_char = line:sub(1, 1)
        if first_char == '\t' then
            -- Skip multi-line comments and strings (1-indexed)
            if skip_multiline and is_multiline(i + 1) then
                goto continue
            end

            detected = 0
            break
        elseif first_char == ' ' then
            -- Figure out the number of spaces used and if it should be the indentation
            local j = 2
            while j ~= #line and j < 10 do
                local c = line:sub(j, j)
                if c == '\t' then
                    -- Spaces and then a tab? WTF? Ignore this unholy line
                    goto continue
                elseif c ~= ' ' then
                    break
                end

                j = j + 1
            end

            -- If it's a standard number of spaces it's probably the file's indentation
            j = j - 1
            if contains(standard_widths, j) then
                -- Skip multi-line comments and strings (1-indexed)
                if skip_multiline and is_multiline(i + 1) then
                    goto continue
                end

                detected = j
                break
            end
        end

        -- "We have continue at home"
        ::continue::
        i = i + 1
    end

    if detected ~= default then
        if detected == 0 then
            setopt('expandtab', false)
        else
            setopt('expandtab', true)
            setopt('tabstop', detected)
            setopt('softtabstop', detected)
            setopt('shiftwidth', detected)
        end
    end
end

return indent_o_matic

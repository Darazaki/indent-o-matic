-- This is a high level nvim emulator that only implements the necessary APIs
-- Tree-sitter isn't currently supported

local vim = {
    api = {},
    fn = {},

    fake = {
        buf_options = {},
        ---@type string[]
        buf_lines = {},
    },
}

---@generic T
---@param x T
---@return T
local function dbg(x)
    if type(x) == "table" then
        print("TODO: got table")
    else
        print(x)
    end
    return x
end

---@param buf integer
local function expect_current_buf(buf)
    if buf ~= 0 and buf ~= vim.api.nvim_get_current_buf() then
        error("Wrong buffer")
    end
end

--- @param buffer integer
--- @param name string
--- @return any
function vim.api.nvim_buf_get_option(buffer, name)
    expect_current_buf(buffer)
    return vim.fake.buf_options[name]
end

--- @param buffer integer
--- @param name string
--- @param value any
function vim.api.nvim_buf_set_option(buffer, name, value)
    expect_current_buf(buffer)
    vim.fake.buf_options[name] = value
end

function vim.api.nvim_get_option_value(name, opts)
    expect_current_buf(opts.buf)
    return vim.fake.buf_options[name]
end

function vim.api.nvim_set_option_value(name, value, opts)
    expect_current_buf(opts.buf)
    vim.fake.buf_options[name] = value
end

---@param buffer integer
---@param start integer
---@param end_ integer
---@param strict_indexing boolean
---@return string[]
function vim.api.nvim_buf_get_lines(buffer, start, end_, strict_indexing)
    expect_current_buf(buffer)

    if strict_indexing ~= true then
        error("Strict indexing must be enabled")
    end

    local result = {}
    local i = start
    while i < end_ do
        local line = vim.fake.buf_lines[i + 1]
        if line == nil then
            error("Not a line")
        end
        table.insert(result, line)
        i = i + 1
    end

    return result
end

---@param lnum integer
---@param col integer
---@param trans integer
---@return table
function vim.fn.synID(lnum, col, trans)
    if trans ~= 1 then
        error("`trans` must be 1")
    end

    -- Comment represented by "#" at the end of line
    local line = vim.fake.buf_lines[lnum]
    local is_comment = line:sub(#line, #line) == "#"

    return { name = is_comment and "Comment" or "IDK" }
end

function vim.fn.synIDtrans(synID) return synID end

---@param synID table
---@param what string
---@return string
function vim.fn.synIDattr(synID, what) return synID[what] end

---@return integer
function vim.api.nvim_get_current_buf()
    -- Chosen by fair dice roll
    return 4
end

return vim

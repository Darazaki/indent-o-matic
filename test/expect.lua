-- Run indent-o-matic through the high-level nvim emulator
-- Usage: luajit expect.lua <filename>
--   <filename>: path to the file to test

local uutil = require ".uutil"

---@param filename string
---@return string[]
local function read_file(filename)
    local lines = {}
    for line in io.lines(filename) do
        table.insert(lines, line)
    end

    return lines
end

local function indent_for_file(filename)
    vim = dofile("./nvim-emulator.lua")
    vim.fake.buf_lines = read_file(filename)
    vim.fake.buf_options = {
        filetype = uutil.file_extension(filename),
        expandtab = true,
        softtabstop = 42,
        shiftwidth = 42,
        tabstop = 42,
    }

    local indent_o_matic = dofile("../lua/indent-o-matic.lua")
    indent_o_matic.setup {
        filetype_2or8 = {
            standard_widths = { 2, 8 },
        },
        filetype_3maxlines = {
            max_lines = 3,
        },
        filetype_disabled = {
            max_lines = 0,
        },
        filetype_noskip = {
            skip_multiline = false,
        },
    }
    indent_o_matic.detect()

    if not vim.fake.buf_options['expandtab'] then
        return 0
    else
        return vim.fake.buf_options['shiftwidth']
    end
end

local filename = arg[1] or error("Missing arg `filename`")
local expected_result = uutil.extract_expected_value(filename)

local ok, result = pcall(function() return indent_for_file(filename) end)
if ok then
    if result == expected_result then
        print("OK: " .. filename)
    else
        print("Fail: " .. filename .. " (expected " .. expected_result .. " got " .. result .. ")")
        os.exit(1)
    end
else
    print("Fail: " .. filename .. " (" .. result .. ")")
    os.exit(2)
end

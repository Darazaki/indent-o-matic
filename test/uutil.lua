local ffi = require "ffi"

local M = {}

ffi.cdef[[
    // Opaque
    typedef struct DIR DIR;

    typedef struct dirent {
        unsigned long _inode;
        unsigned long _useless_historical_artifact;
        unsigned short _record_length;
        unsigned char _type_except_when_its_not;
        char name[256];
    } dirent;
    
    DIR *opendir(const char *name);
    dirent *readdir(DIR *dirp);
    int closedir(DIR *dirp);
]]

---@param path string
---@return string[]
function M.ls(path)
    local results = {}
    local dir = ffi.C.opendir(path)
    if not dir then
        error("Could not open directory")
    end

    while true do
        local entry = ffi.C.readdir(dir)
        if entry == nil then
            break -- No more entries
        end

        local name = ffi.string(entry.name)

        -- Skip '.' and '..' (current and parent directory)
        if name ~= "." and name ~= ".." then
            table.insert(results, name)
        end
    end

    ffi.C.closedir(dir)
    return results
end

---@param filename string
---@return string
function M.file_extension(filename)
    local basename = filename:match("([^/\\]+)$") or filename
    local extension = basename:match("%.([^%.]+)$")
    return extension or ""
end

---@param filename string
---@return integer
function M.extract_expected_value(filename)
    local expected = -1
    for number in filename:gmatch("[.]%d+[.]") do
        expected = tonumber(number:sub(2, #number - 1)) or error("WTF?")
    end

    if expected == -1 then
        error("Missing expected value in " .. filename)
    end

    return expected
end

return M

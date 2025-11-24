local uutil = require ".uutil"

local failed = {}
local test_files = uutil.ls("data")
for _, local_filename in ipairs(test_files) do
    local filename = "data/" .. local_filename

    local command = ("luajit ./expect.lua '%s'"):format(filename)
    print("-----------------")
    print(command)
    local exit_code = os.execute(command)
    if exit_code ~= 0 then
        table.insert(failed, filename)
    end
end

print("-----------------")
if #failed == 0 then
    print("All test succeeded!")
else
    print(#failed .. " test(s) failed!")
    for _, filename in ipairs(failed) do
        print("  * " .. filename)
    end
end

os.exit(#failed)

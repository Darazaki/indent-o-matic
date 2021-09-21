-- Attempt to detect current buffer's indentation and apply it to local settings
function IndentOMatic()
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

    -- Detect default indentation values (0 for tabs, N for N spaces)
    local default = opt('expandtab') and opt('shiftwidth') or 0
    local detected = default

    -- Loop over every line, breaking once it finds something that looks like a
    -- standard indentation or if it reaches end of file
    local i = 0
    while true do
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
            detected = 0
            break
        elseif first_char == ' ' then
            -- Figure out the number of spaces used and if it should be the indentation
            local j = 2
            while j ~= #line and j < 10 do
                local c = line:sub(j, j)
                if c == '\t' then
                    -- Spaces and then a tab? WTF? Ignore this unholy line
                    j = 0
                    break
                elseif c ~= ' ' then
                    break
                end

                j = j + 1
            end

            -- If it's a standard number of spaces (2, 4 or 8) it's probably the file's
            -- indentation
            if j == 3 or j == 5 or j == 9 then
                detected = j - 1
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

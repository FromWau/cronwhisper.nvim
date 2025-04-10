local M = {}

function M.print(obj, indent)
    indent = indent or 0 -- Set default indentation to 0 if not provided
    local indentStr = string.rep("  ", indent) -- Create indentation string

    if type(obj) == "table" then
        print(indentStr .. "{")
        -- Iterate over all keys and values in the table
        for k, v in pairs(obj) do
            -- Handle nil keys and values
            if k == nil then
                io.write(indentStr .. "  [nil] = ")
            elseif type(k) == "string" then
                io.write(indentStr .. "  " .. k .. " = ")
            else
                io.write(indentStr .. "  [")
                M.print(k, indent + 1) -- Corrected recursive call to M.print for keys
                io.write(indentStr .. "] = ")
            end

            -- Handle nil values
            if v == nil then
                io.write(indentStr .. "  [nil]")
            elseif type(v) == "table" then
                M.print(v, indent + 1) -- Recursively print table values
            else
                print(indentStr .. tostring(v))
            end
        end
        print(indentStr .. "}")
    else
        -- If it's not a table, just print the value
        print(indentStr .. tostring(obj))
    end
end

---@param s string
function M.trim(s) return s:match "^%s*(.-)%s*$" end

---@param t table -- The table to join
---@param seperator string -- The separator to use between elements
---@return string -- Returns the joined string
function M.join(t, separator)
    local result = {}

    for _, i in pairs(t) do
        if i ~= "" then table.insert(result, i) end
    end

    return table.concat(result, separator)
end

return M

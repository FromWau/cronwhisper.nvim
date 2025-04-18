local M = {}

---@param str string -- The string to split
---@param sep string -- The separator to use for splitting
---returns table -- A table containing the split parts
function M.split(str, sep)
    sep = sep or "/"
    local result = {}

    if sep == "" then
        -- Edge case: splitting on empty string
        for i = 1, #str do
            result[i] = str:sub(i, i)
        end
        return result
    end

    local last_pos = 1
    local next_pos = 1

    while true do
        local start_pos, end_pos = string.find(str, sep, next_pos, true)
        if not start_pos then
            table.insert(result, str:sub(last_pos))
            break
        end
        table.insert(result, str:sub(last_pos, start_pos - 1))
        last_pos = end_pos + 1
        next_pos = end_pos + 1
    end

    -- If string ends with separator, add trailing empty part
    if str:sub(-#sep) == sep then table.insert(result, "") end

    return result
end

---@param s string
function M.trim(s) return s:match "^%s*(.-)%s*$" end

---@param t table -- The table to join
---@param separator string -- The separator to use between elements
---@return string -- Returns the joined string
function M.join(t, separator)
    local result = {}

    for _, i in pairs(t) do
        if i ~= "" then table.insert(result, i) end
    end

    return table.concat(result, separator)
end

return M

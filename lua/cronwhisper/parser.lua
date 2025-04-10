local M = {}

---@param line string -- The raw line from the crontab
---@return table      -- A table containing the parsed cron line
--- - error string:   An error message
--- - success string: The parsed cron expression
function M.parse_cron_line(line)
    local parts = {}

    if string.sub(line, 1, #"@") == "@" then
        local result = parse_special_commands(line)

        if result.success then line = result.success end

        if result.error then return { error = result.error } end
    end

    for word in line:gmatch "%S+" do
        table.insert(parts, word)
    end

    if #parts < 1 then return { error = "Missing <minute> [0-59]" } end
    if #parts < 2 then return { error = "Missing <hour> [0-23]" } end

    if parts[1] == "@reboot" then
        return { success = {
            reboot = true,
            command = table.concat(parts, " ", 2),
        } }
    end

    if #parts < 3 then return { error = "Missing <day_of_month> [1-31]" } end
    if #parts < 4 then return { error = "Missing <month> [1-12/JAN-DEC]" } end
    if #parts < 5 then return { error = "Missing <day_of_week> [0-7 (Sun, Mo, ..., Sun)/SUN-SAT]" } end
    if #parts < 6 then return { error = "Missing <command>" } end

    return {
        success = {
            minute = parts[1],
            hour = parts[2],
            day_of_month = parts[3],
            month = parts[4],
            day_of_week = parts[5],
            command = table.concat(parts, " ", 6),
        },
    }
end

---@param line string -- The raw line from the crontab
---@return table      -- A table containing either:
---  - `success` string: The parsed cron expression
---  - `error` string: An error message if the line is not a special command
function parse_special_commands(line)
    local words = {}
    for word in line:gmatch "%S+" do
        table.insert(words, word)
    end

    if words[2] == nil then return { error = "Missing <command>" } end

    local commands = {
        ["@yearly"] = "0 0 1 1 *",
        ["@annually"] = "0 0 1 1 *",
        ["@monthly"] = "0 0 1 * *",
        ["@weekly"] = "0 0 * * 0",
        ["@daily"] = "0 0 * * *",
        ["@hourly"] = "0 * * * *",
        ["@reboot"] = "@reboot",
    }

    local cmd = commands[words[1]]
    if cmd then
        return { success = "" .. cmd .. " " .. table.concat(words, " ", 2) }
    else
        return { error = "Unknown special command: " .. words[1] }
    end
end

return M

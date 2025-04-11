local M = {}

---@param line string -- The raw line from the crontab
---@return table      -- A table containing the parsed cron line
--- - error string:   An error message
--- - success table: The parsed cron expression
---   - reboot bool: If the cron line is a reboot command
---   - minute table: The parsed minute can either be `value`, `step`, `separator`, or `range`
---     - value string: The minute value
---     - step table: A table containing the parsed step value
---         - base string: The base value (e.g., "*")
---         - step number: The step value (e.g., "2")
---     - separator table: A table containing the parsed separator value
---     - range table: A table containing the parsed range value
---         - from number: The starting value (e.g., "1")
---         - to number: The ending value (e.g., "5")
---
---   - hour table: The parsed hour can either be `value`, `step`, `separator`, or `range`
---     - value string: The minute value
---     - step table: A table containing the parsed step value
---         - base string: The base value (e.g., "*")
---         - step number: The step value (e.g., "2")
---     - separator table: A table containing the parsed separator value
---     - range table: A table containing the parsed range value
---         - from number: The starting value (e.g., "1")
---         - to number: The ending value (e.g., "5")
---
---   - day_of_month table: The parsed day of month can either be `value`, `step`, `separator`, or `range`
---     - value string: The minute value
---     - step table: A table containing the parsed step value
---         - base string: The base value (e.g., "*")
---         - step number: The step value (e.g., "2")
---     - separator table: A table containing the parsed separator value
---     - range table: A table containing the parsed range value
---         - from number: The starting value (e.g., "1")
---         - to number: The ending value (e.g., "5")
---
---   - month table: The parsed month can either be `value`, `step`, `separator`, or `range`
---     - value string: The minute value
---     - step table: A table containing the parsed step value
---         - base string: The base value (e.g., "*")
---         - step number: The step value (e.g., "2")
---     - separator table: A table containing the parsed separator value
---     - range table: A table containing the parsed range value
---         - from number: The starting value (e.g., "1")
---         - to number: The ending value (e.g., "5")
---
---   - day_of_week table: The parsed day of week can either be `value`, `step`, `separator`, or `range`
---     - value string: The minute value
---     - step table: A table containing the parsed step value
---         - base string: The base value (e.g., "*")
---         - step number: The step value (e.g., "2")
---     - separator table: A table containing the parsed separator value
---     - range table: A table containing the parsed range value
---         - from number: The starting value (e.g., "1")
---         - to number: The ending value (e.g., "5")
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

    local result = check_actions(parts[1])
    if result.no_step then
    end
    if result.error then return { error = result.error } end
    local minute = result.success

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
            minute = minute,
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

---@param word string -- The word to check
---@return table -- A table containing actions `step`, `separator`, `range`, `error`, or `nothing`:
---  - error string: An error message if the word is not a valid step value
---  - nothing bool: If the word does not contain a action
---  - step table: A table containing the parsed step value
---    - base string: The base value (e.g., "*")
---    - step number: The step value (e.g., "2")
--- - separator table: A table containing the parsed separator value
--- - range table: A table containing the parsed range value
---    - from number: The starting value (e.g., "1")
---    - to number: The ending value (e.g., "5")
---
function check_actions(word)
    local result = check_step(word)
    if result == nil then print "No step value found" end
    if result.error then return { error = result.error } end

    if result.success then
        return {
            step = {
                base = result.success.base,
                step = result.success.step,
            },
        }
    end
end

function check_step(word)
    -- check for step
    local parts = {}
    for part in string.gmatch(word, "([^/]+)") do
        table.insert(parts, part)
    end

    if #parts == 0 then return nil end

    if #parts > 2 then return { error = "Invalid: Can not have multiple step values" } end

    if parts[1] ~= "*" then return { error = "Invalid: Step value must be preceded by a *" } end

    if type(parts[2]) ~= number then return { error = "Invalid: Step value must be a number" } end

    return {
        success = {
            base = parts[1],
            step = parts[2],
        },
    }
end

return M

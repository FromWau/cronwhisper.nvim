local pprint = require "PrettyPrint"
local utils = require "utils"
local validator = require "cronwhisper.validator"

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

    local result_min = check_actions(parts[1])
    if result_min.error then return { error = result_min.error } end

    local minute = nil
    if result_min.step or result_min.range or result_min.list then
        minute = result_min
    else
        minute = { value = parts[1] }
    end

    if parts[1] ~= "@reboot" then
        local validate_min = validator.validate_minute(minute)
        if not validate_min.valid then return { error = validate_min.error } end
    end

    if #parts < 2 then return { error = "Missing <hour> [0-23]" } end

    if parts[1] == "@reboot" then
        return { success = {
            reboot = true,
            command = table.concat(parts, " ", 2),
        } }
    end

    local result_hour = check_actions(parts[2])
    if result_hour.error then return { error = result_hour.error } end

    local hour = nil
    if result_hour.step or result_hour.range or result_hour.list then
        hour = result_hour
    else
        hour = { value = parts[2] }
    end

    local validate_hour = validator.validate_hour(hour)
    if not validate_hour.valid then return { error = validate_hour.error } end

    if #parts < 3 then return { error = "Missing <day_of_month> [1-31]" } end
    local result_day = check_actions(parts[3])
    if result_day.error then return { error = result_day.error } end

    local day_of_month = nil
    if result_day.step or result_day.range or result_day.list then
        day_of_month = result_day
    else
        day_of_month = { value = parts[3] }
    end

    local validate_day = validator.validate_day_of_month(day_of_month)
    if not validate_day.valid then return { error = validate_day.error } end

    if #parts < 4 then return { error = "Missing <month> [1-12/JAN-DEC]" } end
    local result_month = check_actions(parts[4])
    if result_month.error then return { error = result_month.error } end

    local month = nil
    if result_month.step or result_month.range or result_month.list then
        month = result_month
    else
        month = { value = parts[4] }
    end

    local validate_month = validator.validate_month(month)
    if not validate_month.valid then return { error = validate_month.error } end

    if #parts < 5 then return { error = "Missing <day_of_week> [0-7 (Sun, Mo, ..., Sun)/SUN-SAT]" } end
    local result_day_of_week = check_actions(parts[5])
    if result_day_of_week.error then return { error = result_day_of_week.error } end

    local day_of_week = nil
    if result_day_of_week.step or result_day_of_week.range or result_day_of_week.list then
        day_of_week = result_day_of_week
    else
        day_of_week = { value = parts[5] }
    end

    local validate_day_of_week = validator.validate_day_of_week(day_of_week)
    if not validate_day_of_week.valid then return { error = validate_day_of_week.error } end

    if #parts < 6 then return { error = "Missing <command>" } end

    return {
        success = {
            minute = minute,
            hour = hour,
            day_of_month = day_of_month,
            month = month,
            day_of_week = day_of_week,
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
    if word == "@reboot" then return { nothing = true } end

    -- Check for list values first (contains ,)
    local result_list = check_list(word)
    if result_list ~= nil then
        if result_list.error then return { error = result_list.error } end
        if result_list.success then return { list = result_list.success.items } end
    end

    -- Check for step values (contains /)
    local result_step = check_step(word)
    if result_step ~= nil then
        if result_step.error then return { error = result_step.error } end
        if result_step.success then
            return {
                step = {
                    base = result_step.success.base,
                    step = result_step.success.step,
                },
            }
        end
    end

    -- Check for range values (contains -)
    local result_range = check_range(word)
    if result_range ~= nil then
        if result_range.error then return { error = result_range.error } end
        if result_range.success then
            return {
                range = {
                    from = result_range.success.from,
                    to = result_range.success.to,
                },
            }
        end
    end

    return { nothing = true }
end

---@param word string -- The word to check
---@return table | nil -- nil or table containing:
--- - error string: An error message if the word is not a valid step value
--- - success table: The parsed step value
---   - base string: The base value (e.g., "*" or "10-50" or "MON-FRI")
---   - step number: The step value (e.g., "2")
function check_step(word)
    -- check for step
    local parts = utils.split(word, "/")

    if #parts == 1 then return nil end

    if #parts > 2 then return { error = "Invalid: Can not have multiple step values" } end

    -- Base can be "*" or a range like "10-50" or "MON-FRI"
    local base = parts[1]
    if base ~= "*" and not base:match "-" then return { error = "Invalid: Step value must be preceded by a * or a range" } end

    local step = tonumber(parts[2])
    if not step then return { error = "Invalid: Step value must be a number" } end

    return {
        success = {
            base = base,
            step = parts[2],
        },
    }
end

---@param word string -- The word to check
---@return table | nil -- nil or table containing:
--- - error string: An error message if the word is not a valid range value
--- - success table: The parsed range value
---   - from string: The starting value (e.g., "1" or "MON")
---   - to string: The ending value (e.g., "5" or "FRI")
function check_range(word)
    -- check for range (contains -)
    -- Don't treat as range if it starts with - (negative number)
    if word:sub(1, 1) == "-" then return nil end

    local parts = utils.split(word, "-")

    if #parts == 1 then return nil end

    if #parts > 2 then return { error = "Invalid: Can not have multiple ranges" } end

    local from = parts[1]
    local to = parts[2]

    if from == "" or to == "" then return { error = "Invalid: Range must have both start and end values" } end

    -- Check if both are numeric for validation
    local from_num = tonumber(from)
    local to_num = tonumber(to)

    -- If both are numbers, validate that from <= to
    if from_num and to_num then
        if from_num > to_num then return { error = "Invalid: Range start must be less than or equal to end" } end
    end

    return {
        success = {
            from = from,
            to = to,
        },
    }
end

---@param word string -- The word to check
---@return table | nil -- nil or table containing:
--- - error string: An error message if the word is not a valid list value
--- - success table: The parsed list value
---   - items table: Array of list items (e.g., {"1", "3", "5"} or {"MON", "WED", "FRI"})
function check_list(word)
    -- check for list (contains ,)
    local parts = utils.split(word, ",")

    if #parts == 1 then return nil end

    -- Check for empty values in the list
    for _, part in ipairs(parts) do
        if part == "" then return { error = "Invalid: List contains empty values" } end
    end

    return {
        success = {
            items = parts,
        },
    }
end

return M

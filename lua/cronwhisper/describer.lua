local utils = require "utils"

local M = {}

---@param obj table -- The table containing the parsed cron line
---@return string -- A string describing the cron line
function M.describe(obj)
    if next(obj) == nil then return "Nothing to describe" end

    -- Not valid if command is not set
    if obj["command"] == nil then return "Missing <command>" end

    -- Reboot command
    if obj["reboot"] then return "After rebooting" end

    -- Check for remaining fields
    if obj["minute"] == nil then return "Missing <minute> [1-59]" end
    if obj["hour"] == nil then return "Missing <hour> [0-23]" end
    if obj["day_of_month"] == nil then return "Missing <day_of_month> [1-31]" end
    if obj["month"] == nil then return "Missing <month> [1-12/JAN-DEC]" end
    if obj["day_of_week"] == nil then return "Missing <day_of_week> [0-7(Sun, Mo, ..., Sun)/SUN-SAT]" end

    local minute = obj["minute"]
    local hour = obj["hour"]
    local day_of_month = obj["day_of_month"]
    local month = obj["month"]
    local day_of_week = obj["day_of_week"]

    local desc = {}
    table.insert(desc, describe_time(minute, hour))
    table.insert(desc, describe_day(day_of_month, day_of_week))
    table.insert(desc, describe_month(month))

    return utils.join(desc, " ")
end

---@param minute table -- The minute field object
---@param hour table -- The hour field object
---@return string -- A string describing the time
function describe_time(minute, hour)
    local minute_desc = describe_minute(minute)
    local hour_desc = describe_hour(hour)

    -- Both wildcards
    if minute.value == "*" and hour.value == "*" then return "At every minute" end

    -- Minute has specifics, hour is wildcard
    if minute_desc and hour.value == "*" then return minute_desc end

    -- Hour has specifics, minute is wildcard
    if minute.value == "*" and hour_desc then return "At every minute past " .. hour_desc end

    -- Both have specifics - check if it's a simple time
    if minute.value and hour.value and minute.value ~= "*" and hour.value ~= "*" then
        return string.format("At %02d:%02d", tonumber(hour.value), tonumber(minute.value))
    end

    -- Complex combination
    if minute_desc and hour_desc then return minute_desc .. " past " .. hour_desc end

    return "At " .. (minute_desc or "every minute") .. " past " .. (hour_desc or "every hour")
end

---@param minute table -- The minute field object
---@return string | nil -- Description of minute or nil
function describe_minute(minute)
    if minute.value == "*" then return nil end

    if minute.value then return "At minute " .. minute.value end

    if minute.step then
        if minute.step.base == "*" then
            return "At every " .. minute.step.step .. " minutes"
        else
            -- Range-based step
            local from, to = parse_range_values(minute.step.base)
            return "At every " .. minute.step.step .. " minutes from " .. from .. " through " .. to
        end
    end

    if minute.range then return "At every minute from " .. minute.range.from .. " through " .. minute.range.to end

    if minute.list then
        local items = format_list(minute.list)
        return "At minutes " .. items
    end

    return nil
end

---@param hour table -- The hour field object
---@return string | nil -- Description of hour or nil
function describe_hour(hour)
    if hour.value == "*" then return nil end

    if hour.value then return "hour " .. hour.value end

    if hour.step then
        if hour.step.base == "*" then
            return "every " .. hour.step.step .. " hours"
        else
            -- Range-based step
            local from, to = parse_range_values(hour.step.base)
            return "every " .. hour.step.step .. " hours from " .. from .. " through " .. to
        end
    end

    if hour.range then return "every hour from " .. hour.range.from .. " through " .. hour.range.to end

    if hour.list then
        local items = format_list(hour.list)
        return "hours " .. items
    end

    return nil
end

---@param day_of_month table -- The day of month field object
---@param day_of_week table -- The day of week field object
---@return string -- A string describing the day
function describe_day(day_of_month, day_of_week)
    local dom_desc = describe_day_of_month(day_of_month)
    local dow_desc = describe_day_of_week(day_of_week)

    if dom_desc and dow_desc then return "on " .. dom_desc .. " and " .. dow_desc end

    if dom_desc then return "on " .. dom_desc end

    if dow_desc then return "on " .. dow_desc end

    return ""
end

---@param day_of_month table -- The day of month field object
---@return string | nil -- Description or nil
function describe_day_of_month(day_of_month)
    if day_of_month.value == "*" then return nil end

    if day_of_month.value then return "day-of-month " .. day_of_month.value end

    if day_of_month.step then
        if day_of_month.step.base == "*" then
            return "every " .. day_of_month.step.step .. " days"
        else
            local from, to = parse_range_values(day_of_month.step.base)
            return "every " .. day_of_month.step.step .. " days from " .. from .. " through " .. to
        end
    end

    if day_of_month.range then
        return "every day-of-month from " .. day_of_month.range.from .. " through " .. day_of_month.range.to
    end

    if day_of_month.list then
        local items = format_list(day_of_month.list)
        return "day-of-month " .. items
    end

    return nil
end

---@param day_of_week table -- The day of week field object
---@return string | nil -- Description or nil
function describe_day_of_week(day_of_week)
    if day_of_week.value == "*" then return nil end

    if day_of_week.value then
        local day_name = convert_day_to_name(day_of_week.value)
        return day_name
    end

    if day_of_week.step then
        if day_of_week.step.base == "*" then
            return "every " .. day_of_week.step.step .. " days-of-week"
        else
            local from, to = parse_range_values(day_of_week.step.base)
            local from_name = convert_day_to_name(from)
            local to_name = convert_day_to_name(to)
            return "every " .. day_of_week.step.step .. " days-of-week from " .. from_name .. " through " .. to_name
        end
    end

    if day_of_week.range then
        local from_name = convert_day_to_name(day_of_week.range.from)
        local to_name = convert_day_to_name(day_of_week.range.to)
        return "every day-of-week from " .. from_name .. " through " .. to_name
    end

    if day_of_week.list then
        local named_list = {}
        for _, item in ipairs(day_of_week.list) do
            table.insert(named_list, convert_day_to_name(item))
        end
        local items = format_list(named_list)
        return items
    end

    return nil
end

---@param month table -- The month field object
---@return string -- Description of month or empty string
function describe_month(month)
    if month.value == "*" then return "" end

    if month.value then
        local month_name = convert_month_to_name(month.value)
        return "in " .. month_name
    end

    if month.step then
        if month.step.base == "*" then
            return "every " .. month.step.step .. " months"
        else
            local from, to = parse_range_values(month.step.base)
            local from_name = convert_month_to_name(from)
            local to_name = convert_month_to_name(to)
            return "every " .. month.step.step .. " months from " .. from_name .. " through " .. to_name
        end
    end

    if month.range then
        local from_name = convert_month_to_name(month.range.from)
        local to_name = convert_month_to_name(month.range.to)
        return "in every month from " .. from_name .. " through " .. to_name
    end

    if month.list then
        local named_list = {}
        for _, item in ipairs(month.list) do
            table.insert(named_list, convert_month_to_name(item))
        end
        local items = format_list(named_list)
        return "in " .. items
    end

    return ""
end

---@param value string -- Numeric or name value
---@return string -- Day name
function convert_day_to_name(value)
    local week_day = {
        [0] = "Sunday",
        [1] = "Monday",
        [2] = "Tuesday",
        [3] = "Wednesday",
        [4] = "Thursday",
        [5] = "Friday",
        [6] = "Saturday",
        [7] = "Sunday",
        ["SUN"] = "Sunday",
        ["MON"] = "Monday",
        ["TUE"] = "Tuesday",
        ["WED"] = "Wednesday",
        ["THU"] = "Thursday",
        ["FRI"] = "Friday",
        ["SAT"] = "Saturday",
    }

    local num = tonumber(value)
    if num then return week_day[num] end

    return week_day[value:upper()] or value
end

---@param value string -- Numeric or name value
---@return string -- Month name
function convert_month_to_name(value)
    local month_name = {
        [1] = "January",
        [2] = "February",
        [3] = "March",
        [4] = "April",
        [5] = "May",
        [6] = "June",
        [7] = "July",
        [8] = "August",
        [9] = "September",
        [10] = "October",
        [11] = "November",
        [12] = "December",
        ["JAN"] = "January",
        ["FEB"] = "February",
        ["MAR"] = "March",
        ["APR"] = "April",
        ["MAY"] = "May",
        ["JUN"] = "June",
        ["JUL"] = "July",
        ["AUG"] = "August",
        ["SEP"] = "September",
        ["OCT"] = "October",
        ["NOV"] = "November",
        ["DEC"] = "December",
    }

    local num = tonumber(value)
    if num then return month_name[num] end

    return month_name[value:upper()] or value
end

---@param range_str string -- Range string like "10-50" or "MON-FRI"
---@return string, string -- from and to values
function parse_range_values(range_str)
    local parts = {}
    for part in range_str:gmatch "[^-]+" do
        table.insert(parts, part)
    end
    return parts[1] or "", parts[2] or ""
end

---@param list table -- List of items
---@return string -- Formatted list like "1, 2, and 3"
function format_list(list)
    if #list == 1 then return list[1] end

    if #list == 2 then return list[1] .. " and " .. list[2] end

    local result = {}
    for i = 1, #list - 1 do
        table.insert(result, list[i])
    end

    return table.concat(result, ", ") .. ", and " .. list[#list]
end

return M

local utils = require "utils"

local M = {}

---@param obj table             -- The tavle containing the parsed cron line
---  - `command` (string):      The command to be executed
---  - `reboot` (boolean):      Indicates if the command is a reboot command
---  - `minute` (string):       The minute field of the cron expression
---  - `hour` (string):         The hour field of the cron expression
---  - `day_of_month` (string): The day of the month field of the cron expression
---  - `moanth` (string):       The month field of the cron expression
---  - `day_of_week` (string):  The day of the week field of the cron expression
---@return string --            A string describing the cron line
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

    -- Validate fields
    if minute ~= "*" then
        minute = tonumber(minute)
        if minute < 0 or minute > 59 then return "Invalid minute must be between 0 to 59" end
    end
    if hour ~= "*" then
        hour = tonumber(hour)
        if hour < 0 or hour > 23 then return "Invalid hour must be between 0 to 23" end
    end

    if day_of_month ~= "*" then
        day_of_month = tonumber(day_of_month)
        if day_of_month < 1 or day_of_month > 31 then return "Invalid day_of_month must be between 1 to 31" end
    end

    if month ~= "*" then
        if month:match "^%a+$" then
            month = string.upper(month)
            local month_name = {
                ["JAN"] = 1,
                ["FEB"] = 2,
                ["MAR"] = 3,
                ["APR"] = 4,
                ["MAY"] = 5,
                ["JUN"] = 6,
                ["JUL"] = 7,
                ["AUG"] = 8,
                ["SEP"] = 9,
                ["OCT"] = 10,
                ["NOV"] = 11,
                ["DEC"] = 12,
            }
            month = month_name[month]
            if month == nil then month = -1 end
        end
        month = tonumber(month)
        if month < 1 or month > 12 then return "Invalid month must be between 1 to 12 or JAN to DEC" end
    end

    if day_of_week ~= "*" then
        if day_of_week:match "^%a+$" then
            day_of_week = string.upper(day_of_week)
            local week_day = {
                ["SUN"] = 0,
                ["MON"] = 1,
                ["TUE"] = 2,
                ["WED"] = 3,
                ["THU"] = 4,
                ["FRI"] = 5,
                ["SAT"] = 6,
            }
            day_of_week = week_day[day_of_week]
            if day_of_week == nil then day_of_week = -1 end
        end
        day_of_week = tonumber(day_of_week)
        if day_of_week < 0 or day_of_week > 7 then return "Invalid day_of_week must be between 0 to 7 or SUN to SAT" end
    end

    local desc = {}
    table.insert(desc, describe_time(minute, hour))
    table.insert(desc, describe_day(day_of_month, day_of_week))
    table.insert(desc, describe_month(month))

    return utils.join(desc, " ")
end

---@param minute string -- The minute field of the cron expression
---@param hour string   -- The hour field of the cron expression
---@return string -- A string describing the time
function describe_time(minute, hour)
    if minute == "*" and hour == "*" then return "At every minute" end

    if minute ~= "*" and hour == "*" then return "At minute " .. minute end

    if minute == "*" and hour ~= "*" then return "At every minute past hour " .. hour end

    if minute ~= "*" and hour ~= "*" then return "At " .. string.format("%02d:%02d", hour, minute) end
end

---@param day_of_month string -- The day of the month field of the cron expression
---@param day_of_week string  -- The day of the week field of the cron expression
---@return string -- A string describing the day
function describe_day(day_of_month, day_of_week)
    local desc = {}
    table.insert(desc, describe_day_of_month(day_of_month))
    table.insert(desc, describe_day_of_week(day_of_week))
    return utils.join(desc, " and ")
end

---@param day_of_month string -- The day of the month field of the cron expression
---@return string -- A string describing the day of the month
function describe_day_of_month(day_of_month)
    if day_of_month == "*" then return "" end

    if day_of_month ~= "*" then return "on day-of-month " .. day_of_month end
end

---@param day_of_week string -- The day of the week field of the cron expression
---@return string -- A string describing the day of the week
function describe_day_of_week(day_of_week)
    if day_of_week == "*" then return "" end

    local week_day = {
        [0] = "Sunday",
        [1] = "Monday",
        [2] = "Tuesday",
        [3] = "Wednesday",
        [4] = "Thursday",
        [5] = "Friday",
        [6] = "Saturday",
        [7] = "Sunday",
    }

    if day_of_week ~= "*" then
        day_of_week = week_day[day_of_week]
        return "on " .. day_of_week
    end
end

---@param month string -- The month field of the cron expression
---@return string -- A string describing the month
function describe_month(month)
    if month == "*" then return "" end

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
    }

    if month ~= "*" then
        month = month_name[month]
        return "in " .. month
    end
end

return M

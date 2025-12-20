local pprint = require "PrettyPrint"

local M = {}

---@param minute table: The parsed minute can either be `value`, `step`, `separator`, or `range`
--- - value string: The minute value
--- - step table: A table containing the parsed step value
---     - base string: The base value (e.g., "*")
---     - step number: The step value (e.g., "2")
--- - separator table: A table containing the parsed separator value
--- - range table: A table containing the parsed range value
---     - from number: The starting value (e.g., "1")
---     - to number: The ending value (e.g., "5")
---@return table: A table containing the validation result
function M.validate_minute(minute)
    local valid = true
    local error_message = ""

    if type(minute) ~= "table" then
        valid = false
        error_message = "Invalid minute format. Expected a table."
    end

    if minute.value ~= nil then
        if minute.value == "*" then return { valid = true } end

        local number = tonumber(minute.value)
        if not number then
            valid = false
            error_message = "Invalid minute value. Expected a number."
        elseif number < 0 or number > 59 then
            valid = false
            error_message = "Invalid minute value. Must be between 0 and 59."
        end
    end

    if minute.step ~= nil then
        local number = tonumber(minute.step.step)
        if not number then
            valid = false
            error_message = "Invalid step value. Expected a number."
            return { valid = false, error = error_message }
        end

        -- Validate the base (can be "*" or a range like "10-50")
        if minute.step.base ~= "*" then
            -- Must be a range
            if not minute.step.base:match "-" then
                valid = false
                error_message = "Invalid step base. Expected '*' or a range."
                return { valid = false, error = error_message }
            end

            -- Validate the range in the base
            local parts = {}
            for part in minute.step.base:gmatch "[^-]+" do
                table.insert(parts, part)
            end

            local from_num = tonumber(parts[1])
            local to_num = tonumber(parts[2])

            if not from_num or from_num < 0 or from_num > 59 then
                valid = false
                error_message = "Invalid step base range. 'from' value must be between 0 and 59."
                return { valid = false, error = error_message }
            end

            if not to_num or to_num < 0 or to_num > 59 then
                valid = false
                error_message = "Invalid step base range. 'to' value must be between 0 and 59."
                return { valid = false, error = error_message }
            end
        end
    end

    if minute.range ~= nil then
        local from_num = tonumber(minute.range.from)
        local to_num = tonumber(minute.range.to)

        if not from_num then
            valid = false
            error_message = "Invalid minute range 'from' value. Expected a number."
            return { valid = false, error = error_message }
        end

        if not to_num then
            valid = false
            error_message = "Invalid minute range 'to' value. Expected a number."
            return { valid = false, error = error_message }
        end

        if from_num < 0 or from_num > 59 then
            valid = false
            error_message = "Invalid minute range 'from' value. Must be between 0 and 59."
            return { valid = false, error = error_message }
        end

        if to_num < 0 or to_num > 59 then
            valid = false
            error_message = "Invalid minute range 'to' value. Must be between 0 and 59."
            return { valid = false, error = error_message }
        end
    end

    if minute.list ~= nil then
        -- Validate each item in the list
        for _, item in ipairs(minute.list) do
            -- Check if item is a range
            if item:match "-" and item:sub(1, 1) ~= "-" then
                local parts = {}
                for part in item:gmatch "[^-]+" do
                    table.insert(parts, part)
                end
                local from_num = tonumber(parts[1])
                local to_num = tonumber(parts[2])

                if not from_num or from_num < 0 or from_num > 59 then
                    valid = false
                    error_message = "Invalid minute list item '" .. item .. "'. Must be between 0 and 59."
                    return { valid = false, error = error_message }
                end

                if not to_num or to_num < 0 or to_num > 59 then
                    valid = false
                    error_message = "Invalid minute list item '" .. item .. "'. Must be between 0 and 59."
                    return { valid = false, error = error_message }
                end
            else
                -- Simple value
                local number = tonumber(item)
                if not number then
                    valid = false
                    error_message = "Invalid minute list item '" .. item .. "'. Expected a number."
                    return { valid = false, error = error_message }
                end

                if number < 0 or number > 59 then
                    valid = false
                    error_message = "Invalid minute list item '" .. item .. "'. Must be between 0 and 59."
                    return { valid = false, error = error_message }
                end
            end
        end
    end

    return { valid = valid, error = error_message }
end

---@param hour table: The parsed hour can either be `value`, `step`, `separator`, or `range`
--- - value string: The hour value
--- - step table: A table containing the parsed step value
---     - base string: The base value (e.g., "*")
---     - step number: The step value (e.g., "2")
--- - separator table: A table containing the parsed separator value
--- - range table: A table containing the parsed range value
---     - from number: The starting value (e.g., "1")
---     - to number: The ending value (e.g., "5")
---@return table: A table containing the validation result
function M.validate_hour(hour)
    local valid = true
    local error_message = ""

    if type(hour) ~= "table" then
        valid = false
        error_message = "Invalid hour format. Expected a table."
    end

    if hour.value ~= nil then
        if hour.value == "*" then return { valid = true } end

        local number = tonumber(hour.value)
        if not number then
            valid = false
            error_message = "Invalid hour value. Expected a number."
        elseif number < 0 or number > 23 then
            valid = false
            error_message = "Invalid hour value. Must be between 0 and 23."
        end
    end

    if hour.step ~= nil then
        local number = tonumber(hour.step.step)
        if not number then
            valid = false
            error_message = "Invalid step value. Expected a number."
            return { valid = false, error = error_message }
        end

        -- Validate the base (can be "*" or a range like "9-17")
        if hour.step.base ~= "*" then
            -- Must be a range
            if not hour.step.base:match "-" then
                valid = false
                error_message = "Invalid step base. Expected '*' or a range."
                return { valid = false, error = error_message }
            end

            -- Validate the range in the base
            local parts = {}
            for part in hour.step.base:gmatch "[^-]+" do
                table.insert(parts, part)
            end

            local from_num = tonumber(parts[1])
            local to_num = tonumber(parts[2])

            if not from_num or from_num < 0 or from_num > 23 then
                valid = false
                error_message = "Invalid step base range. 'from' value must be between 0 and 23."
                return { valid = false, error = error_message }
            end

            if not to_num or to_num < 0 or to_num > 23 then
                valid = false
                error_message = "Invalid step base range. 'to' value must be between 0 and 23."
                return { valid = false, error = error_message }
            end
        end
    end

    if hour.range ~= nil then
        local from_num = tonumber(hour.range.from)
        local to_num = tonumber(hour.range.to)

        if not from_num then
            valid = false
            error_message = "Invalid hour range 'from' value. Expected a number."
            return { valid = false, error = error_message }
        end

        if not to_num then
            valid = false
            error_message = "Invalid hour range 'to' value. Expected a number."
            return { valid = false, error = error_message }
        end

        if from_num < 0 or from_num > 23 then
            valid = false
            error_message = "Invalid hour range 'from' value. Must be between 0 and 23."
            return { valid = false, error = error_message }
        end

        if to_num < 0 or to_num > 23 then
            valid = false
            error_message = "Invalid hour range 'to' value. Must be between 0 and 23."
            return { valid = false, error = error_message }
        end
    end

    return { valid = valid, error = error_message }
end

---@param day_of_month table: The parsed day_of_month can either be `value`, `step`, `separator`, or `range`
--- - value string: The day_of_month value
--- - step table: A table containing the parsed step value
---     - base string: The base value (e.g., "*")
---     - step number: The step value (e.g., "2")
--- - separator table: A table containing the parsed separator value
--- - range table: A table containing the parsed range value
---     - from number: The starting value (e.g., "1")
---     - to number: The ending value (e.g., "5")
---@return table: A table containing the validation result
function M.validate_day_of_month(day_of_month)
    local valid = true
    local error_message = ""

    if type(day_of_month) ~= "table" then
        valid = false
        error_message = "Invalid day_of_month format. Expected a table."
    end

    if day_of_month.value ~= nil then
        if day_of_month.value == "*" then return { valid = true } end

        local number = tonumber(day_of_month.value)
        if not number then
            valid = false
            error_message = "Invalid day_of_month value. Expected a number."
        elseif number < 1 or number > 31 then
            valid = false
            error_message = "Invalid day_of_month value. Must be between 1 and 31."
        end
    end

    if day_of_month.step ~= nil then
        if day_of_month.step.base ~= "*" then
            valid = false
            error_message = "Invalid step base. Expected '*'."
            return { valid = false, error = error_message }
        end

        local number = tonumber(day_of_month.step.step)
        if not number then
            valid = false
            error_message = "Invalid step value. Expected a number."
        end
    end

    if day_of_month.range ~= nil then
        local from_num = tonumber(day_of_month.range.from)
        local to_num = tonumber(day_of_month.range.to)

        if not from_num then
            valid = false
            error_message = "Invalid day_of_month range 'from' value. Expected a number."
            return { valid = false, error = error_message }
        end

        if not to_num then
            valid = false
            error_message = "Invalid day_of_month range 'to' value. Expected a number."
            return { valid = false, error = error_message }
        end

        if from_num < 1 or from_num > 31 then
            valid = false
            error_message = "Invalid day_of_month range 'from' value. Must be between 1 and 31."
            return { valid = false, error = error_message }
        end

        if to_num < 1 or to_num > 31 then
            valid = false
            error_message = "Invalid day_of_month range 'to' value. Must be between 1 and 31."
            return { valid = false, error = error_message }
        end
    end

    return { valid = valid, error = error_message }
end

---@param month table: The parsed month can either be `value`, `step`, `separator`, or `range`
--- - value string: The month value
--- - step table: A table containing the parsed step value
---     - base string: The base value (e.g., "*")
---     - step number: The step value (e.g., "2")
--- - separator table: A table containing the parsed separator value
--- - range table: A table containing the parsed range value
---     - from number: The starting value (e.g., "1")
---     - to number: The ending value (e.g., "5")
---@return table: A table containing the validation result
function M.validate_month(month)
    local valid = true
    local error_message = ""

    if type(month) ~= "table" then
        valid = false
        error_message = "Invalid month format. Expected a table."
    end

    if month.value ~= nil then
        if month.value == "*" then return { valid = true } end

        local number = tonumber(month.value)
        if number then
            if number < 1 or number > 12 then
                valid = false
                error_message = "Invalid month value. Must be between 1 and 12."
                return { valid = false, error = error_message }
            end
            return { valid = true }
        end

        local str = tostring(month.value)
        if str then
            local month_names = {
                JAN = 1,
                FEB = 2,
                MAR = 3,
                APR = 4,
                MAY = 5,
                JUN = 6,
                JUL = 7,
                AUG = 8,
                SEP = 9,
                OCT = 10,
                NOV = 11,
                DEC = 12,
            }

            local x = month_names[str:upper()]
            if not x then
                valid = false
                error_message = "Invalid month value. Expected a number or a valid month name."
                return { valid = false, error = error_message }
            end
        end

        if not str and not number then
            valid = false
            error_message = "Invalid month value. Expected a number or a valid month name."
        end
    end

    if month.step ~= nil then
        if month.step.base ~= "*" then
            valid = false
            error_message = "Invalid step base. Expected '*'."
            return { valid = false, error = error_message }
        end

        local number = tonumber(month.step.step)
        if not number then
            valid = false
            error_message = "Invalid step value. Expected a number."
        end
    end

    if month.range ~= nil then
        local month_names = {
            JAN = 1,
            FEB = 2,
            MAR = 3,
            APR = 4,
            MAY = 5,
            JUN = 6,
            JUL = 7,
            AUG = 8,
            SEP = 9,
            OCT = 10,
            NOV = 11,
            DEC = 12,
        }

        local from_num = tonumber(month.range.from)
        local to_num = tonumber(month.range.to)

        -- Try to convert month names to numbers
        if not from_num then from_num = month_names[tostring(month.range.from):upper()] end

        if not to_num then to_num = month_names[tostring(month.range.to):upper()] end

        if not from_num then
            valid = false
            error_message = "Invalid month range 'from' value. Expected a number or valid month name."
            return { valid = false, error = error_message }
        end

        if not to_num then
            valid = false
            error_message = "Invalid month range 'to' value. Expected a number or valid month name."
            return { valid = false, error = error_message }
        end

        if from_num < 1 or from_num > 12 then
            valid = false
            error_message = "Invalid month range 'from' value. Must be between 1 and 12."
            return { valid = false, error = error_message }
        end

        if to_num < 1 or to_num > 12 then
            valid = false
            error_message = "Invalid month range 'to' value. Must be between 1 and 12."
            return { valid = false, error = error_message }
        end
    end

    return { valid = valid, error = error_message }
end

---@param day_of_week table: The parsed day_of_week can either be `value`, `step`, `separator`, or `range`
--- - value string: The day_of_week value
--- - step table: A table containing the parsed step value
---     - base string: The base value (e.g., "*")
---     - step number: The step value (e.g., "2")
--- - separator table: A table containing the parsed separator value
--- - range table: A table containing the parsed range value
---     - from number: The starting value (e.g., "1")
---     - to number: The ending value (e.g., "5")
---@return table: A table containing the validation result
function M.validate_day_of_week(day_of_week)
    local valid = true
    local error_message = ""

    if type(day_of_week) ~= "table" then
        valid = false
        error_message = "Invalid day_of_week format. Expected a table."
    end

    if day_of_week.value ~= nil then
        if day_of_week.value == "*" then return { valid = true } end

        local number = tonumber(day_of_week.value)
        if number then
            if number < 0 or number > 7 then
                valid = false
                error_message = "Invalid day_of_week value. Must be between 0 and 7 or a valid week name."
                return { valid = false, error = error_message }
            end
            return { valid = true }
        end

        local str = tostring(day_of_week.value)
        if str then
            local day_of_week_names = {
                SUN = 0,
                MON = 1,
                TUE = 2,
                WED = 3,
                THU = 4,
                FRI = 5,
                SAT = 6,
                SUN = 7,
            }

            local x = day_of_week_names[str:upper()]
            if not x then
                valid = false
                error_message = "Invalid day_of_week value. Expected a number or a valid day_of_week name."
                return { valid = false, error = error_message }
            end
        end

        if not str and not number then
            valid = false
            error_message = "Invalid day_of_week value. Expected a number or a valid day_of_week name."
        end
    end

    if day_of_week.step ~= nil then
        local number = tonumber(day_of_week.step.step)
        if not number then
            valid = false
            error_message = "Invalid step value. Expected a number."
            return { valid = false, error = error_message }
        end

        -- Validate the base (can be "*" or a range like "MON-FRI" or "1-5")
        if day_of_week.step.base ~= "*" then
            -- Must be a range
            if not day_of_week.step.base:match "-" then
                valid = false
                error_message = "Invalid step base. Expected '*' or a range."
                return { valid = false, error = error_message }
            end

            -- Validate the range in the base
            local day_of_week_names = {
                SUN = 0,
                MON = 1,
                TUE = 2,
                WED = 3,
                THU = 4,
                FRI = 5,
                SAT = 6,
            }

            local parts = {}
            for part in day_of_week.step.base:gmatch "[^-]+" do
                table.insert(parts, part)
            end

            local from_num = tonumber(parts[1])
            local to_num = tonumber(parts[2])

            -- Try to convert day names to numbers
            if not from_num then from_num = day_of_week_names[tostring(parts[1]):upper()] end

            if not to_num then to_num = day_of_week_names[tostring(parts[2]):upper()] end

            if not from_num or from_num < 0 or from_num > 7 then
                valid = false
                error_message = "Invalid step base range. 'from' value must be between 0 and 7 or a valid day name."
                return { valid = false, error = error_message }
            end

            if not to_num or to_num < 0 or to_num > 7 then
                valid = false
                error_message = "Invalid step base range. 'to' value must be between 0 and 7 or a valid day name."
                return { valid = false, error = error_message }
            end
        end
    end

    if day_of_week.range ~= nil then
        local day_of_week_names = {
            SUN = 0,
            MON = 1,
            TUE = 2,
            WED = 3,
            THU = 4,
            FRI = 5,
            SAT = 6,
        }

        local from_num = tonumber(day_of_week.range.from)
        local to_num = tonumber(day_of_week.range.to)

        -- Try to convert day names to numbers
        if not from_num then from_num = day_of_week_names[tostring(day_of_week.range.from):upper()] end

        if not to_num then to_num = day_of_week_names[tostring(day_of_week.range.to):upper()] end

        if not from_num then
            valid = false
            error_message = "Invalid day_of_week range 'from' value. Expected a number or valid day name."
            return { valid = false, error = error_message }
        end

        if not to_num then
            valid = false
            error_message = "Invalid day_of_week range 'to' value. Expected a number or valid day name."
            return { valid = false, error = error_message }
        end

        -- Both 0 and 7 represent Sunday, so they're valid
        if from_num < 0 or from_num > 7 then
            valid = false
            error_message = "Invalid day_of_week range 'from' value. Must be between 0 and 7."
            return { valid = false, error = error_message }
        end

        if to_num < 0 or to_num > 7 then
            valid = false
            error_message = "Invalid day_of_week range 'to' value. Must be between 0 and 7."
            return { valid = false, error = error_message }
        end
    end

    return { valid = valid, error = error_message }
end

return M

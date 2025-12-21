---@diagnostic disable: undefined-field
local parser = require "cronwhisper.parser"
local describer = require "cronwhisper.describer"
local pprint = require "PrettyPrint"

describe("Parse minute", function()
    it("ok", function()
        local line = "1 * * * * do_something.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)
    end)

    it("negative", function()
        local line = "-1 * * * * do_something.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)

        local error = parsed.error
        assert.is_equal("Invalid minute must be between 0 to 59", error)
    end)

    it("too high", function()
        local line = "61 * * * * do_something.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)

        local error = parsed.error
        assert.is_equal("Invalid minute must be between 0 to 59", error)
    end)
end)

describe("Parse hour", function()
    it("ok", function()
        local line = "* 13 * * * do_something.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)
    end)

    it("negative", function()
        local line = "* -1 * * * do_something.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)

        local error = parsed.error
        assert.is_equal("Invalid hour must be between 0 to 23", error)
    end)

    it("too high", function()
        local line = "* 25 * * * * do_something.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)

        local error = parsed.error
        assert.is_equal("Invalid hour must be between 0 to 23", error)
    end)
end)

describe("Parse day of month", function()
    it("ok", function()
        local line = "* * 30 * * do_something.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_equal("30", success.day_of_month.value)
    end)

    it("negative", function()
        local line = "* * -1 * * do_something.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)

        local error = parsed.error
        assert.is_equal("Invalid day_of_month must be between 1 to 31", error)
    end)

    it("too high", function()
        local line = "* * 32 * * do_something.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)

        local error = parsed.error
        assert.is_equal("Invalid day_of_month must be between 1 to 31", error)
    end)
end)

describe("Parse month", function()
    it("ok number", function()
        local line = "* * * 12 * do_something.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_equal("12", success.month.value)
    end)

    it("ok name", function()
        local line = "* * * dEc * do_something.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_equal("dEc", success.month.value)
    end)

    it("negative", function()
        local line = "* * * -1 * do_something.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)

        local error = parsed.error
        assert.is_equal("Invalid month must be between 1 to 12 or JAN to DEC", error)
    end)

    it("too high", function()
        local line = "* * * 13 * do_something.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)

        local error = parsed.error
        assert.is_equal("Invalid month must be between 1 to 12 or JAN to DEC", error)
    end)
end)

describe("Parse day_of_week", function()
    it("ok number", function()
        local line = "* * * * 5 do_something.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_equal("5", success.day_of_week.value)
    end)

    it("ok name", function()
        local line = "* * * * wed do_something.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_equal("wed", success.day_of_week.value)
    end)

    it("negative", function()
        local line = "* * * * -1 do_something.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)

        local error = parsed.error
        assert.is_equal("Invalid day_of_week value. Must be between 0 and 7 or a valid week name.", error)
    end)

    it("too high", function()
        local line = "* * * * 8 do_something.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)

        local error = parsed.error
        assert.is_equal("Invalid day_of_week value. Must be between 0 and 7 or a valid week name.", error)
    end)
end)

describe("Parse special commands", function()
    it("Parse reboot", function()
        local line = "@reboot do_something.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_not_nil(success.reboot)
        assert.is_true(success.reboot)
        assert.is_not_nil(success.command)
        assert.is_equal("do_something.sh", success.command)
    end)

    it("Parse reboot without command", function()
        local line = "@reboot"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.success)
        assert.is_not_nil(parsed.error)

        local error = parsed.error
        assert.is_equal("Missing <command>", error)
    end)

    it("Unknown special command", function()
        local line = "@invalid do_something.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.success)
        assert.is_not_nil(parsed.error)

        local error = parsed.error
        assert.is_equal("Unknown special command: @invalid", error)
    end)

    it("Parse yearly", function()
        local line = "@yearly do_something.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_equal("0", success.minute.value)
        assert.is_equal("0", success.hour.value)
        assert.is_equal("1", success.day_of_month.value)
        assert.is_equal("1", success.month.value)
        assert.is_equal("*", success.day_of_week.value)
        assert.is_equal("do_something.sh", success.command)
    end)

    it("Parse annually", function()
        local line = "@annually do_something.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_equal("0", success.minute.value)
        assert.is_equal("0", success.hour.value)
        assert.is_equal("1", success.day_of_month.value)
        assert.is_equal("1", success.month.value)
        assert.is_equal("*", success.day_of_week.value)
        assert.is_equal("do_something.sh", success.command)
    end)

    it("Parse monthly", function()
        local line = "@monthly do_something.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_equal("0", success.minute.value)
        assert.is_equal("0", success.hour.value)
        assert.is_equal("1", success.day_of_month.value)
        assert.is_equal("*", success.month.value)
        assert.is_equal("*", success.day_of_week.value)
        assert.is_equal("do_something.sh", success.command)
    end)

    it("Parse weekly", function()
        local line = "@weekly do_something.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_equal("0", success.minute.value)
        assert.is_equal("0", success.hour.value)
        assert.is_equal("*", success.day_of_month.value)
        assert.is_equal("*", success.month.value)
        assert.is_equal("0", success.day_of_week.value)
        assert.is_equal("do_something.sh", success.command)
    end)

    it("Parse daily", function()
        local line = "@daily do_something.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_equal("0", success.minute.value)
        assert.is_equal("0", success.hour.value)
        assert.is_equal("*", success.day_of_month.value)
        assert.is_equal("*", success.month.value)
        assert.is_equal("*", success.day_of_week.value)
        assert.is_equal("do_something.sh", success.command)
    end)

    it("Parse hourly", function()
        local line = "@hourly do_something.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_equal("0", success.minute.value)
        assert.is_equal("*", success.hour.value)
        assert.is_equal("*", success.day_of_month.value)
        assert.is_equal("*", success.month.value)
        assert.is_equal("*", success.day_of_week.value)
        assert.is_equal("do_something.sh", success.command)
    end)
end)

describe("Parse step", function()
    it("minute step", function()
        local line = "*/2 * * * * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_equal("*", success.minute.step.base)
        assert.is_equal("2", success.minute.step.step)
        assert.is_equal("*", success.hour.value)
        assert.is_equal("*", success.day_of_month.value)
        assert.is_equal("*", success.month.value)
        assert.is_equal("*", success.day_of_week.value)
        assert.is_equal("some_command.sh", success.command)
    end)

    it("minute step base not *", function()
        local line = "1/2 * * * * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)

        local error = parsed.error
        assert.is_equal("Invalid: Step value must be preceded by a * or a range", error)
    end)

    it("minute step base not set", function()
        local line = "/2 * * * * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)

        local error = parsed.error
        assert.is_equal("Invalid: Step value must be preceded by a * or a range", error)
    end)

    it("minute step multiple steps", function()
        local line = "*/2/3 * * * * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)

        local error = parsed.error
        assert.is_equal("Invalid: Can not have multiple step values", error)
    end)

    it("hour step", function()
        local line = "* */2 * * * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_equal("*", success.minute.value)
        assert.is_equal("*", success.hour.step.base)
        assert.is_equal("2", success.hour.step.step)
        assert.is_equal("*", success.day_of_month.value)
        assert.is_equal("*", success.month.value)
        assert.is_equal("*", success.day_of_week.value)
        assert.is_equal("some_command.sh", success.command)
    end)

    it("hour step base not *", function()
        local line = "* 1/2 * * * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)

        local error = parsed.error
        assert.is_equal("Invalid: Step value must be preceded by a * or a range", error)
    end)

    it("hour step base not set", function()
        local line = "* /2 * * * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)

        local error = parsed.error
        assert.is_equal("Invalid: Step value must be preceded by a * or a range", error)
    end)

    it("hour step multiple steps", function()
        local line = "* */2/3 * * * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)

        local error = parsed.error
        assert.is_equal("Invalid: Can not have multiple step values", error)
    end)

    it("day_of_month step", function()
        local line = "* * */2 * * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_equal("*", success.minute.value)
        assert.is_equal("*", success.hour.value)
        assert.is_equal("*", success.day_of_month.step.base)
        assert.is_equal("2", success.day_of_month.step.step)
        assert.is_equal("*", success.month.value)
        assert.is_equal("*", success.day_of_week.value)
        assert.is_equal("some_command.sh", success.command)
    end)

    it("day_of_month step base not *", function()
        local line = "* * 1/2 * * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)

        local error = parsed.error
        assert.is_equal("Invalid: Step value must be preceded by a * or a range", error)
    end)

    it("day_of_month step base not set", function()
        local line = "* * /2 * * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)

        local error = parsed.error
        assert.is_equal("Invalid: Step value must be preceded by a * or a range", error)
    end)

    it("day_of_month step multiple steps", function()
        local line = "* * */2/3 * * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)

        local error = parsed.error
        assert.is_equal("Invalid: Can not have multiple step values", error)
    end)

    it("month step", function()
        local line = "* * * */2 * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_equal("*", success.minute.value)
        assert.is_equal("*", success.hour.value)
        assert.is_equal("*", success.day_of_month.value)
        assert.is_equal("*", success.month.step.base)
        assert.is_equal("2", success.month.step.step)
        assert.is_equal("*", success.day_of_week.value)
        assert.is_equal("some_command.sh", success.command)
    end)

    it("month step base not *", function()
        local line = "* * * 1/2 * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)

        local error = parsed.error
        assert.is_equal("Invalid: Step value must be preceded by a * or a range", error)
    end)

    it("month step base not set", function()
        local line = "* * * /2 * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)

        local error = parsed.error
        assert.is_equal("Invalid: Step value must be preceded by a * or a range", error)
    end)

    it("month step multiple steps", function()
        local line = "* * * */2/3 * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)

        local error = parsed.error
        assert.is_equal("Invalid: Can not have multiple step values", error)
    end)

    it("day_of_week step", function()
        local line = "* * * * */2 some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_equal("*", success.minute.value)
        assert.is_equal("*", success.hour.value)
        assert.is_equal("*", success.day_of_month.value)
        assert.is_equal("*", success.month.value)
        assert.is_equal("*", success.day_of_week.step.base)
        assert.is_equal("2", success.day_of_week.step.step)
        assert.is_equal("some_command.sh", success.command)
    end)

    it("day_of_week step base not *", function()
        local line = "* * * * 1/2 some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)

        local error = parsed.error
        assert.is_equal("Invalid: Step value must be preceded by a * or a range", error)
    end)

    it("day_of_week step base not set", function()
        local line = "* * * * /2 some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)

        local error = parsed.error
        assert.is_equal("Invalid: Step value must be preceded by a * or a range", error)
    end)

    it("day_of_week step multiple steps", function()
        local line = "* * * * */2/3 some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)

        local error = parsed.error
        assert.is_equal("Invalid: Can not have multiple step values", error)
    end)
end)

describe("Parse range", function()
    it("minute range", function()
        local line = "1-5 * * * * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_not_nil(success.minute.range)
        assert.is_equal("1", success.minute.range.from)
        assert.is_equal("5", success.minute.range.to)
        assert.is_equal("*", success.hour.value)
        assert.is_equal("some_command.sh", success.command)
    end)

    it("hour range", function()
        local line = "* 9-17 * * * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_equal("*", success.minute.value)
        assert.is_not_nil(success.hour.range)
        assert.is_equal("9", success.hour.range.from)
        assert.is_equal("17", success.hour.range.to)
    end)

    it("day_of_month range", function()
        local line = "* * 1-15 * * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_not_nil(success.day_of_month.range)
        assert.is_equal("1", success.day_of_month.range.from)
        assert.is_equal("15", success.day_of_month.range.to)
    end)

    it("month range numeric", function()
        local line = "* * * 1-6 * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_not_nil(success.month.range)
        assert.is_equal("1", success.month.range.from)
        assert.is_equal("6", success.month.range.to)
    end)

    it("month range named", function()
        local line = "* * * JAN-JUN * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_not_nil(success.month.range)
        assert.is_equal("JAN", success.month.range.from)
        assert.is_equal("JUN", success.month.range.to)
    end)

    it("day_of_week range numeric", function()
        local line = "* * * * 1-5 some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_not_nil(success.day_of_week.range)
        assert.is_equal("1", success.day_of_week.range.from)
        assert.is_equal("5", success.day_of_week.range.to)
    end)

    it("day_of_week range named", function()
        local line = "* * * * MON-FRI some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_not_nil(success.day_of_week.range)
        assert.is_equal("MON", success.day_of_week.range.from)
        assert.is_equal("FRI", success.day_of_week.range.to)
    end)

    it("invalid range - reversed", function()
        local line = "5-1 * * * * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)

        local error = parsed.error
        assert.is_equal("Invalid: Range start must be less than or equal to end", error)
    end)

    it("invalid range - same value", function()
        local line = "5-5 * * * * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_not_nil(success.minute.range)
        assert.is_equal("5", success.minute.range.from)
        assert.is_equal("5", success.minute.range.to)
    end)

    it("invalid range - out of bounds minute", function()
        local line = "50-70 * * * * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)
    end)
end)

describe("Parse list/separator", function()
    it("minute list", function()
        local line = "0,15,30,45 * * * * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_not_nil(success.minute.list)
        assert.is_equal(4, #success.minute.list)
        assert.is_equal("0", success.minute.list[1])
        assert.is_equal("15", success.minute.list[2])
        assert.is_equal("30", success.minute.list[3])
        assert.is_equal("45", success.minute.list[4])
    end)

    it("hour list", function()
        local line = "* 9,12,15,18 * * * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_not_nil(success.hour.list)
        assert.is_equal(4, #success.hour.list)
    end)

    it("day_of_week list named", function()
        local line = "* * * * MON,WED,FRI some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_not_nil(success.day_of_week.list)
        assert.is_equal(3, #success.day_of_week.list)
        assert.is_equal("MON", success.day_of_week.list[1])
        assert.is_equal("WED", success.day_of_week.list[2])
        assert.is_equal("FRI", success.day_of_week.list[3])
    end)

    it("month list mixed", function()
        local line = "* * * 1,JUN,12 * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_not_nil(success.month.list)
        assert.is_equal("1", success.month.list[1])
        assert.is_equal("JUN", success.month.list[2])
        assert.is_equal("12", success.month.list[3])
    end)

    it("single value not a list", function()
        local line = "5 * * * * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_nil(success.minute.list)
        assert.is_not_nil(success.minute.value)
        assert.is_equal("5", success.minute.value)
    end)

    it("list with ranges", function()
        local line = "1-5,10,15-20 * * * * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_not_nil(success.minute.list)
        assert.is_equal(3, #success.minute.list)
        assert.is_equal("1-5", success.minute.list[1])
        assert.is_equal("10", success.minute.list[2])
        assert.is_equal("15-20", success.minute.list[3])
    end)

    it("invalid list - empty value", function()
        local line = "1,,5 * * * * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)

        local error = parsed.error
        assert.is_equal("Invalid: List contains empty values", error)
    end)

    it("invalid list - trailing comma", function()
        local line = "1,5, * * * * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)

        local error = parsed.error
        assert.is_equal("Invalid: List contains empty values", error)
    end)
end)

describe("Parse advanced steps", function()
    it("minute range step", function()
        local line = "10-50/5 * * * * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_not_nil(success.minute.step)
        assert.is_equal("10-50", success.minute.step.base)
        assert.is_equal("5", success.minute.step.step)
    end)

    it("hour range step", function()
        local line = "* 9-17/2 * * * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_not_nil(success.hour.step)
        assert.is_equal("9-17", success.hour.step.base)
        assert.is_equal("2", success.hour.step.step)
    end)

    it("day_of_week range step named", function()
        local line = "* * * * MON-FRI/2 some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_not_nil(success.day_of_week.step)
        assert.is_equal("MON-FRI", success.day_of_week.step.base)
        assert.is_equal("2", success.day_of_week.step.step)
    end)
end)

describe("Describe step fields", function()
    it("every 5 minutes", function()
        local line = "*/5 * * * * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        local desc = describer.describe(parsed.success)
        assert.is_equal("At every 5 minutes", desc)
    end)

    it("every 2 hours", function()
        local line = "0 */2 * * * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        local desc = describer.describe(parsed.success)
        assert.is_equal("At minute 0 past every 2 hours", desc)
    end)

    it("every 5 minutes from 10 through 50", function()
        local line = "10-50/5 * * * * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        local desc = describer.describe(parsed.success)
        assert.is_equal("At every 5 minutes from 10 through 50", desc)
    end)
end)

describe("Describe range fields", function()
    it("minutes 1 through 5", function()
        local line = "1-5 * * * * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        local desc = describer.describe(parsed.success)
        assert.is_equal("At every minute from 1 through 5", desc)
    end)

    it("hours 9 through 17", function()
        local line = "0 9-17 * * * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        local desc = describer.describe(parsed.success)
        assert.is_equal("At minute 0 past every hour from 9 through 17", desc)
    end)

    it("Monday through Friday", function()
        local line = "0 9 * * MON-FRI some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        local desc = describer.describe(parsed.success)
        assert.is_equal("At 09:00 on every day-of-week from Monday through Friday", desc)
    end)
end)

describe("Describe list fields", function()
    it("at minutes 0, 15, 30, and 45", function()
        local line = "0,15,30,45 * * * * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        local desc = describer.describe(parsed.success)
        assert.is_equal("At minutes 0, 15, 30, and 45", desc)
    end)

    it("on Monday, Wednesday, and Friday", function()
        local line = "0 9 * * MON,WED,FRI some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        local desc = describer.describe(parsed.success)
        assert.is_equal("At 09:00 on Monday, Wednesday, and Friday", desc)
    end)
end)

describe("Complex feature combinations", function()
    -- Lists with ranges
    it("list containing ranges - minutes", function()
        local line = "0-10,20-30,45,50-59 * * * * cmd.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_not_nil(success.minute.list)
        assert.is_equal(4, #success.minute.list)
        assert.is_equal("0-10", success.minute.list[1])
        assert.is_equal("20-30", success.minute.list[2])
        assert.is_equal("45", success.minute.list[3])
        assert.is_equal("50-59", success.minute.list[4])
    end)

    it("list with mixed numeric and named months", function()
        local line = "0 0 1 1,MAR,6,SEP,12 * cmd.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_not_nil(success.month.list)
        assert.is_equal("1", success.month.list[1])
        assert.is_equal("MAR", success.month.list[2])
        assert.is_equal("6", success.month.list[3])
        assert.is_equal("SEP", success.month.list[4])
    end)

    it("list with ranges in day of week", function()
        local line = "0 9 * * MON-WED,FRI,SAT-SUN cmd.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_not_nil(success.day_of_week.list)
        assert.is_equal(3, #success.day_of_week.list)
    end)

    -- Multiple fields with complex patterns
    it("step in minutes and range in hours", function()
        local line = "*/15 9-17 * * * cmd.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_not_nil(success.minute.step)
        assert.is_equal("*", success.minute.step.base)
        assert.is_equal("15", success.minute.step.step)
        assert.is_not_nil(success.hour.range)
        assert.is_equal("9", success.hour.range.from)
        assert.is_equal("17", success.hour.range.to)
    end)

    it("range step in minutes, list in hours", function()
        local line = "0-30/5 8,12,16,20 * * * cmd.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_not_nil(success.minute.step)
        assert.is_equal("0-30", success.minute.step.base)
        assert.is_not_nil(success.hour.list)
        assert.is_equal(4, #success.hour.list)
    end)

    it("all fields with different complex patterns", function()
        local line = "*/10 8-18/2 1-15 JAN,JUL MON-FRI cmd.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_not_nil(success.minute.step)
        assert.is_not_nil(success.hour.step)
        assert.is_not_nil(success.day_of_month.range)
        assert.is_not_nil(success.month.list)
        assert.is_not_nil(success.day_of_week.range)
    end)
end)

describe("Real-world cron examples", function()
    it("backup every day at 2:30 AM", function()
        local line = "30 2 * * * /usr/bin/backup.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local desc = describer.describe(parsed.success)
        assert.is_equal("At 02:30", desc)
    end)

    it("cleanup every 6 hours", function()
        local line = "0 */6 * * * /usr/bin/cleanup.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)

        local desc = describer.describe(parsed.success)
        assert.is_equal("At minute 0 past every 6 hours", desc)
    end)

    it("business hours monitoring - every 5 min Mon-Fri 9am-5pm", function()
        local line = "*/5 9-17 * * MON-FRI /usr/bin/monitor.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_not_nil(success.minute.step)
        assert.is_not_nil(success.hour.range)
        assert.is_not_nil(success.day_of_week.range)
    end)

    it("quarterly report - first day of Jan, Apr, Jul, Oct", function()
        local line = "0 0 1 JAN,APR,JUL,OCT * /usr/bin/quarterly.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_equal("0", success.minute.value)
        assert.is_equal("0", success.hour.value)
        assert.is_equal("1", success.day_of_month.value)
        assert.is_not_nil(success.month.list)
    end)

    it("weekend batch job - 3am on Sat and Sun", function()
        local line = "0 3 * * SAT,SUN /usr/bin/batch.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)

        local success = parsed.success
        assert.is_not_nil(success.day_of_week.list)
        assert.is_equal(2, #success.day_of_week.list)
    end)

    it("office hours - every 15 min 8am-6pm weekdays", function()
        local line = "*/15 8-18 * * 1-5 /usr/bin/office.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)
    end)

    it("first and fifteenth of month", function()
        local line = "0 9 1,15 * * /usr/bin/payroll.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)

        local success = parsed.success
        assert.is_not_nil(success.day_of_month.list)
        assert.is_equal("1", success.day_of_month.list[1])
        assert.is_equal("15", success.day_of_month.list[2])
    end)

    it("every 2 hours during business days", function()
        local line = "0 8-18/2 * * MON-FRI /usr/bin/sync.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)

        local success = parsed.success
        assert.is_not_nil(success.hour.step)
        assert.is_equal("8-18", success.hour.step.base)
        assert.is_equal("2", success.hour.step.step)
    end)

    it("maintenance window - weeknights 11pm-5am every 30 min", function()
        local line = "*/30 23,0-5 * * MON-FRI /usr/bin/maint.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)
    end)
end)

describe("Edge cases and boundaries", function()
    it("midnight exactly", function()
        local line = "0 0 * * * cmd.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)

        local desc = describer.describe(parsed.success)
        assert.is_equal("At 00:00", desc)
    end)

    it("last minute of day", function()
        local line = "59 23 * * * cmd.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_equal("23", parsed.success.hour.value)
        assert.is_equal("59", parsed.success.minute.value)
    end)

    it("last day of month", function()
        local line = "0 0 31 * * cmd.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_equal("31", parsed.success.day_of_month.value)
    end)

    it("December range", function()
        local line = "0 0 * 11-12 * cmd.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)

        local success = parsed.success
        assert.is_not_nil(success.month.range)
        assert.is_equal("11", success.month.range.from)
        assert.is_equal("12", success.month.range.to)
    end)

    it("Sunday as 0", function()
        local line = "0 0 * * 0 cmd.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_equal("0", parsed.success.day_of_week.value)
    end)

    it("Sunday as 7", function()
        local line = "0 0 * * 7 cmd.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_equal("7", parsed.success.day_of_week.value)
    end)

    it("range wrapping Sunday (0-1 means Sun-Mon)", function()
        local line = "0 0 * * 0-1 cmd.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)

        local success = parsed.success
        assert.is_not_nil(success.day_of_week.range)
        assert.is_equal("0", success.day_of_week.range.from)
        assert.is_equal("1", success.day_of_week.range.to)
    end)

    it("every minute", function()
        local line = "* * * * * cmd.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)

        local desc = describer.describe(parsed.success)
        assert.is_equal("At every minute", desc)
    end)

    it("minimum step - every 1 minute", function()
        local line = "*/1 * * * * cmd.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)

        local success = parsed.success
        assert.is_not_nil(success.minute.step)
        assert.is_equal("1", success.minute.step.step)
    end)

    it("maximum step - every 59 minutes", function()
        local line = "*/59 * * * * cmd.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)

        local success = parsed.success
        assert.is_equal("59", success.minute.step.step)
    end)

    it("single value in list", function()
        local line = "5 * * * * cmd.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)

        local success = parsed.success
        assert.is_nil(success.minute.list)
        assert.is_not_nil(success.minute.value)
    end)

    it("range of same value", function()
        local line = "5-5 * * * * cmd.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)

        local success = parsed.success
        assert.is_not_nil(success.minute.range)
        assert.is_equal("5", success.minute.range.from)
        assert.is_equal("5", success.minute.range.to)
    end)

    it("full range - all minutes", function()
        local line = "0-59 * * * * cmd.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)

        local success = parsed.success
        assert.is_not_nil(success.minute.range)
        assert.is_equal("0", success.minute.range.from)
        assert.is_equal("59", success.minute.range.to)
    end)

    it("full range - all hours", function()
        local line = "0 0-23 * * * cmd.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)

        local success = parsed.success
        assert.is_not_nil(success.hour.range)
    end)

    it("full range - all days of month", function()
        local line = "0 0 1-31 * * cmd.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)

        local success = parsed.success
        assert.is_not_nil(success.day_of_month.range)
    end)

    it("all months as range", function()
        local line = "0 0 1 JAN-DEC * cmd.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)

        local success = parsed.success
        assert.is_not_nil(success.month.range)
    end)

    it("all weekdays", function()
        local line = "0 0 * * MON-FRI cmd.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)

        local success = parsed.success
        assert.is_not_nil(success.day_of_week.range)
    end)
end)

describe("Error cases and validation", function()
    it("minute out of range - too high", function()
        local line = "60 * * * * cmd.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)
    end)

    it("hour out of range - too high", function()
        local line = "0 24 * * * cmd.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)
    end)

    it("day of month zero", function()
        local line = "0 0 0 * * cmd.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)
    end)

    it("day of month too high", function()
        local line = "0 0 32 * * cmd.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)
    end)

    it("month zero", function()
        local line = "0 0 1 0 * cmd.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)
    end)

    it("month too high", function()
        local line = "0 0 1 13 * cmd.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)
    end)

    it("day of week too high", function()
        local line = "0 0 * * 8 cmd.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)
    end)

    it("invalid month name", function()
        local line = "0 0 1 XYZ * cmd.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)
    end)

    it("invalid day name", function()
        local line = "0 0 * * XYZ cmd.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)
    end)

    it("range with from > to", function()
        local line = "50-10 * * * * cmd.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)
        assert.is_equal("Invalid: Range start must be less than or equal to end", parsed.error)
    end)

    it("list with empty value", function()
        local line = "1,,5 * * * * cmd.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_equal("Invalid: List contains empty values", parsed.error)
    end)

    it("list with trailing comma", function()
        local line = "1,5, * * * * cmd.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_equal("Invalid: List contains empty values", parsed.error)
    end)

    it("range in list with invalid values", function()
        local line = "1-70,5 * * * * cmd.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)
    end)

    it("step with invalid base", function()
        local line = "5/10 * * * * cmd.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_equal("Invalid: Step value must be preceded by a * or a range", parsed.error)
    end)

    it("too few fields", function()
        local line = "* * * * cmd.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)
    end)
end)

describe("Describe time", function()
    it("nil", function()
        local cron = {}
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("Nothing to describe", desc)
    end)
--
    it("minute ok", function()
        local cron = {
            minute = { value = "0" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "*" },
            day_of_week = { value = "*" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At minute 0", desc)
    end)
--
    it("minute nok", function()
        local cron = {
            minute = { value = "69" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "*" },
            day_of_week = { value = "*" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("Invalid minute must be between 0 to 59", desc)
    end)
--
    it("hour ok", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "12" },
            day_of_month = { value = "*" },
            month = { value = "*" },
            day_of_week = { value = "*" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute past hour 12", desc)
    end)
--
    it("hour nok", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "42" },
            day_of_month = { value = "*" },
            month = { value = "*" },
            day_of_week = { value = "*" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("Invalid hour must be between 0 to 23", desc)
    end)
--
    it("time ok", function()
        local cron = {
            minute = { value = "0" },
            hour = { value = "12" },
            day_of_month = { value = "*" },
            month = { value = "*" },
            day_of_week = { value = "*" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At 12:00", desc)
    end)
end)
--
describe("Describe day of month", function()
    it("day_of_month ok", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "1" },
            month = { value = "*" },
            day_of_week = { value = "*" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute on day-of-month 1", desc)
    end)
--
    it("day_of_month nok", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "32" },
            month = { value = "*" },
            day_of_week = { value = "*" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("Invalid day_of_month must be between 1 to 31", desc)
    end)
end)
--
describe("Describe day_of_week", function()
    it("day_of_week monday number", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "*" },
            day_of_week = { value = "1" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute on Monday", desc)
    end)
--
    it("day_of_week monday", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "*" },
            day_of_week = { value = "MON" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute on Monday", desc)
    end)
--
    it("day_of_week tuesday number", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "*" },
            day_of_week = { value = "2" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute on Tuesday", desc)
    end)
--
    it("day_of_week tuesday", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "*" },
            day_of_week = { value = "tue" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute on Tuesday", desc)
    end)
--
    it("day_of_week wednesday number", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "*" },
            day_of_week = { value = "3" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute on Wednesday", desc)
    end)
--
    it("day_of_week wednesday", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "*" },
            day_of_week = { value = "wed" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute on Wednesday", desc)
    end)
--
    it("day_of_week thursday number", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "*" },
            day_of_week = { value = "4" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute on Thursday", desc)
    end)
--
    it("day_of_week thursday", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "*" },
            day_of_week = { value = "thu" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute on Thursday", desc)
    end)
--
    it("day_of_week friday number", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "*" },
            day_of_week = { value = "5" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute on Friday", desc)
    end)
--
    it("day_of_week friday", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "*" },
            day_of_week = { value = "Fri" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute on Friday", desc)
    end)
--
    it("day_of_week saturday number", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "*" },
            day_of_week = { value = "6" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute on Saturday", desc)
    end)
--
    it("day_of_week saturday", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "*" },
            day_of_week = { value = "sat" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute on Saturday", desc)
    end)
--
    it("day_of_week sunday number special", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "*" },
            day_of_week = { value = "7" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute on Sunday", desc)
    end)
--
    it("day_of_week sunday number", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "*" },
            day_of_week = { value = "0" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute on Sunday", desc)
    end)
--
    it("day_of_week sunday", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "*" },
            day_of_week = { value = "sun" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute on Sunday", desc)
    end)
end)
--
describe("Describe month", function()
    it("month january number", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "1" },
            day_of_week = { value = "*" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in January", desc)
    end)
--
    it("month january", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "jAn" },
            day_of_week = { value = "*" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in January", desc)
    end)
--
    it("month february number", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "2" },
            day_of_week = { value = "*" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in February", desc)
    end)
--
    it("month february", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "feb" },
            day_of_week = { value = "*" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in February", desc)
    end)
--
    it("month march number", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "3" },
            day_of_week = { value = "*" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in March", desc)
    end)
--
    it("month march", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "mar" },
            day_of_week = { value = "*" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in March", desc)
    end)
--
    it("month april number", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "4" },
            day_of_week = { value = "*" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in April", desc)
    end)
--
    it("month april", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "apr" },
            day_of_week = { value = "*" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in April", desc)
    end)
--
    it("month may number", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "5" },
            day_of_week = { value = "*" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in May", desc)
    end)
--
    it("month may", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "may" },
            day_of_week = { value = "*" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in May", desc)
    end)
--
    it("month june number", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "6" },
            day_of_week = { value = "*" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in June", desc)
    end)
--
    it("month june", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "jun" },
            day_of_week = { value = "*" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in June", desc)
    end)
--
    it("month july number", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "7" },
            day_of_week = { value = "*" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in July", desc)
    end)
--
    it("month july", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "jul" },
            day_of_week = { value = "*" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in July", desc)
    end)
--
    it("month august number", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "8" },
            day_of_week = { value = "*" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in August", desc)
    end)
--
    it("month august", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "aug" },
            day_of_week = { value = "*" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in August", desc)
    end)
--
    it("month september number", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "9" },
            day_of_week = { value = "*" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in September", desc)
    end)
--
    it("month september", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "sep" },
            day_of_week = { value = "*" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in September", desc)
    end)
--
    it("month october number", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "10" },
            day_of_week = { value = "*" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in October", desc)
    end)
--
    it("month october", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "oct" },
            day_of_week = { value = "*" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in October", desc)
    end)
--
    it("month november number", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "11" },
            day_of_week = { value = "*" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in November", desc)
    end)
--
    it("month november", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "nov" },
            day_of_week = { value = "*" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in November", desc)
    end)
--
    it("month december number", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "12" },
            day_of_week = { value = "*" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in December", desc)
    end)
--
    it("month december", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "dec" },
            day_of_week = { value = "*" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in December", desc)
    end)
--
    it("month invalid number", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "13" },
            day_of_week = { value = "*" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("Invalid month must be between 1 to 12 or JAN to DEC", desc)
    end)
--
    it("month invalid", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "IDK" },
            day_of_week = { value = "*" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("Invalid month must be between 1 to 12 or JAN to DEC", desc)
    end)
end)
--
describe("Test missing", function()
    it("missing minute", function()
        local cron = {
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "*" },
            day_of_week = { value = "*" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("Missing <minute> [0-59 or *]", desc)
    end)
--
    it("missing hour", function()
        local cron = {
            minute = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "*" },
            day_of_week = { value = "*" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("Missing <hour> [0-23 or *]", desc)
    end)
--
    it("missing day_of_month", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            month = { value = "*" },
            day_of_week = { value = "*" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("Missing <day_of_month> [1-31 or *]", desc)
    end)
--
    it("missing month", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            day_of_week = { value = "*" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("Missing <month> [1-12/JAN-DEC or *]", desc)
    end)
--
    it("missing day_of_week", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "*" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("Missing <day_of_week> [0-7/SUN-SAT or *]", desc)
    end)
--
    it("missing command", function()
        local cron = {
            minute = { value = "*" },
            hour = { value = "*" },
            day_of_month = { value = "*" },
            month = { value = "*" },
            day_of_week = { value = "*" },
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("Missing <command>", desc)
    end)
end)
--
describe("Describe misc", function()
    it("1 everything", function()
        local cron = {
            minute = { value = "1" },
            hour = { value = "1" },
            day_of_month = { value = "1" },
            month = { value = "1" },
            day_of_week = { value = "1" },
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At 01:01 on day-of-month 1 and on Monday in January", desc)
    end)
end)

describe("Progressive cron hints", function()
    it("empty line shows missing minute", function()
        local line = ""
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_equal("Missing <minute> [0-59 or *]", parsed.error)
    end)

    it("only minute shows missing hour", function()
        local line = "*/5"
        local parsed = parser.parse_cron_line(line)

        if parsed.error then
            assert.is_equal("Missing <hour> [0-23 or *]", parsed.error)
        else
            local desc = describer.describe(parsed.success)
            assert.is_equal("Missing <hour> [0-23 or *]", desc)
        end
    end)

    it("minute and hour shows missing day_of_month", function()
        local line = "*/5 *"
        local parsed = parser.parse_cron_line(line)

        if parsed.error then
            assert.is_equal("Missing <day_of_month> [1-31 or *]", parsed.error)
        else
            local desc = describer.describe(parsed.success)
            assert.is_equal("Missing <day_of_month> [1-31 or *]", desc)
        end
    end)

    it("three fields shows missing month", function()
        local line = "*/5 * *"
        local parsed = parser.parse_cron_line(line)

        if parsed.error then
            assert.is_equal("Missing <month> [1-12/JAN-DEC or *]", parsed.error)
        else
            local desc = describer.describe(parsed.success)
            assert.is_equal("Missing <month> [1-12/JAN-DEC or *]", desc)
        end
    end)

    it("four fields shows missing day_of_week", function()
        local line = "*/5 * * *"
        local parsed = parser.parse_cron_line(line)

        if parsed.error then
            assert.is_equal("Missing <day_of_week> [0-7/SUN-SAT or *]", parsed.error)
        else
            local desc = describer.describe(parsed.success)
            assert.is_equal("Missing <day_of_week> [0-7/SUN-SAT or *]", desc)
        end
    end)

    it("five fields shows missing command", function()
        local line = "*/5 * * * *"
        local parsed = parser.parse_cron_line(line)

        if parsed.error then
            assert.is_equal("Missing <command>", parsed.error)
        else
            local desc = describer.describe(parsed.success)
            assert.is_equal("Missing <command>", desc)
        end
    end)
end)

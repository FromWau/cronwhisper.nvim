---@diagnostic disable: undefined-field
local parser = require "cronwhisper.parser"
local describer = require "cronwhisper.describer"

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
        assert.is_equal("0", success.minute)
        assert.is_equal("0", success.hour)
        assert.is_equal("1", success.day_of_month)
        assert.is_equal("1", success.month)
        assert.is_equal("*", success.day_of_week)
        assert.is_equal("do_something.sh", success.command)
    end)

    it("Parse annually", function()
        local line = "@annually do_something.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_equal("0", success.minute)
        assert.is_equal("0", success.hour)
        assert.is_equal("1", success.day_of_month)
        assert.is_equal("1", success.month)
        assert.is_equal("*", success.day_of_week)
        assert.is_equal("do_something.sh", success.command)
    end)

    it("Parse monthly", function()
        local line = "@monthly do_something.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_equal("0", success.minute)
        assert.is_equal("0", success.hour)
        assert.is_equal("1", success.day_of_month)
        assert.is_equal("*", success.month)
        assert.is_equal("*", success.day_of_week)
        assert.is_equal("do_something.sh", success.command)
    end)

    it("Parse weekly", function()
        local line = "@weekly do_something.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_equal("0", success.minute)
        assert.is_equal("0", success.hour)
        assert.is_equal("*", success.day_of_month)
        assert.is_equal("*", success.month)
        assert.is_equal("0", success.day_of_week)
        assert.is_equal("do_something.sh", success.command)
    end)

    it("Parse daily", function()
        local line = "@daily do_something.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_equal("0", success.minute)
        assert.is_equal("0", success.hour)
        assert.is_equal("*", success.day_of_month)
        assert.is_equal("*", success.month)
        assert.is_equal("*", success.day_of_week)
        assert.is_equal("do_something.sh", success.command)
    end)

    it("Parse hourly", function()
        local line = "@hourly do_something.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_equal("0", success.minute)
        assert.is_equal("*", success.hour)
        assert.is_equal("*", success.day_of_month)
        assert.is_equal("*", success.month)
        assert.is_equal("*", success.day_of_week)
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
        assert.is_equal("*/2", success.minute)
        assert.is_equal("*", success.hour)
        assert.is_equal("*", success.day_of_month)
        assert.is_equal("*", success.month)
        assert.is_equal("*", success.day_of_week)
        assert.is_equal("some_command.sh", success.command)
    end)

    it("minute step", function()
        local line = "*/ * * * * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_not_nil(parsed.error)
        assert.is_nil(parsed.success)

        local error = parsed.error
        assert.is_equal("Missing frequency", error)
    end)

    it("hour step", function()
        local line = "* */2 * * * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_equal("*", success.minute)
        assert.is_equal("*/2", success.hour)
        assert.is_equal("*", success.day_of_month)
        assert.is_equal("*", success.month)
        assert.is_equal("*", success.day_of_week)
        assert.is_equal("some_command.sh", success.command)
    end)

    it("day_of_month step", function()
        local line = "* * */2 * * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_equal("*", success.minute)
        assert.is_equal("*", success.hour)
        assert.is_equal("*/2", success.day_of_month)
        assert.is_equal("*", success.month)
        assert.is_equal("*", success.day_of_week)
        assert.is_equal("some_command.sh", success.command)
    end)

    it("month step", function()
        local line = "* * * */2 * some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_equal("*", success.minute)
        assert.is_equal("*", success.hour)
        assert.is_equal("*", success.day_of_month)
        assert.is_equal("*/2", success.month)
        assert.is_equal("*", success.day_of_week)
        assert.is_equal("some_command.sh", success.command)
    end)

    it("month step", function()
        local line = "* * * * */2 some_command.sh"
        local parsed = parser.parse_cron_line(line)
        assert.is_nil(parsed.error)
        assert.is_not_nil(parsed.success)

        local success = parsed.success
        assert.is_equal("*", success.minute)
        assert.is_equal("*", success.hour)
        assert.is_equal("*", success.day_of_month)
        assert.is_equal("*", success.month)
        assert.is_equal("*/2", success.day_of_week)
        assert.is_equal("some_command.sh", success.command)
    end)
end)

describe("Describe time", function()
    it("nil", function()
        local cron = {}
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("Nothing to describe", desc)
    end)

    it("minute ok", function()
        local cron = {
            minute = "0",
            hour = "*",
            day_of_month = "*",
            month = "*",
            day_of_week = "*",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At minute 0", desc)
    end)

    it("minute nok", function()
        local cron = {
            minute = "69",
            hour = "*",
            day_of_month = "*",
            month = "*",
            day_of_week = "*",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("Invalid minute must be between 0 to 59", desc)
    end)

    it("hour ok", function()
        local cron = {
            minute = "*",
            hour = "12",
            day_of_month = "*",
            month = "*",
            day_of_week = "*",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute past hour 12", desc)
    end)

    it("hour nok", function()
        local cron = {
            minute = "*",
            hour = "42",
            day_of_month = "*",
            month = "*",
            day_of_week = "*",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("Invalid hour must be between 0 to 23", desc)
    end)

    it("time ok", function()
        local cron = {
            minute = "0",
            hour = "12",
            day_of_month = "*",
            month = "*",
            day_of_week = "*",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At 12:00", desc)
    end)
end)

describe("Describe day of month", function()
    it("day_of_month ok", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "1",
            month = "*",
            day_of_week = "*",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute on day-of-month 1", desc)
    end)

    it("day_of_month nok", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "32",
            month = "*",
            day_of_week = "*",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("Invalid day_of_month must be between 1 to 31", desc)
    end)
end)

describe("Describe day_of_week", function()
    it("day_of_week monday number", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "*",
            day_of_week = "1",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute on Monday", desc)
    end)

    it("day_of_week monday", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "*",
            day_of_week = "MON",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute on Monday", desc)
    end)

    it("day_of_week tuesday number", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "*",
            day_of_week = "2",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute on Tuesday", desc)
    end)

    it("day_of_week tuesday", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "*",
            day_of_week = "tue",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute on Tuesday", desc)
    end)

    it("day_of_week wednesday number", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "*",
            day_of_week = "3",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute on Wednesday", desc)
    end)

    it("day_of_week wednesday", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "*",
            day_of_week = "wed",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute on Wednesday", desc)
    end)

    it("day_of_week thursday number", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "*",
            day_of_week = "4",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute on Thursday", desc)
    end)

    it("day_of_week thursday", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "*",
            day_of_week = "thu",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute on Thursday", desc)
    end)

    it("day_of_week friday number", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "*",
            day_of_week = "5",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute on Friday", desc)
    end)

    it("day_of_week friday", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "*",
            day_of_week = "Fri",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute on Friday", desc)
    end)

    it("day_of_week saturday number", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "*",
            day_of_week = "6",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute on Saturday", desc)
    end)

    it("day_of_week saturday", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "*",
            day_of_week = "sat",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute on Saturday", desc)
    end)

    it("day_of_week sunday number special", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "*",
            day_of_week = "7",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute on Sunday", desc)
    end)

    it("day_of_week sunday number", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "*",
            day_of_week = "0",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute on Sunday", desc)
    end)

    it("day_of_week sunday", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "*",
            day_of_week = "sun",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute on Sunday", desc)
    end)
end)

describe("Describe month", function()
    it("month january number", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "1",
            day_of_week = "*",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in January", desc)
    end)

    it("month january", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "jAn",
            day_of_week = "*",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in January", desc)
    end)

    it("month february number", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "2",
            day_of_week = "*",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in February", desc)
    end)

    it("month february", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "feb",
            day_of_week = "*",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in February", desc)
    end)

    it("month march number", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "3",
            day_of_week = "*",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in March", desc)
    end)

    it("month march", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "mar",
            day_of_week = "*",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in March", desc)
    end)

    it("month april number", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "4",
            day_of_week = "*",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in April", desc)
    end)

    it("month april", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "apr",
            day_of_week = "*",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in April", desc)
    end)

    it("month may number", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "5",
            day_of_week = "*",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in May", desc)
    end)

    it("month may", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "may",
            day_of_week = "*",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in May", desc)
    end)

    it("month june number", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "6",
            day_of_week = "*",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in June", desc)
    end)

    it("month june", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "jun",
            day_of_week = "*",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in June", desc)
    end)

    it("month july number", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "7",
            day_of_week = "*",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in July", desc)
    end)

    it("month july", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "jul",
            day_of_week = "*",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in July", desc)
    end)

    it("month august number", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "8",
            day_of_week = "*",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in August", desc)
    end)

    it("month august", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "aug",
            day_of_week = "*",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in August", desc)
    end)

    it("month september number", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "9",
            day_of_week = "*",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in September", desc)
    end)

    it("month september", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "sep",
            day_of_week = "*",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in September", desc)
    end)

    it("month october number", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "10",
            day_of_week = "*",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in October", desc)
    end)

    it("month october", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "oct",
            day_of_week = "*",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in October", desc)
    end)

    it("month november number", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "11",
            day_of_week = "*",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in November", desc)
    end)

    it("month november", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "nov",
            day_of_week = "*",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in November", desc)
    end)

    it("month december number", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "12",
            day_of_week = "*",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in December", desc)
    end)

    it("month december", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "dec",
            day_of_week = "*",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At every minute in December", desc)
    end)

    it("month invalid number", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "13",
            day_of_week = "*",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("Invalid month must be between 1 to 12 or JAN to DEC", desc)
    end)

    it("month invalid", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "IDK",
            day_of_week = "*",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("Invalid month must be between 1 to 12 or JAN to DEC", desc)
    end)
end)

describe("Test missing", function()
    it("missing minute", function()
        local cron = {
            hour = "*",
            day_of_month = "*",
            month = "*",
            day_of_week = "*",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("Missing <minute> [1-59]", desc)
    end)

    it("missing hour", function()
        local cron = {
            minute = "*",
            day_of_month = "*",
            month = "*",
            day_of_week = "*",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("Missing <hour> [0-23]", desc)
    end)

    it("missing day_of_month", function()
        local cron = {
            minute = "*",
            hour = "*",
            month = "*",
            day_of_week = "*",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("Missing <day_of_month> [1-31]", desc)
    end)

    it("missing month", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            day_of_week = "*",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("Missing <month> [1-12/JAN-DEC]", desc)
    end)

    it("missing day_of_week", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "*",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("Missing <day_of_week> [0-7(Sun, Mo, ..., Sun)/SUN-SAT]", desc)
    end)

    it("missing command", function()
        local cron = {
            minute = "*",
            hour = "*",
            day_of_month = "*",
            month = "*",
            day_of_week = "*",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("Missing <command>", desc)
    end)
end)

describe("Describe misc", function()
    it("1 everything", function()
        local cron = {
            minute = "1",
            hour = "1",
            day_of_month = "1",
            month = "1",
            day_of_week = "1",
            command = "do_something.sh",
        }
        local desc = describer.describe(cron)
        assert.is_not_nil(desc)
        assert.is_equal("At 01:01 on day-of-month 1 and on Monday in January", desc)
    end)
end)

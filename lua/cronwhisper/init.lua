local parser = require "cronwhisper.parser"
local describer = require "cronwhisper.describer"
local ui = require "cronwhisper.ui"
local config = require "cronwhisper.config"

local M = {}

---@class CronwhisperConfig
---@field default_action? "float"|"virtual"|"echo" Default action for showing cron description
---@field float_opts? table Floating window options
---@field virtual_text_hl? string Highlight group for virtual text
---@field auto_describe? boolean Automatically describe on CursorHold

M.config = config

---Setup cronwhisper plugin
---@param opts? CronwhisperConfig
function M.setup(opts)
    config.setup(opts or {})

    -- Create user commands
    vim.api.nvim_create_user_command("CronDescribe", function(cmd_opts)
        M.describe_current_line(cmd_opts.args)
    end, {
        nargs = "?",
        desc = "Describe cron expression on current line",
    })

    vim.api.nvim_create_user_command("CronParse", function()
        M.parse_current_line()
    end, {
        desc = "Parse cron expression on current line and show structure",
    })

    vim.api.nvim_create_user_command("CronValidate", function()
        M.validate_current_line()
    end, {
        desc = "Validate cron expression on current line",
    })

    -- Auto-describe on cursor hold if enabled
    if config.options.auto_describe then
        vim.api.nvim_create_autocmd("CursorHold", {
            pattern = "*",
            callback = function()
                local line = vim.api.nvim_get_current_line()
                if M.looks_like_cron(line) then M.describe_current_line "virtual" end
            end,
        })
    end
end

---Check if a line looks like a cron expression
---@param line string
---@return boolean
function M.looks_like_cron(line)
    -- Simple heuristic: starts with number, *, or @ and has at least 5 space-separated fields
    local trimmed = line:match "^%s*(.-)%s*$"
    if trimmed:match "^@" then return true end

    local fields = vim.split(trimmed, "%s+")
    return #fields >= 6
end

---Parse cron expression from current line
---@return table|nil parsed Parsed cron structure or nil on error
---@return string|nil error Error message if parsing failed
function M.parse_current_line()
    local line = vim.api.nvim_get_current_line()
    local parsed = parser.parse_cron_line(line)

    if parsed.error then
        vim.notify("Cron parse error: " .. parsed.error, vim.log.levels.ERROR)
        return nil, parsed.error
    end

    -- Show parsed structure
    ui.show_parsed_structure(parsed.success)
    return parsed.success, nil
end

---Validate cron expression on current line
---@return boolean valid Whether the cron expression is valid
function M.validate_current_line()
    local line = vim.api.nvim_get_current_line()
    local parsed = parser.parse_cron_line(line)

    if parsed.error then
        vim.notify("❌ Invalid: " .. parsed.error, vim.log.levels.ERROR)
        return false
    end

    vim.notify("✓ Valid cron expression", vim.log.levels.INFO)
    return true
end

---Describe cron expression on current line
---@param action? "float"|"virtual"|"echo" How to display the description
function M.describe_current_line(action)
    local line = vim.api.nvim_get_current_line()
    local parsed = parser.parse_cron_line(line)

    if parsed.error then
        vim.notify("Cannot describe: " .. parsed.error, vim.log.levels.ERROR)
        return
    end

    local description = describer.describe(parsed.success)
    local display_action = action or config.options.default_action

    if display_action == "float" then
        ui.show_in_float(description, line)
    elseif display_action == "virtual" then
        ui.show_as_virtual_text(description)
    else
        vim.notify(description, vim.log.levels.INFO)
    end
end

---Parse and describe a cron expression string
---@param cron_line string The cron expression to parse
---@return string|nil description The description or nil on error
---@return string|nil error Error message if parsing failed
function M.describe(cron_line)
    local parsed = parser.parse_cron_line(cron_line)

    if parsed.error then return nil, parsed.error end

    local description = describer.describe(parsed.success)
    return description, nil
end

---Parse a cron expression string
---@param cron_line string The cron expression to parse
---@return table|nil parsed Parsed structure or nil on error
---@return string|nil error Error message if parsing failed
function M.parse(cron_line)
    local parsed = parser.parse_cron_line(cron_line)

    if parsed.error then return nil, parsed.error end

    return parsed.success, nil
end

return M

local parser = require "cronwhisper.parser"
local describer = require "cronwhisper.describer"
local ui = require "cronwhisper.ui"
local config = require "cronwhisper.config"

local M = {}

M.config = config

---Setup cronwhisper plugin (optional - commands work without setup)
---@param opts? CronwhisperConfig
function M.setup(opts)
    config.setup(opts or {})
end

---Check if a line looks like a cron expression
---@param line string
---@return boolean
function M.looks_like_cron(line)
    local trimmed = line:match "^%s*(.-)%s*$"

    -- Ignore comment lines
    if trimmed:match "^#" then return false end

    -- Empty lines show missing minute hint
    if trimmed == "" then return true end

    -- Special commands (@reboot, @daily, etc.)
    if trimmed:match "^@" then return true end

    -- Any line with cron-like content (numbers, *, -, etc.)
    if trimmed:match "^[%d%*%-%,/]" then return true end

    return false
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

---Show cron description as virtual text on current line
function M.describe_current_line()
    local line = vim.api.nvim_get_current_line()
    local parsed = parser.parse_cron_line(line)

    local description
    if parsed.error then
        description = parsed.error
    else
        description = describer.describe(parsed.success)
    end

    ui.show_as_virtual_text(description)
end

---Show cron description in floating window
function M.show_float()
    local line = vim.api.nvim_get_current_line()
    local parsed = parser.parse_cron_line(line)

    local description
    if parsed.error then
        description = parsed.error
    else
        description = describer.describe(parsed.success)
    end

    ui.show_in_float(description, line)
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

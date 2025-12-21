local config = require "cronwhisper.config"

local M = {}

local namespace_id = vim.api.nvim_create_namespace "cronwhisper"

-- Store the current float window ID
local float_win_id = nil

---Show description in a floating window
---@param description string The cron description
---@param cron_line string The original cron expression
function M.show_in_float(description, cron_line)
    -- Close existing float if any
    if float_win_id and vim.api.nvim_win_is_valid(float_win_id) then
        vim.api.nvim_win_close(float_win_id, true)
    end

    local buf = vim.api.nvim_create_buf(false, true)
    local lines = {
        "Cron Expression:",
        "  " .. cron_line,
        "",
        "Description:",
        "  " .. description,
    }

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    local opts = vim.tbl_deep_extend("force", {
        style = "minimal",
        width = math.max(40, #description + 4),
        height = #lines,
    }, config.options.float_opts)

    float_win_id = vim.api.nvim_open_win(buf, false, opts)

    -- Auto-close on cursor move
    local augroup = vim.api.nvim_create_augroup("CronwhisperFloat", { clear = true })
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufLeave" }, {
        group = augroup,
        callback = function()
            if float_win_id and vim.api.nvim_win_is_valid(float_win_id) then
                vim.api.nvim_win_close(float_win_id, true)
                float_win_id = nil
            end
            -- Clear the autocmd after closing
            vim.api.nvim_clear_autocmds({ group = augroup })
        end,
    })
end

---Show description as virtual text
---@param description string The cron description
function M.show_as_virtual_text(description)
    local bufnr = vim.api.nvim_get_current_buf()
    local line = vim.api.nvim_win_get_cursor(0)[1] - 1

    -- Clear existing virtual text
    vim.api.nvim_buf_clear_namespace(bufnr, namespace_id, 0, -1)

    -- Add virtual text
    vim.api.nvim_buf_set_extmark(bufnr, namespace_id, line, 0, {
        virt_text = { { "  → " .. description, config.options.virtual_text_hl } },
        virt_text_pos = "eol",
    })
end

---Clear all virtual text
function M.clear_virtual_text()
    local bufnr = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_clear_namespace(bufnr, namespace_id, 0, -1)
end

---Show parsed structure in a floating window
---@param parsed table The parsed cron structure
function M.show_parsed_structure(parsed)
    local PrettyPrint = require "PrettyPrint"
    local output = PrettyPrint.prettyPrint(parsed)

    local buf = vim.api.nvim_create_buf(false, true)
    local lines = vim.split(output, "\n")

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(buf, "filetype", "lua")

    local width = 0
    for _, line in ipairs(lines) do
        width = math.max(width, #line)
    end

    local opts = vim.tbl_deep_extend("force", {
        style = "minimal",
        width = math.min(width + 4, 100),
        height = math.min(#lines, 30),
    }, config.options.float_opts)

    vim.api.nvim_open_win(buf, false, opts)
end

return M

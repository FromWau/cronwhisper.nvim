-- Keybinding for cron files
-- K - Show cron description in floating window (overrides default man page lookup)
vim.keymap.set("n", "K", function()
    require("cronwhisper").show_float()
end, { buffer = true, desc = "Show cron description in float" })

-- Auto-describe functionality with performance optimization
local cronwhisper = require("cronwhisper")
local config = require("cronwhisper.config")

if config.options.auto_describe then
    -- Cache last line number and content to avoid redundant parsing
    local last_line_nr = -1
    local last_line_content = ""

    -- Auto-describe on cursor move and text changes in insert mode
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "TextChangedI" }, {
        buffer = 0,
        callback = function()
            local current_line_nr = vim.api.nvim_win_get_cursor(0)[1]
            local line = vim.api.nvim_get_current_line()

            -- Only process if line number or content changed
            if current_line_nr ~= last_line_nr or line ~= last_line_content then
                last_line_nr = current_line_nr
                last_line_content = line

                if cronwhisper.looks_like_cron(line) then
                    cronwhisper.describe_current_line()
                else
                    require("cronwhisper.ui").clear_virtual_text()
                end
            end
        end,
    })

    -- Clear virtual text when leaving buffer
    vim.api.nvim_create_autocmd("BufLeave", {
        buffer = 0,
        callback = function()
            require("cronwhisper.ui").clear_virtual_text()
            last_line_nr = -1 -- Reset cache
            last_line_content = ""
        end,
    })
end

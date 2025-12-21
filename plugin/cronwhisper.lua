-- Commands for cronwhisper.nvim
-- This file is automatically loaded by Neovim and lazy.nvim

if vim.g.loaded_cronwhisper then
    return
end
vim.g.loaded_cronwhisper = 1

-- Create user commands (lazy-loaded automatically)
vim.api.nvim_create_user_command("CronDescribe", function()
    require("cronwhisper").show_float()
end, {
    desc = "Show cron description in floating window",
    range = false,
})

vim.api.nvim_create_user_command("CronParse", function()
    require("cronwhisper").parse_current_line()
end, {
    desc = "Parse cron expression on current line and show structure",
    range = false,
})

vim.api.nvim_create_user_command("CronValidate", function()
    require("cronwhisper").validate_current_line()
end, {
    desc = "Validate cron expression on current line",
    range = false,
})

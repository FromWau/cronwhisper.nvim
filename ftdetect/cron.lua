-- Detect cron files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.cron", "crontab", "crontab.*", "*/cron.d/*", "*/cron.daily/*", "*/cron.hourly/*", "*/cron.weekly/*", "*/cron.monthly/*" },
    callback = function()
        vim.bo.filetype = "cron"
    end,
})

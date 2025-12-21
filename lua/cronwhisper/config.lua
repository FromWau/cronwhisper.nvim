local M = {}

---@class CronwhisperConfig
---@field float_opts? table Floating window options
---@field virtual_text_hl? string Highlight group for virtual text
---@field auto_describe? boolean Automatically show virtual text on cursor move

M.options = {
    float_opts = {
        border = "rounded",
        relative = "cursor",
        row = 1,
        col = 0,
    },
    virtual_text_hl = "Comment",
    auto_describe = true,
}

---Setup configuration
---@param opts CronwhisperConfig
function M.setup(opts)
    M.options = vim.tbl_deep_extend("force", M.options, opts)
end

return M
